# Mesos Puppet Module
[![Build Status](https://travis-ci.org/deric/puppet-mesos.png)](https://travis-ci.org/deric/puppet-mesos)

This is a Puppet module for managing Mesos nodes in a cluster.

## Requirements

  * Puppet 3 (or 2.6 with hiera gem)
  * Mesos binary package
    * Debian/Ubuntu
      * [mesos deb packaging](https://github.com/deric/mesos-deb-packaging)
      * [mesosphere packages](http://mesosphere.io/downloads/)
    * RedHat/CentOS
      * [mesosphere packages](http://mesosphere.io/downloads/)

## Usage

Parameters:

 - `zookeeper` - ZooKeeper URL which is used for slaves connecting to the master and also for leader election, e.g.:
	- single ZooKeeper: `zk://127.0.0.1:2181/mesos` (which isn't fault tolerant)
        - multiple ZooKeepers: `zk://192.168.1.1:2181,192.168.1.2:2181,192.168.1.3:2181/mesos` (usually 3 or 5 ZooKeepers should be enough)
        - ZooKeeper URL will be stored in `/etc/mesos/zk`
 - `conf_dir` - directory with simple configuration files containing master/slave parameters (name of the file is a key, contents its value)
        - this directory will be completely managed by Puppet

### Master

  Should be as simple as this, on master node:

  ```puppet
class{'mesos::master': }
```
optionally you can specify some parameters or it is possible to configure Mesos via Hiera (see below).

```puppet
class{'mesos::master':
  master_port => 5050,
  work_dir => '/var/lib/mesos',
  options => {
    quorum   => 4
  }
}
```

  For slave you have to specify either `master`

```puppet
class{'mesos::slave':
  master => '192.168.1.1'
}
```
or `zookeeper` node(s) to connect:
```puppet
class{'mesos::slave':
  zookeeper => 'zk://192.168.1.1:2181,192.168.1.2:2181,192.168.1.3:2181/mesos'
}
```
 - `conf_dir` default value is `/etc/mesos-master` (this directory will be purged by Puppet!)
 	- for list of supported options see `mesos-master --help`

### Slave

 - `enable` - install Mesos slave service (default: `true`)
 - `port` - slave's port for incoming connections (default: `5051`)
 - `master`- ip address of Mesos master (default: `localhost`)
 - `master_port` - Mesos master's port (default: `5050`)
 - `work_dir` - directory for storing task's temporary files (default: `/tmp/mesos`)
 - `env_var` - slave's execution environment variables - a Hash, if you are using
 Java, you might need e.g.:

```puppet
class{'mesos::slave':
  master  => '192.168.1.1',
  env_var => {
    'JAVA_HOME' => '/usr/bin/java'
  }
}
```

in a similar manner you can specify cgroups isolation:

```puppet
class{'mesos::slave':
  zookeeper  => 'zk://192.168.1.1:2181/mesos',
  isolation  => 'cgroups',
  cgroups    => {
    'hierarchy' => '/sys/fs/cgroup',
    'root'      => 'mesos',
  }
}
```
 - `conf_dir` default value is `/etc/mesos-slave` (this directory will be purged by Puppet!)
        - for list of supported options see `mesos-slave --help`

## File based configuration

If some file based configurations this module doesn't provide directly in master and slave module, `mesos::property` allows to configure them or remove the file when `value` is left empty. e.g. configure value in `/etc/mesos/hostname`:

```puppet
::mesos::property { 'hostname':
  value => 'mesos.hostname.com',
  dir   => '/etc/mesos'
}
```

Remove this file simply set value to undef:

```puppet
::mesos::property { 'hostname':
  value => undef,
  dir   => '/etc/mesos'
}
```


## Hiera support

  All configuration could be handled by hiera.

  Either specify one master

```yaml
mesos::master      : '192.168.1.1'
```

  or [Zookeeper](http://zookeeper.apache.org/) could be use for a fault-tolerant setup (multiple instances of zookeeper are separated by comma):

```yaml
mesos::zookeeper   : 'zk://192.168.1.1:2181/mesos'
```

Some parameters are shared between master and slave nodes:

```yaml
mesos::master_port : 5050
mesos::log_dir     : '/var/log/mesos'
mesos::conf_dir    : '/etc/mesos'
mesos::owner       : 'mesos'
mesos::group       : 'mesos'
```

Other are master specific:

```yaml
mesos::master::cluster     : 'my_mesos_cluster'
mesos::master::whitelist   : '*'
```

or slave specific:

```yaml
mesos:slave::env_var:
  JAVA_HOME: '/usr/bin/java'
```

Mesos service reads configuration either from ENV variables or from configuration files wich are stored in `/etc/mesos-slave` resp. `/etc/mesos-master`. Hash passed via `options` will be converted to config files. Most of the options is possible to configure this way:

```yaml
mesos::master::options:
  webui_dir: '/usr/local/share/mesos/webui'
  quorum: '4'
```

you can also use facts from Puppet:

```
mesos::master::options:
  hostname: "%{::fqdn}"
```


cgroups with Hiera:

```puppet
mesos::slave::isolation: 'cgroups'
mesos::slave::cgroups:
  hierarchy: '/sys/fs/cgroup'
```

Limit resources used by Mesos slave:

```puppet
mesos::slave::resources:
  cpus: '10'
```

## Links

For more information see [Mesos project](http://mesos.apache.org/)

## License

Apache License 2.0
