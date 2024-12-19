# devops_skills_test_12-19-24

# Skills test #1: Puppet


We use Puppet as our configuration management tool to control the configuration of our internal
and production environment. We use r10k to manage deployment of our configuration code to
our various environments.
Minimal Puppet Skill Test:
Setup two virtual machines with the following characteristics:
1. puppet: Rocky 9, set up as a puppet server using Puppet.
2. agent: Rocky 9, configured as a client of the puppet server.
3. Create a custom module that ensures a user exists on controlled servers, specifying both the
password for that user, and the SSH public key for that user. This will ensure that the user can
use the specified password and SSH key to access both servers. The user should also be in the
wheel group and be able to sudo to root. This module should be used by the puppet server and
applied to both.
Success is achieved by being able to SSH into both servers, and sudo to root with the known
password. The user should have been created by puppet and not by hand on either server.
Variations from the specific steps above which achieve the need to be explained why the
candidate used a different method. Substitution of a different configuration management like say
Ansible won’t suffice because we use Puppet in our environment.


# The approach:
Without some additional context on how to go about implementing the servers and where (or if I should set up the VMs myself), I will include the bash / shell commands that will go along with each step. I can incorporate these steps into a demonstrable solution where each instance can be accessed if such is required. But I wasnt sure if I should implement this without knowing how it should be deployed. 


## 1 : To set up a puppet server:
``` 
sudo dnf update -y 
sudo dnf install -y https://yum.puppet.com/puppet7-release-el-9.noarch.rpm                     # To pull the latest image from a image repo 
sudo dnf install -y puppetserver
sudo systemctl enable --now puppetserver
sudo hostnamectl set-hostname puppet.example.com
sudo nano /etc/puppetlabs/puppet/puppet.conf

## Edit within: ##
[main]
dns_alt_names = puppet,puppet.example.com        # edit to match specs 

sudo systemctl restart puppetserver 

```


## 2 : To set up client 
```
sudo dnf install -y https://yum.puppet.com/puppet7-release-el-9.noarch.rpm
sudo dnf install -y puppet-agent     #Package necessary to be set up as agent
sudo hostnamectl set-hostname agent.example.com

## Modify /etc/puppetlabs/puppet/puppet.conf ##
[main]
server = puppet.example.com

sudo systemctl enable --now puppet # Starting and enabling the puppet agent 
sudo puppetserver ca list
sudo puppetserver ca sign --certname agent.example.com

```

## 3 : Create a custom module 
```
- Edit manifests/init.pp


class create_user {
  user { 'testuser':
    ensure     => 'present',
    managehome => true,
    home       => '/home/testuser',
    shell      => '/bin/bash',
    password   => '<hashed_password>',
  }

  ssh_authorized_key { 'testuser_ssh_key':
    ensure  => 'present',
    user    => 'testuser',
    type    => 'ssh-rsa',
    key     => '<your_ssh_public_key>',
  }

  exec { 'add_to_wheel':
    command => '/usr/sbin/usermod -aG wheel testuser',
    unless  => 'groups testuser | grep -q wheel',
  }
}


- Deploy module at: 

/etc/puppetlabs/code/environments/production/modules/

- Apply the module to both nodes

node 'agent.example.com' {
  include create_user
}

- Trigger a run: 
puppet agent -t


```


## Verification
```
- To ssh into testuser: 
ssh testuser@agent.example.com


- test sudo for testuser: 
sudo -i 

```