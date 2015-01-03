
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

package { 'qgit':
  ensure => 'installed',
}

package { 'meld':
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


# gpg things
package { 'dconf-editor':
  ensure => 'installed',
}

# Python Tools
package { 'ipython':
  ensure => 'installed',
}

package { 'pep8':
  ensure => 'installed',
}

package { 'python3-pep8':
  ensure => 'installed',
}

package { 'python-flake8':
  ensure => 'installed',
}

package { 'python3-flake8':
  ensure => 'installed',
}

# Sysadmin tools:

package { 'sysstat':
  ensure => 'installed',
}

package { 'vnstat':
  ensure => 'installed',
}

## Video processing tools

package { 'mencoder':
  ensure => 'installed',
}

package { 'kdenlive':
  ensure => 'installed',
}

package { 'vlc':
  ensure => 'installed',
}


# Needed for rosdistro tests

package { 'python-pip':
  ensure => 'installed',
}

pip::install { 'unidiff':
  python_version => '2',    # defaults to 2.7
  require => Package['python-pip'],
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
  package { 'squidclient':
    ensure => 'installed',
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
