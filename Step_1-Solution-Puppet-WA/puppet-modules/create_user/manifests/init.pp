class create_user {
  user { 'devuser':
    ensure     => 'present',
    managehome => true,
    home       => '/home/devuser',
    shell      => '/bin/bash',
    password   => '$6$7lg3sQKvzhMik6Ay$hMreupNLMd2QeNYhddxQbpsgGEWrXRb6nbEFZhxZPz.pPrcVc2Gksk6SEdHek0WVsB4SxLUY0eNeDNdD7Gwil/',
  }

  ssh_authorized_key { 'devuser_ssh_key':
    ensure  => 'present',
    user    => 'devuser',
    type    => 'ssh-rsa',
    key     => 'AAAAB3NzaC1yc2EAAAADAQABAAACAQCYihN5bJMiyA3O+g0lD6qs4CCWtuew2QUAkaMB0cKYntPXbUoKj+lGbPf+Gag6M3bO4e4ldDQvf2Hb8uFvTn9mWhQnQtGeRSb1I5iZjmBi2kPQ/RtEq/qlV3qFEECeWL32XGKzd7NEe7HYgXo768naOXvEUQNkMsBSJEjgqsTuKRynDtzOqZ0xvqwnKiPyXJI05/eZjK6mhjgbVZnqVhsIzbumFYRNlEjRXf4ZeL2wlGE0AG+bj2oRZ/9CqIJUA6EdlZnhSIupH6w5hBVtfgOUk2bFTLGfyG01n7OK6R3aFgZwwMgnj+1po+a1sRr+BzziO/MIWfK6sBMhYwH9ds19aDl9C+FWv/gR0g4XbEzVoDYr5inYXOPmf3RgXKe+p3EAnUm3PgECKSoinuLnZZtx/OcFC1kLWG7qufZMtUOpFNWQ+NVihLE5HQP/2uwBMb+q23hVxlhPeCP/PLJGk/tG0XZhzJtG1Ec1Y5UG+PiOAb3IVixygRSfZx7SsBl5JiNbkWwGgA6KWvy+PXN+DwWmRxAyAK7abKep5f02JLSmfw5orTU58pF+JfnyYZnFxC3TRvMwtpmSkK5osBmZrFg8ZO06kyxvRGbQ985Em3bu3p7FPOGopEEQSO7yxZuAeH35KajQu67IT5cqbORwxuPHz868MLaRmNz2t+13zXEHZQ==rsa-key-20241223',
  }

  exec { 'add_to_wheel':
    command => '/usr/sbin/usermod -aG wheel devuser',
    unless  => '/usr/bin/groups devuser | /bin/grep -q wheel',
  }
}
