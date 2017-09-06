# csf
class csf::params {
  $download_location = 'https://download.configserver.com/csf.tgz'
  $docker = absent
  $service_ensure = 'running'
  $service_enable = true
}
