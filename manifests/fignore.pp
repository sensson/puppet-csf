# csf::fignore
define csf::fignore($program = $title, $ensure = 'present', $comment = '') {
  csf::global { "csf-global-fignore-${program}":
    ensure    => $ensure,
    ipaddress => $program,
    type      => 'fignore',
    comment   => $comment,
  }
}
