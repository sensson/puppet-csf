# This is a global CSF function which we use to define CSF rules
define csf::rule($content = '', $source = '', $order = '99', $target = '/etc/csf/csfpost.sh') {
	concat::fragment { $title:
		target	=> $target,
		content => $content,
		order	=> $order,
	}
}