# csf::deny
define csf::deny($ipaddress = $title, $ensure = 'present', $comment = 'puppet') {
  csf::global { "csf-global-deny-${ipaddress}":
    ensure    => $ensure,
    ipaddress => $ipaddress,
    type      => 'deny',
    comment   => $comment,
  }
}