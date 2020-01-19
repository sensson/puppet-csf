# csf::ignore
define csf::pignore($program = $title, $ensure = 'present', $comment = '') {
  csf::global { "csf-global-pignore-${program}":
    ensure    => $ensure,
    ipaddress => $program,
    type      => 'pignore',
    comment   => $comment,
  }
}
