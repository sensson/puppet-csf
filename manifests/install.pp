# csf::install
class csf::install inherits csf {
  # this installs csf and reloads it
  if $::operatingsystem == 'CentOS' and $::operatingsystemmajrelease != '7' {
    package { 'iptables-ipv6':
      ensure => installed,
      before => Exec['csf-install'],
    }
  }

  package { 'csf-perl':
    ensure => installed,
    name   => 'perl',
  } ->
  exec { 'csf-install':
    cwd     => '/tmp',
    command => "/usr/bin/wget -N ${::csf::download_location} && tar -xzf csf.tgz && cd csf && sh install.sh",
    creates => '/usr/sbin/csf',
    notify  => Exec['csf-reload'],
    require => Package['csf-perl'],
  }

  # make sure testing is disabled, we trust puppet enough
  csf::config { 'TESTING': value => '0' }

  # make sure puppet masters are always accessible
  csf::ipv4::output { '8140': require => Exec['csf-install'], }
}
