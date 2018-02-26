# csf::ipv4::output
define csf::ipv4::output($port = $title, $proto = 'tcp') {
  $iptables = 'iptables'
  $chain = 'OUTPUT'
  csf::rule { "csf-ip4-${proto}-${chain}-${port}":
    content => template('csf/csf_rule.erb'),
  }
}
