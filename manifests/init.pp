# csf
class csf(
  $download_location = $::csf::params::download_location,
  $docker = $::csf::params::docker
) inherits csf::params {
  # Install and configure CSF as required
  include ::csf::install
  include ::csf::docker

  # This controls CSF restarts - keep in mind that this will also enable it.
  exec { 'csf-reload':
    command     => '/usr/sbin/csf -e; /usr/sbin/csf -r',
    refreshonly => true,
    onlyif      => '/usr/bin/test -f /etc/csf/csf.conf',
  }

  # This is just an 'in case it does not work' scenario, if CSF blocks port 
  # 8140, make sure it stays open
  exec { 'csf-open-puppet':
    command => '/sbin/iptables -I OUTPUT -p tcp --dport 8140 -j ACCEPT',
    unless  => '/sbin/iptables -L OUTPUT -n | grep "8140"',
  }

  # Set up a header for /etc/csf/csfpost.sh so people do not make changes to it
  concat::fragment { 'csf-post-header':
    target  => '/etc/csf/csfpost.sh',
    content => template('csf/csf_header.erb'),
    order   => '00',
  }

  # Set up a header for /etc/csf/csfpre.sh so people do not make changes to it
  concat::fragment { 'csf-pre-header':
    target  => '/etc/csf/csfpre.sh',
    content => template('csf/csf_header.erb'),
    order   => '00',
  }

  # Create /etc/csf/csfpost.sh, only when it's installed
  concat { '/etc/csf/csfpost.sh':
    ensure         => present,
    ensure_newline => true,
    mode           => '0700',
    order          => 'numeric',
    require        => Exec['csf-install'],
    notify         => Exec['csf-reload'],
  }

  # Create /etc/csf/csfpre.sh, only when it's installed
  concat { '/etc/csf/csfpre.sh':
    ensure         => present,
    ensure_newline => true,
    mode           => '0700',
    order          => 'numeric',
    require        => Exec['csf-install'],
    notify         => Exec['csf-reload'],
  }

  # Create a set of resources that you can specify in Hiera
  $csf_ipv4_input_ports = hiera('csf::ipv4::input::ports', {})
  $csf_ipv4_output_ports = hiera('csf::ipv4::output::ports', {})
  $csf_allow_hosts = hiera('csf::allow::hosts', {})
  $csf_ignore_hosts = hiera('csf::ignore::hosts', {})
  $csf_deny_hosts = hiera('csf::deny::hosts', {})
  $csf_config_settings = hiera('csf::config::settings', {})
  create_resources(csf::ipv4::input, $csf_ipv4_input_ports)
  create_resources(csf::ipv4::output, $csf_ipv4_output_ports)
  create_resources(csf::allow, $csf_allow_hosts)
  create_resources(csf::ignore, $csf_ignore_hosts)
  create_resources(csf::deny, $csf_deny_hosts)
  create_resources(csf::config, $csf_config_settings)
}
