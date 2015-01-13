class rabbitmq (
  $selinux          = true,
  $rabbitmq_package = $::rabbitmq::params::rabbitmq_package,
  $rabbitmq_service = $::rabbitmq::params::rabbitmq_service,
) inherits ::rabbitmq::params {

  package { $rabbitmq_package: ensure => 'installed' }

  service { $rabbitmq_service:
    ensure  => 'running',
    enable  => true,
    require => Package[$rabbitmq_package],
  }

  # SELinux - 3.3.5 on RHEL 7.0 fails to start as of 201501
  # https://bugzilla.redhat.com/show_bug.cgi?id=1135523
  $node_selinux = str2bool($::selinux)
  if $selinux == true and $node_selinux == true {
    # This requires the optional 'thias-selinux' for semanage presence
    include '::selinux'
    # Management port
    exec { 'semanage port -a -t amqp_port_t -p tcp 15672':
      unless  => "semanage port -l -C | egrep '^amqp_port_t[[:space:]]+tcp.+15672'",
      path    => [ '/bin', '/usr/bin', '/sbin', '/usr/sbin' ],
      require => Package[$::selinux::package_audit2allow],
      before  => Service[$rabbitmq_service],
    }
    # Cluster port
    exec { 'semanage port -a -t amqp_port_t -p tcp 25672':
      unless  => "semanage port -l -C | egrep '^amqp_port_t[[:space:]]+tcp.+25672'",
      path    => [ '/bin', '/usr/bin', '/sbin', '/usr/sbin' ],
      require => Package[$::selinux::package_audit2allow],
      before  => Service[$rabbitmq_service],
    }
  }

}

