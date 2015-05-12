# csf::ipv4::input
define csf::ipv4::input($port = $title, $proto = 'tcp') {
  $chain = 'INPUT'
  csf::rule { "csf-${proto}-${chain}-${port}":
    content => template('csf/csf_rule.rb'),
  }
}
