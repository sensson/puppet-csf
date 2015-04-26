# csf

This module installs the ConfigServer Firewall and adds
some functions to manage it from other modules.

We haven't added support to change the main configuration
file yet although that may be added in the future if certain
changes require us to do so. 

By default it will open up port 8140 for outgoing connections
to the puppet master. All other ports, except for 20 and 22, are
closed. 

## Prerequisites
We assume that your site.pp has the following snippet in there

```
Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }
```

## Examples
### Install CSF
This module is very basic as it is. We have provided a default CSF
configuration file which we believe is useful, but you can configure
it so it doesn't take control of csf.conf too. By default it will though.

There are other options available, but you need to have manage_config set
to true to make use of them otherwise they won't work. More options will
be made available in the future. For example; enable or disable e-mails.

```
class { "csf": manage_config => true, ipv6 = '1', }
``` 

### Open up a port in CSF
The most basic functionality is to open up a port in CSF. You can open
up an incoming port with the following basic example:

```
csf::ipv4::input { '443': }
```

A little more advanced is the following example where we specifically
tell CSF it should open a TCP port.

```
csf::ipv4::input  { '3306':
	proto	=> 'tcp',
}
```

Of course, you can use arrays too to open up more ports at the same time

```
csf::ipv4::input { [ '80', '443' ]: }
```

As soon as you remove a port it will not be part of the configuration
any more.

### Making global changes
CSF has some default lists you can use to either ignore, deny or allow
IP addresses from either accessing your server or to prevent they will
get banned by LFD.

To allow an IP address, or range, you can use the following code

```
csf::allow { '192.168.0.0/24': }
```

In contrast with ports, you will have to specifically disable a setting to
remove it from the config, for example:

```
csf::allow { '192.168.0.0/24': ensure => absent, }
```

Similar functions are available for csf::ignore and csf::deny. Again this
does accept arrays too.

### Add an advanced rules to CSF
This module allows you to set up advanced iptables rules if you need to. But
please keep in mind that we only add rules once CSF has been loaded entirely.

For example:

```
csf::rule { 'csf-rule-port-80-from-192.168.0.1':
	content => "/sbin/iptables -I INPUT -p tcp --dport 80 -s 192.168.0.1/32 -j ACCEPT",
	order	=> "1",
}
```

This will set up a rule that allows traffic to port 80 only from the internal
ip address 192.168.0.1/32. You can order firewall rules if needed. The function
csf::ipv4::input will use an order of 99 by default so if you need to set some
rules first you can change the order as well. It will by default add rules to 
/etc/csf/csfpost.sh, but you could use target => '/etc/csf/csfpre.sh', if you
need to run rules before other parts are initialized.

Removing a csf::rule from your configuration will automatically remove it from
the running config as well.

## Hiera

We support hiera.

```
csf::ipv4::input::ports:
  '82':
    proto: udp
  '81': {}
```

Will open up port 82 UDP and 81 TCP. Similar Hiera settings are available for
`csf::ipv4::output::ports`, `csf::allow::hosts`, `csf::ignore::hosts` and
`csf::deny::hosts`. Setting {} is required when you're not specifying any other
parameters. All settings from the parent are supported.
