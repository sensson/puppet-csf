# csf::ipv4::output
define csf::ipv4::output($port = $title, $proto = 'tcp') {
  $chain = 'OUTPUT'
  csf::rule { "csf-${proto}-${chain}-${port}":
    content => template('csf/csf_rule.rb'),
  }
}
