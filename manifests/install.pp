# csf::install
class csf::install inherits csf {
  # this installs csf and reloads it

  $required_packages = lookup('csf::packages::required', Array[String])

  ensure_packages ($required_packages, {
    ensure => 'present',
    before => Exec['csf-install'],
  })

  if $::csf::install_recommended_packages {
    $recommended_packages = lookup('csf::packages::recommended', Array[String])

    ensure_packages ($recommended_packages, {
      ensure => 'present',
      before => Exec['csf-install'],
    })
  }

  exec { 'csf-install':
    cwd     => '/tmp',
    command => "/usr/bin/curl -o csf.tgz ${::csf::download_location} && tar -xzf csf.tgz && cd csf && sh install.sh",
    creates => '/usr/sbin/csf',
    notify  => Service['csf'],
    require => Package['perl'],
  }

  # make sure testing is disabled, we trust puppet enough
  csf::config { 'TESTING': value => '0' }

  # make sure puppet masters are always accessible
  csf::ipv4::output { '8140': require => Exec['csf-install'], }
}
