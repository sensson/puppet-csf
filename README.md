# csf

[![Build Status](https://travis-ci.org/sensson/puppet-csf.svg?branch=master)](https://travis-ci.org/sensson/puppet-csf) [![Puppet Forge](https://img.shields.io/puppetforge/v/sensson/csf.svg?maxAge=2592000?style=plastic)](https://forge.puppet.com/sensson/csf)

This module manages ConfigServer Firewall and the Login Failure Daemon.

By default it will open up port 8140 for outgoing connections to the puppet 
master. All other ports are unmanaged and set to the default that comes
with the installation of CSF. You definitely want to change this.

## Examples

### Installation and configuration

This will install CSF and only allow access through port 22.

```
class { 'csf': }
csf::config { 'TCP_IN': value => '22' }
``` 

#### Open up a port in CSF

The most basic functionality is to open up a port in CSF. You can open
up an incoming port with the following basic example:

```
csf::ipv4::input { '443': }
```

A little more advanced is the following example where we specifically
tell CSF it should open a TCP port.

```
csf::ipv4::input  { '3306':
  proto => 'tcp',
}
```

Of course, you can use arrays too to open up more ports at the same time

```
csf::ipv4::input { [ '80', '443' ]: }
```

As soon as you remove a port it will not be part of the configuration
any more.

#### Making global changes: allow, deny and ignore

CSF has some default configurations you can use to either ignore, deny or allow
IP addresses from either accessing your server or to prevent they will
get banned by the Login Failure Daemon.

To allow an IP address, or range, you can use the following code

```
csf::allow { '192.168.0.0/24': }
```

In contrast with ports, you will have to specifically disable a setting to
remove it from the config, for example:

```
csf::allow { '192.168.0.0/24': ensure => absent, }
```

Similar functions are available for csf::ignore and csf::deny. All of these
functions accept arrays too.

#### Add advanced rules to CSF

This module allows you to set up advanced iptables rules if you need to. 

For example:

```
csf::rule { 'csf-rule-port-80-from-192.168.0.1':
  content => "/sbin/iptables -I INPUT -p tcp --dport 80 -s 192.168.0.1/32 -j ACCEPT",
  order => "1",
}
```

This will set up a rule that allows traffic to port 80 only from the internal
ip address 192.168.0.1/32. You can order firewall rules if needed. It will by 
default add rules to /etc/csf/csfpost.sh, but you can specify csfpre too by using
`target => '/etc/csf/csfpre.sh` if you need to run rules before other parts are 
initialized.

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
`csf::ipv4::output::ports`, `csf::allow::hosts`, `csf::ignore::hosts`,
`csf::deny::hosts` and `csf::config::settings`. Setting {} is required when 
you're not specifying any other parameters. All settings from the parent are 
supported.

## Reference

### Parameters

#### csf

##### `download_location`

This allows you to override the download location. Defaults to https://download.configserver.com/csf.tgz 

### Defines

#### csf::config

You can change settings in /etc/csf/csf.conf with `csf::config`. Keep in mind that it is case sensitive.

```
csf::config { 'TCP_IN':
  value => '22,80',
}
```

Alternatively you can manage ports using `csf::ipv4::input`. `csf::config` is mainly aimed
at changing configuration settings such as DENY_IP_LIMIT and so on.

##### `ensure`

Specify if you want the config setting to exist or not. This is particularly useful
if you made a mistake. Defaults to 'present'.

##### `title`

This is the setting you want to adjust. There is no verification if the setting
actually exists. If you make a mistake here it will simply add it. Defaults to ''.

##### `value`

Set the value of the configuration setting you want to change. Defaults to ''.

#### csf::ipv4::input

Open up a port for incoming ipv4 connections.

```
csf::ipv4::input { [ '80', '443']: proto => tcp, }
```

##### `port`

The port you want to open. Defaults to the title of the resource.

##### `proto`

The protocol it should be opened for. Defaults to 'tcp'.

#### csf::ipv4::output

Open up a port for outgoing ipv4 connections.

```
csf::ipv4::output { [ '80', '443']: proto => tcp, }
```

##### `port`

The port you want to open. Defaults to the title of the resource.

##### `proto`

The protocol it should be opened for. Defaults to 'tcp'.

#### csf::allow

This manages the /etc/csf/csf.allow file.

```
csf::allow { '192.168.0.1':
  ensure => present,
  comment => 'This is required for Apache',
}
```

##### `ipaddress`

Set the IP address that you want to allow access. Defaults to the title of the resource.

##### `ensure`

Valid values are 'present', 'absent'. Defaults to 'present'.

##### `comment`

Add a comment for your entry. Defaults to 'puppet'.

#### csf::deny

This manages the /etc/csf/csf.deny file.

```
csf::deny { '192.168.0.1':
  ensure => present,
  comment => 'This is required for Apache',
}
```

##### `ipaddress`

Set the IP address that you want to deny access. Defaults to the title of the resource.

##### `ensure`

Valid values are 'present', 'absent'. Defaults to 'present'.

##### `comment`

Add a comment for your entry. Defaults to 'puppet'.

#### csf::ignore

This manages the /etc/csf/csf.ignore file.

```
csf::ignore { '192.168.0.1':
  ensure => present,
  comment => 'This is required for Apache',
}
```

##### `ipaddress`

Set the IP address that you want to ignore in LFD. Defaults to the title of the resource.

##### `ensure`

Valid values are 'present', 'absent'. Defaults to 'present'.

##### `comment`

Add a comment for your entry. Defaults to 'puppet'.

#### csf::global

This is used to manage global configuration files in CSF such as /etc/csf/csf.allow. It
is mostly used by functions such as `csf::allow`, `csf::deny` and `csf::ignore`.

```
csf::global { '192.168.0.1':
  ensure => present,
  type => 'ignore',
  comment => 'This is required for Apache',
}
```

##### `ipaddress`

Set the IP address that you're managing. Defaults to '127.0.0.1'.

##### `type`

Set the file type you want to manage. Valid values are 'ignore', 'allow', 'deny'. Defaults to 'ignore'.

##### `ensure`

Valid values are 'present', 'absent'. Defaults to 'present'.

##### `comment`

Add a comment for your entry. Defaults to 'puppet'

#### csf::rule

This allows you to set custom rules in CSF.

```
csf::rule { 'custom-rule':
  content => '/sbin/iptables -I INPUT -p tcp --dport 80 -s 192.168.0.1/32 -j ACCEPT',
  order => 1,
  target => '/etc/csf/csfpost.sh',
}
```

##### `content`

Set the content for the iptables rule. Defaults to ''.

##### `target`

Set the target you want to add the rule to. Defaults to '/etc/csf/csfpost.sh'.

##### `order`

Set the order in which you want to add the rules. This allows you to run certain
rules in a particular order. Defaults to '99'

## Limitations

This module has been tested on:

* Debian 7
* Debian 8
* CentOS 6
* CentOS 7
* Ubuntu 14.04
* Ubuntu 16.04

## Development

We strongly believe in the power of open source. This module is our way
of saying thanks.

This module is tested against the Ruby versions from Puppet's support
matrix. Please make sure you have a supported version of Ruby installed.

If you want to contribute please:

1. Fork the repository.
2. Run tests. It's always good to know that you can start with a clean slate.
3. Add a test for your change.
4. Make sure it passes.
5. Push to your fork and submit a pull request.

We can only accept pull requests with passing tests.

To install all of its dependencies please run:

```
bundle install --path vendor/bundle --without development
```

### Running unit tests

```
bundle exec rake test
```

### Running acceptance tests

The unit tests only verify if the code runs, not if it does exactly
what we want on a real machine. For this we use Beaker. Beaker will
start a new virtual machine (using Vagrant) and runs a series of
simple tests.

You can run Beaker tests with:

```
bundle exec rake spec_prep
BEAKER_destroy=onpass bundle exec rake beaker:debian7
BEAKER_destroy=onpass bundle exec rake beaker:debian8
BEAKER_destroy=onpass bundle exec rake beaker:centos6
BEAKER_destroy=onpass bundle exec rake beaker:centos7
BEAKER_destroy=onpass bundle exec rake beaker:ubuntu1404
BEAKER_destroy=onpass bundle exec rake beaker:ubuntu1604
```

We recommend specifying BEAKER_destroy=onpass as it will keep the
Vagrant machine running in case something fails.
