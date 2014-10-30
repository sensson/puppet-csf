/sbin/iptables -I <%= @chain %> -p <%= @proto %> --dport <%= @port %> -j ACCEPT
