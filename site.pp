
# setup ntp with defaults
include '::ntp'


# Latest docker
class {'docker':
  # skydock/skydns support
  extra_parameters => '--bip=172.17.42.1/16',
  dns => ['172.17.42.1', '8.8.8.8', '8.8.4.4'],
  dns_search => ['dev.docker'],
  manage_kernel => false,
}

pip::install { 'fig':
  python_version => '2',    # defaults to 2.7
  require => Package['python-pip'],
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

package { 'byobu':
  ensure => 'installed',
}

package { 'pdftk':
ensure => 'installed',
}

# atom manually

#rst renderer needed for atom-rst-preview
package { 'pandoc':
  ensure => 'installed',
}

# android studio

package { 'default-jdk':
  ensure => 'installed',
} ->
class { 'android': }
android::build_tools { 'build-tools-19.0.1': }
android::platform { 'android-3': }

package { 'ant':
  ensure => 'installed',
}

# autoconf automake etc
package { 'autoconf':
  ensure => 'installed',
}
package { 'automake':
  ensure => 'installed',
}

# image processing
package { 'gimp':
  ensure => 'installed',
}

#gitbook
package { 'nodejs':
  ensure => 'installed',
}

package { 'npm':
  ensure => 'installed',
}

# TODO gitbook npm module


# steam
package { 'steam':
  ensure => 'installed',
}


# Wine
package { 'wine':
  ensure => 'installed',
}

package { 'winetricks':
  ensure => 'installed',
}

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

package { 'clusterssh':
  ensure => 'installed',
}

package { 'sysstat':
  ensure => 'installed',
}

package { 'vnstat':
  ensure => 'installed',
}

package { 'nmap':
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

# latex tools
package { 'texlive-latex-extra':
  ensure => 'installed',
}

# latex tools
package { 'texlive-fonts-recommended':
  ensure => 'installed',
}

package { 'latex-beamer':
  ensure => 'installed',
}



# Needed for rosdistro tests

## declared below in ros_release_python section
#package { 'python-pip':
#  ensure => 'installed',
#}

pip::install { 'unidiff':
  python_version => '2',    # defaults to 2.7
  require => Package['python-pip'],
}

# buildfarm deployment

package { 'curl':
  ensure => 'installed',
}

## declared below in ros_release_python section
#package { 'python3-pip':
#  ensure => 'installed',
#}
## declared below in ros_release_python section
#package { 'python3-all':
#  ensure => 'installed',
#}


# ifc6410
package { 'android-tools-fastboot':
  ensure => 'installed',
}

# android
package { 'android-tools-adb':
  ensure => 'installed',
}


# Pandora

apt::source { 'pithos-ppa':
  location   => 'http://ppa.launchpad.net/pithos/ppa/ubuntu',
  #release    => 'stable',
  repos      => 'main',
  key        => '5C8B1281',
  #include_src => false,
}

package { 'pithos':
  ensure => 'installed',
  require => Apt::Source['pithos-ppa'],
}



# Google Chrome
apt::source { 'google-chrome-stable':
  location   => 'http://dl.google.com/linux/chrome/deb/',
  release    => 'stable',
  repos      => 'main',
  key        => '7FAC5991',
  include_src => false,
}
package { 'google-chrome-stable':
  ensure => 'installed',
  require => Apt::Source ['google-chrome-stable'],
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


# Basic ROS configuration
# TODO better parameterization
# potential parameters:
#  testing vs main
#  python3


apt::source { 'ros-latest':
  location   => 'http://packages.ros.org/ros/ubuntu',
  #release    => 'stable',
  repos      => 'main',
  key        => 'B01FA116',
  key_source => 'https://raw.githubusercontent.com/ros/rosdistro/master/ros.key',
}

package { 'ros-indigo-ros-base':
  ensure => 'installed',
  require => Apt::Source ['ros-latest'],
}

package { 'python-rosdep':
  ensure => 'installed',
  require => Apt::Source ['ros-latest'],
}

package { 'python-rosinstall':
  ensure => 'installed',
  require => Apt::Source ['ros-latest'],
}

package { 'python-rosdistro':
  ensure => 'latest',
  require => Apt::Source ['ros-latest'],
}

exec {'rosdep-init':
  command    => '/usr/bin/rosdep init',
  user       => 'root',
  creates    => '/etc/ros/rosdep/sources.list.d/20-default.list',
  require    => Package['python-rosdep'],
}


## ros_release_python

package { 'dput':
  ensure => 'latest',
}

package { 'apt-file':
  ensure => 'latest',
}

package { 'python-setuptools':
  ensure => 'latest',
}

package { 'python3-setuptools':
  ensure => 'latest',
}

package { 'python-all':
  ensure => 'latest',
}

package { 'python3-all':
  ensure => 'latest',
}

package { 'python-pip':
  ensure => 'latest',
}

package { 'python3-pip':
  ensure => 'latest',
}

## TODO
# apt-file update
# install stdeb from git branch
