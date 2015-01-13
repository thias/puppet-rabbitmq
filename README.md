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
rabbitmqctl(1) for more information.

