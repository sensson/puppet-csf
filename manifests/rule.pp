# csf::rule
define csf::rule($content = '', $source = '', $order = '99', $target = '/etc/csf/csfpost.sh') {
  concat::fragment { $title:
    target  => $target,
    content => $content,
    order   => $order,
  }
}