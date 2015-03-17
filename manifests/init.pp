# Main class
class rabbitmq (
  $selinux                 = true,
  $rabbitmq_package        = $::rabbitmq::params::rabbitmq_package,
  $rabbitmq_service        = $::rabbitmq::params::rabbitmq_service,
  $rabbitmq_config_source  = undef,
  $rabbitmq_config_content = undef,
  $rabbitmq_env            = {},
  $enabled_plugins         = [],
) inherits ::rabbitmq::params { # lint:ignore:class_inherits_from_params_class

  package { $rabbitmq_package: ensure => 'installed' }

  service { $rabbitmq_service:
    ensure  => 'running',
    enable  => true,
    require => Package[$rabbitmq_package],
  }

  # Optional configuration files
  if $rabbitmq_config_source or $rabbitmq_config_content {
    file{ '/etc/rabbitmq/rabbitmq.config':
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      source  => $rabbitmq_config_source,
      content => $rabbitmq_config_content,
      require => Package[$rabbitmq_package],
      notify  => Service[$rabbitmq_service],
    }
  }
  if $rabbitmq_env != {} {
    file{ '/etc/rabbitmq/rabbitmq-env.conf':
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => template("${module_name}/rabbitmq-env.conf.erb"),
      require => Package[$rabbitmq_package],
      notify  => Service[$rabbitmq_service],
    }
  }
  if $enabled_plugins != [] {
    file{ '/etc/rabbitmq/enabled_plugins':
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => template("${module_name}/enabled_plugins.erb"),
      require => Package[$rabbitmq_package],
      notify  => Service[$rabbitmq_service],
    }
  }

  # SELinux - 3.3.5 on RHEL 7.0 fails to start as of 201501
  # https://bugzilla.redhat.com/show_bug.cgi?id=1135523
  $node_selinux = str2bool($::selinux)
  if $selinux == true and $node_selinux == true {
    # This requires the optional 'thias-selinux' for semanage presence
    # lint:ignore:80chars lint:ignore:double_quoted_strings More readable
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
    # lint:endignore
  }

}

