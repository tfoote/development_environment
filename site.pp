# Basic ROS configuration

include ros

# setup ntp with defaults
include '::ntp'

# to configure upstart scripts
include upstart

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

# qemu to support docker armhf
package { 'qemu-user-static':
  ensure => 'installed',
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

package { 'python-vcstool':
  ensure  => 'installed',
  require => Class['ros'],
}

package { 'python-wstool':
  ensure  => 'installed',
  require => Class['ros'],
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


class tully_linter_requirements {

  # atom manually

  #rst renderer needed for atom-rst-preview
  package { 'clang':
    ensure => 'installed',
  }

  #rst renderer needed for atom-rst-preview
  package { 'pandoc':
    ensure => 'installed',
  }

  package { 'pylint':
    ensure => 'installed',
  }

  package { 'puppet-lint':
    ensure => 'installed',
  }

}

include tully_linter_requirements

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

package { 'ccache':
  ensure => 'installed',
}

package { 'rake':
  ensure => 'installed',
}

package { 'ruby-puppetlabs-spec-helper':
  ensure => 'installed',
}

# image processing
package { 'gimp':
  ensure => 'installed',
}

# image processing
package { 'imagemagick':
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

## SSH server

package { 'openssh-server':
  ensure => 'installed',
}

package { 'openvpn':
  ensure => 'installed',
}

# Sysadmin tools:

package { 'clusterssh':
  ensure => 'installed',
}

package { 'gparted':
  ensure => 'installed',
}

package { 'sysstat':
  ensure => 'installed',
}

package { 'iftop':
  ensure => 'installed',
}

package { 'nethogs':
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

# OSRF Repos
apt::source { 'gazebo-ppa':
  location   => 'http://packages.osrfoundation.org/gazebo/ubuntu',
  #release   => 'stable',
  repos      => 'main',
  key        => '9443F10F',
  key_source    => 'http://packages.osrfoundation.org/gazebo.key',
  include_src => false,
}

package { 'libopensplice63':
  ensure => 'installed',
  require => Apt::Source['gazebo-ppa'],
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
    env     => ['DISK_CACHE_SIZE=5000', 'MAX_CACHE_OBJECT=1000', 'SQUID_DIRECTIVES=\'
refresh_pattern . 0 0 1 refresh-ims
refresh_all_ims on # make sure we do not get out of date content
ignore_expect_100 on # needed for new relic system monitor
\''],
    volumes => ['/var/cache/squid-in-a-can:/var/cache/squid3'],
    net     => 'host',
    require => [Docker::Image['jpetazzo/squid-in-a-can'],
                File['/var/cache/squid-in-a-can'],
               ],
  }

  package { 'squidclient':
    ensure => 'installed',
  }

  file { '/root/manage.py':
    ensure => present,
    source => 'puppet:///modules/local_config_files/root/manage.py',
    mode => 755,
  }

  upstart::job{'manage-tproxy':
    description => 'Manage iptables for tproxy',
    chdir => '/root',
    exec  => '/root/manage.py',
    require => File['/root/manage.py'],
    respawn     => true,
    respawn_limit => '99 5',
  }
}
else {


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
