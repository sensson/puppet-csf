# csf::ipv4::input
define csf::ipv6::input($port = $title, $proto = 'tcp') {
  $iptables = 'ip6tables'
  $chain = 'INPUT'
  csf::rule { "csf-ip6-${proto}-${chain}-${port}":
    content => template('csf/csf_rule.erb'),
  }
}
