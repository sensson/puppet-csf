define csf::ignore($ipaddress = $title, $ensure = 'present', $comment = 'puppet') {
	csf::global { "csf-global-ignore-$ipaddress":
		ipaddress	=> $ipaddress,
		ensure		=> $ensure,
		type		=> 'ignore',
		comment		=> $comment,
	}
}