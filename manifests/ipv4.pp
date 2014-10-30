define csf::ipv4::input($port = $title, $proto = 'tcp') {
	$chain = 'INPUT'
	csf::rule { "csf-$proto-$chain-$port":
		content	=> template('csf/csf_rule.rb'),
	}
}

define csf::ipv4::output($port = $title, $proto = 'tcp') {
	$chain = 'OUTPUT'
	csf::rule { "csf-$proto-$chain-$port":
		content	=> template('csf/csf_rule.rb'),
	}
}