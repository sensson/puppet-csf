# csf::ignore
define csf::ignore($ipaddress = $title, $ensure = 'present', $comment = 'puppet') {
  csf::global { "csf-global-ignore-${ipaddress}":
    ensure    => $ensure,
    ipaddress => $ipaddress,
    type      => 'ignore',
    comment   => $comment,
  }
}