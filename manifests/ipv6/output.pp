# csf::ipv4::output
define csf::ipv6::output($port = $title, $proto = 'tcp') {
  $iptables = 'ip6tables'
  $chain = 'OUTPUT'
  csf::rule { "csf-ip6-${proto}-${chain}-${port}":
    content => template('csf/csf_rule.erb'),
  }
}
