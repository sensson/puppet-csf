# csf::config
define csf::config($ensure = 'present', $value = '') {
  if $value == '' { fail("Please set a value for ${title}") }

  file_line { "csf-config-set-${title}":
    ensure  => $ensure,
    path    => '/etc/csf/csf.conf',
    line    => "${title} = \"${value}\"",
    match   => "^${title} =",
    require => Exec['csf-install'],
    notify  => Service['csf'],
  }
}
