# csf::docker
class csf::docker inherits csf {
  file { '/etc/csf/docker.sh':
    ensure  => $::csf::docker,
    mode    => '0755',
    content => template('csf/csf_docker.sh'),
  }

  if $::csf::docker == 'present' {
    csf::rule { 'csf-rule-docker':
      content => 'source /etc/csf/docker.sh',
      order   => 1,
    }
  }
}
