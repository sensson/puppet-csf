define csf::allow($ipaddress = $title, $ensure = 'present', $comment = 'puppet') {
	csf::global { "csf-global-allow-$ipaddress":
		ipaddress	=> $ipaddress,
		ensure		=> $ensure,
		type		=> 'allow',
		comment		=> $comment,
	}
}