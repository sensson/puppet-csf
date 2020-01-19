# csf::global
define csf::global($ipaddress = '127.0.0.1', $type = 'ignore', $ensure = 'present', $comment = 'puppet') {
  $resolved_comment = $comment ? {
    '' => '',
    default => "# ${comment} - from ${title}",
  }
  case $type {
    default: { fail( "unknown value ${type}" ) }
    'ignore',
    'pignore',
    'deny',
    'allow': {
      file_line { "csf-${ipaddress}-${type}":
        ensure  => $ensure,
        path    => "/etc/csf/csf.${type}",
        line    => "${ipaddress} ${resolved_comment}",
        match   => "${ipaddress}.*",
        require => Exec['csf-install'],
        notify  => Service['csf'],
      }
    }
  }
}
