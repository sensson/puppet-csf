define csf::deny($ipaddress = $title, $ensure = 'present', $comment = 'puppet') {
	csf::global { "csf-global-deny-$ipaddress":
		ipaddress	=> $ipaddress,
		ensure		=> $ensure,
		type		=> 'deny',
		comment		=> $comment,
	}
}