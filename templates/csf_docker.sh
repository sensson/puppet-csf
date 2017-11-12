#!/bin/bash
#
# Docker firewall rules
#
# We do not accept incoming traffic by default and it's recommended to
# turn off the Docker implementation of iptables. This will handle all
# rules for you instead.
#
# If Docker restarts you may need to restart the firewall too.
#

export PATH="$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# BASIC FIREWALL RULES
iptables -N DOCKER
iptables -N DOCKER-ISOLATION
iptables -t nat -N DOCKER
iptables -t nat -A PREROUTING -m addrtype --dst-type LOCAL -j DOCKER
iptables -t nat -A OUTPUT ! -d 127.0.0.0/8 -m addrtype --dst-type LOCAL -j DOCKER
iptables -A FORWARD -j DOCKER-ISOLATION

# Setup bridge traffic
setup_bridge() {
        local bridge=$(docker network inspect $1 -f '{{(index .Options "com.docker.network.bridge.name")}}')
        local network=$(docker network inspect $1 -f '{{(index .IPAM.Config 0).Subnet}}')

        if [[ -z "$bridge" ]]; then
                bridge="br-${1}"
        fi

        echo -n "Setup bridge.. "
        iptables -t nat -A POSTROUTING -s $network ! -o $bridge -j MASQUERADE
        iptables -t nat -A DOCKER -i $bridge -j RETURN
        iptables -A FORWARD -o $bridge -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
        iptables -A FORWARD -o $bridge -j DOCKER
        iptables -A FORWARD -i $bridge ! -o $bridge -j ACCEPT
        iptables -A FORWARD -i $bridge -o $bridge -j ACCEPT
        echo "DONE"
}

setup_isolation() {
        echo -n "Setup isolation.. "
        local bridge=$(docker network inspect $1 -f '{{(index .Options "com.docker.network.bridge.name")}}')

        if [[ -z "$bridge" ]]; then
                bridge="br-${1}"
        fi

        for network in $(docker network ls | grep -Ev "host|none|NETWORK|${1}" | awk '{print $1}'); do
                remote_bridge=$(docker network inspect $network -f '{{(index .Options "com.docker.network.bridge.name")}}')

                if [[ -z "$remote_bridge" ]]; then
                        remote_bridge="br-${network}"
                fi

                # check if we are not adding duplicate rules
                iptables -C DOCKER-ISOLATION -i $bridge -o $remote_bridge -j DROP > /dev/null 2>&1
                if [[ $? -eq 1 ]]; then
                        iptables -A DOCKER-ISOLATION -i $bridge -o $remote_bridge -j DROP
                fi

                # check if we are not adding duplicate rules
                iptables -C DOCKER-ISOLATION -i $remote_bridge -o $bridge -j DROP > /dev/null 2>&1
                if [[ $? -eq 1 ]]; then
                        iptables -A DOCKER-ISOLATION -i $remote_bridge -o $bridge -j DROP
                fi
        done
        echo "DONE"
}

setup_container() {
        # for every network
        for network in $(docker inspect $1 -f '{{range $bridge, $conf := .NetworkSettings.Networks}}{{$bridge}}{{end}}'); do
                ipaddress=$(docker inspect $1 -f "{{(index .NetworkSettings.Networks \"${network}\").IPAddress}}")

                bridge=$(docker network inspect $network -f '{{(index .Options "com.docker.network.bridge.name")}}')

                if [[ -z "$bridge" ]]; then
                        bridge="br-$(docker network inspect ${network} -f '{{.Id}}' | cut -c -12)"
                fi

                # for every port
                for port in $(docker inspect $1 -f '{{range $port, $conf := .NetworkSettings.Ports}}{{$port}};{{end}}' | tr ';' "\n"); do
                        protocol=$(echo $port | awk -F/ '{print $2}')
                        container_port=$(echo $port | awk -F/ '{print $1}')
                        host_port=$(docker inspect $1 -f "{{(index (index .NetworkSettings.Ports \"${port}\") 0).HostPort}}" 2>/dev/null)

                        iptables -A DOCKER -d $ipaddress/32 ! -i $bridge -o $bridge -p $protocol -m $protocol --dport $container_port -j ACCEPT

                        # create a rule for the host port if this is setup
                        if [[ ! -z "$host_port" ]]; then
                                iptables -t nat -A POSTROUTING -s $ipaddress/32 -d $ipaddress/32 -p $protocol -m $protocol --dport $host_port -j MASQUERADE
                        fi

                        iptables -t nat -A POSTROUTING -s $ipaddress/32 -d $ipaddress/32 -p $protocol -m $protocol --dport $container_port -j MASQUERADE
                done
        done
}

open_port() {
        container=$1
        dport=$2
        port=$3
        ip_source=${4:-0.0.0.0/0}
        network=${5:-bridge}

        : "${container:?container needs to be set}"
        : "${dport:?dport needs to be set}"
        : "${port:?dport needs to be set}"

        ipaddress=$(docker inspect $container -f "{{(index .NetworkSettings.Networks \"${network}\").IPAddress}}")
        iptables -t nat -A DOCKER -p tcp -m tcp -s $ip_source --dport $dport -j DNAT --to-destination $ipaddress:$port
}

for network in $(docker network ls | grep -Ev 'host|none|NETWORK' | awk '{print $1}'); do
        setup_bridge $network
        setup_isolation $network
done

for container in $(docker ps -q); do
        setup_container $container
done

# Wrap up docker-isolation
iptables -A DOCKER-ISOLATION -j RETURN

# If you want to open up external ports you could use
# iptables -t nat -A DOCKER ! -i docker0 -p tcp -m tcp -s SOURCE --dport 8000 -j DNAT --to-destination 172.17.0.2:80
# or
# open_port gifted_einstein 8000 80 192.168.0.0/24 data_network
