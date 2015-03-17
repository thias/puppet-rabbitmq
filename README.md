# puppet-rabbitmq

## Overview

Install and enable RabbitMQ.

* `rabbitmq` : Class to install and enable the server.

If you are looking for a more complete module, check out the official
PuppetLabs RabbitMQ module. This module is made to be minimalistic, with few
external requirements : stdlib, selinux (optional), nothing more.

It has been initially tested only with Red Hat Enterprise Linux 7.

## Examples

```puppet
include '::rabbitmq'
```

Once the RabbitMQ server is up and running, it initially needs to be manually
configured. This is where other modules might go beyond this basic one. See
`rabbitmqctl(1)` for more information.

If you already have an existing configuration, you should be able to pass it
as-is using `source` or `content` type parameters, with your own files or
templates (here we use an included example cluster template ) :

```puppet
$cluster_nodes = [ 'rabbit@node1', 'rabbit@node2' ]
class { '::rabbitmq':
  rabbitmq_config_content => template('rabbitmq/rabbitmq.config-cluster.erb'),
  rabbitmq_env            => {
    'NODENAME'     => "rabbit@${::hostname}.example.lan",
    'USE_LONGNAME' => 'true',
  },
  enabled_plugins         => [ 'rabbitmq_management' ],
}
```

