# csf::ipv4::input
define csf::ipv4::input($port = $title, $proto = 'tcp') {
  $iptables = 'iptables'
  $chain = 'INPUT'
  csf::rule { "csf-ip4-${proto}-${chain}-${port}":
    content => template('csf/csf_rule.erb'),
  }
}
