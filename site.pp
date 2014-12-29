
# setup ntp with defaults
include '::ntp'


# Latest docker
class {'docker':
  manage_kernel => false,
}


# Standard vcs tools
package { 'bzr':
  ensure => 'installed',
}
package { 'git':
  ensure => 'installed',
}
package { 'mercurial':
  ensure => 'installed',
}
package { 'subversion':
  ensure => 'installed',
}


# Editors
package { 'emacs':
  ensure => 'installed',
}

# atom manually

package { 'squidclient':
  ensure => 'installed',
}


# Squid-in-a-can
if hiera('run_squid', false) {
  docker::image {'jpetazzo/squid-in-a-can':
    require => Package['docker'],
  }

  file { '/var/cache/squid-in-a-can' :
    ensure => 'directory',
    mode   => 644,
    owner  => 'proxy',
    group  => 'proxy',
  }

  docker::run {'squid-in-a-can':
    image   => 'jpetazzo/squid-in-a-can',
    command => '/tmp/deploy_squid.py',
    env     => ['DISK_CACHE_SIZE=5000', 'MAX_CACHE_OBJECT=1000'],
    volumes => ['/var/cache/squid-in-a-can:/var/cache/squid3'],
    net     => 'host',
    require => [Docker::Image['jpetazzo/squid-in-a-can'],
                File['/var/cache/squid-in-a-can'],
               ],
  }

  class { 'iptables':
    config => 'file', # This is needed to activate file mode
    source => [ "puppet:///modules/local_config_files/etc/iptables.docker_squid"],
  }
}
else {
  class { 'iptables':
    config => 'file', # This is needed to activate file mode
    source => [ "puppet:///modules/local_config_files/etc/iptables.docker"],
  }

}


if hiera('autoreconfigure') {
  cron {'autoreconfigure':
    environment => ['PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games
  '],
    command => hiera('autoreconfigure::command'),
    user    => root,
    month   => absent,
    monthday => absent,
    hour    => absent,
    minute  => '*/15',
    weekday => absent,
  }
}
else {
  cron {'autoreconfigure':
    ensure => absent,
  }
}
