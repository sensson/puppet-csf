# csf::docker
class csf::docker inherits csf {
  file { '/etc/csf/docker.sh':
    ensure  => $::csf::docker,
    mode    => '0755',
    content => template('csf/post-docker/docker.sh'),
  }

  if $::csf::docker == 'present' {
    csf::rule { 'csf-rule-docker':
      content => '. /etc/csf/docker.sh',
      order   => 1,
    }
  }
}
