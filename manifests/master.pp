# Class: mesos::master
#
# This module manages Mesos master - installs Mesos package
# and starts master service.
#
# Sample Usage:
#
# class{ 'mesos::master': }
#
# mesos-master service stores configuration in /etc/default/mesos-master in file/directory
# structure. Arguments passed via $options hash are converted to file/directories
#
class mesos::master(
  $enable         = true,
  $whitelist      = '*',
  $cluster        = 'mesos',
  $conf_dir       = '/etc/mesos-master',
  $work_dir       = '/var/lib/mesos', # registrar directory, since 0.19
  $conf_file      = '/etc/default/mesos-master',
  $master_port    = $mesos::master_port,
  $zookeeper      = $mesos::zookeeper,
  $owner          = $mesos::owner,
  $group          = $mesos::group,
  $listen_address = $mesos::listen_address,
  $options        = {},
) inherits mesos {

  validate_hash($options)

  file { $conf_dir:
    ensure  => directory,
    owner   => $owner,
    group   => $group,
    recurse => true,
    purge   => true,
    force   => true,
  }

  file { $work_dir:
    ensure  => directory,
    owner   => $owner,
    group   => $group,
  }

  create_resources(mesos::property,
    mesos_hash_parser($options),
    { dir => $conf_dir }
  )

  file { $conf_file:
    ensure  => present,
    content => template('mesos/master.erb'),
    owner   => $owner,
    group   => $group,
    mode    => '0644',
    require => [File[$conf_dir], Package['mesos']],
  }

  # Install mesos-master service
  mesos::service { 'master':
    enable     => $enable,
    require    => File[$conf_file],
  }
}
