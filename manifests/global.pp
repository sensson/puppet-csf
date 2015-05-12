# csf::global
define csf::global($ipaddress = '127.0.0.1', $type = 'ignore', $ensure = 'present', $comment = 'puppet') {
  case $type {
    default: { err ( "unknown value ${type}" ) }
    ignore,
    deny,
    allow: {
      file_line { "csf-${ipaddress}-${type}":
        ensure  => $ensure,
        path    => "/etc/csf/csf.${type}",
        line    => "${ipaddress} # ${comment} - from ${title}",
        match   => "${ipaddress}.*",
        require => Exec['csf-install'],
        notify  => Exec['csf-reload'],
      }
    }
  }
}