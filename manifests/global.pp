define csf::global($ipaddress = '127.0.0.1', $type = 'ignore', $ensure = 'present', $comment = 'puppet') {
	case $type {
		default: { err ( "unknown value ${type}" ) }
		ignore,
		deny,
		allow: {
			file_line { "csf-$ipaddress-$type": 
				path	=> "/etc/csf/csf.$type",
				line	=> "$ipaddress # $comment - from $title",
				match	=> "$ipaddress.*",
				ensure	=> $ensure,
				require	=> Exec['csf-install'],
				notify	=> Exec['csf-reload'],
			}
		}
	}
}