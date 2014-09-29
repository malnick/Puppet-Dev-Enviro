# Gitlab provisioning manifest for vagrant
# Downloads gitlab, runs an installer scirpt which has a pre-configed answer file piped to it via here doc

exec {'download_gitlab_installer':
  command => '/usr/bin/wget -O /tmp/gitlab_installer.run https://bitnami.com/redirect/to/34992/bitnami-gitlab-6.8.1-0-linux-x64-installer.run --no-check-certificate',
  creates => '/tmp/gitlab_installer.run',
}

file {'/tmp/gitlab_installer.run':
  ensure => present,
  mode => '0755',
  require => Exec['download_gitlab_installer'],
}

file {'/tmp/install_gitlab.sh':
  ensure => file,
  mode   => '0755',
  source => 'puppet:///modules/gitlab/install_gitlab.sh',
}


exec {'install_gitlab':
  command => '/tmp/install_gitlab.sh',
  require => File['/tmp/install_gitlab.sh','/tmp/gitlab_installer.run'],
}

exec {'stop_iptables':
  command => '/etc/rc.d/init.d/iptables stop',
  require => Exec['install_gitlab'],
}

# Get gitlab cli tools
#package {'gitlab_cli':
#  ensure => present,
#  provider => 'gem',
#}

#file {'/root/.gitlab.yml':
#  ensure => file,
# source => 'puppet:///modules/gitlab/gitlab.yml',
#}

# Huck a repo in there...
#file {'control_repo':
#  ensure => directory,
#  path => '/opt/gitlab-6.7.5-0/apps/gitlab/repositories/user/control_repo.git',
#  recurse => true,
#  source => 'puppet:///modules/gitlab/control_repo.git',
#  require => Exec['install_gitlab'],
#}
#exec {'set_path':
#  command => '/bin/echo "export PATH=$PATH:/path/to/gitlab-cli/repo/bin/" >> /root/.bash_profile',
#}

exec {'start_gitlab':
  command => '/opt/gitlab-6.7.5-0/ctlscript.sh restart',
  require => Exec['stop_iptables'],
}

# SSH Excess Permissions issue on /home/git/.ssh and .ssh/authorizedKeys
file {'/home/git/.ssh':
  ensure => directory,
  mode => '0700',
  owner => 'git',
  group => 'git',
  require => Exec['start_gitlab'],
}

file {'/home/git/.ssh/authorized_keys':
  ensure => file,
  group => 'git',
  owner => 'git',
  mode => '0600',
}


# Configure control repo

# In order to do this SSH auth keys need to be provided:
# id pub from master, owner & group 'git', mode 0600
#file {'/home/git/.ssh/authorized_keys':
#  ensure => file,
#  source => 'puppet:///modules/gitlab/authorized_keys',
#  require => Exec['install_gitlab'],
#}

# Once ssh is setup a repo needs to be added, see above 'huck a repo in there'

# Once complete a r10k sync needs to occur, easiest to prob do a MCO r10k deploy from the gitlab vm
