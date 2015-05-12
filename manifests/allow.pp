# csf::allow
define csf::allow($ipaddress = $title, $ensure = 'present', $comment = 'puppet') {
  csf::global { "csf-global-allow-${ipaddress}":
    ensure    => $ensure,
    ipaddress => $ipaddress,
    type      => 'allow',
    comment   => $comment,
  }
}