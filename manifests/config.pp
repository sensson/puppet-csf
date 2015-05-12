# csf::config
class csf::config {
  if $::csf::manage_config == true {
    file { '/etc/csf/csf.conf':
      owner   => root,
      group   => root,
      mode    => '0600',
      content => template('csf/csf.conf.rb'),
      require => Exec['csf-install'],
      notify  => Exec['csf-reload'],
    }
  }
}