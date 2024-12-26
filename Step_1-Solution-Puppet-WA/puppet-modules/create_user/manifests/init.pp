class create_user {
  user { 'devuser':
    ensure     => 'present',
    managehome => true,
    home       => '/home/devuser',
    shell      => '/bin/bash',
    password   => 'REMOVED_AFTER_DEMO',
  }

  ssh_authorized_key { 'devuser_ssh_key':
    ensure  => 'present',
    user    => 'devuser',
    type    => 'ssh-rsa',
    key     => 'REMOVED_AFTER_DEMO',
  }

  exec { 'add_to_wheel':
    command => '/usr/sbin/usermod -aG wheel devuser',
    unless  => '/usr/bin/groups devuser | /bin/grep -q wheel',
  }
}
