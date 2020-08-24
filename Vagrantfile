# -*- mode: ruby -*-
# vi: set ft=ruby :

domain = "testlab"

hosts = {
  puppet_server: {
    hostname: "puppet-server",
    ipv4_address: "192.168.50.10",
  },
  centos_agent: {
    hostname: "centos-agent",
    ipv4_address: "192.168.50.11",
  },
  ubuntu_agent: {
    hostname: "ubuntu-agent",
    ipv4_address: "192.168.50.12",
  }
}

$hosts = <<~"SCRIPT"
sudo tee -a /etc/hosts > /dev/null << "EOF"
#{hosts[:puppet_server][:ipv4_address]} puppet puppet.#{domain}
#{hosts[:centos_agent][:ipv4_address]} #{hosts[:centos_agent][:hostname]} #{hosts[:centos_agent][:hostname]}.#{domain}
#{hosts[:ubuntu_agent][:ipv4_address]} #{hosts[:ubuntu_agent][:hostname]} #{hosts[:ubuntu_agent][:hostname]}.#{domain}
EOF
SCRIPT

$hostname = <<~"SCRIPT"
sudo /bin/hostname -F /etc/hostname
SCRIPT


Vagrant.configure("2") do |config|

  config.vm.define "puppet-server" do |node|

    hostname = hosts[:puppet_server][:hostname]

    node.vm.box = "roboxes/centos7"
    node.vm.network :private_network, ip: "#{hosts[:puppet_server][:ipv4_address]}"
    node.vm.provision "shell", path: "puppet-bootstrap.sh" 
    node.vm.provision "shell", inline: $hosts
    node.vm.provision "shell", inline: "echo #{hostname} | sudo tee /etc/hostname;"
    node.vm.provision "shell", inline: $hostname

    node.vm.provision "shell", inline: "echo *.#{domain} | sudo tee /etc/puppetlabs/puppet/autosign.conf;"

    node.vm.provision "shell", inline: "sudo systemctl restart puppetserver"
    node.vm.provision "shell", inline: "sudo systemctl enable puppetserver"

  end

  config.vm.define "centos-agent" do |node|

    node.vm.box = "roboxes/centos7"
    node.vm.network :private_network, ip: "#{hosts[:centos_agent][:ipv4_address]}"
    node.vm.provision "shell", path: "puppet-bootstrap.sh" 
    node.vm.provision "shell", inline: $hosts
    node.vm.provision "shell", inline: "echo #{hosts[:centos_agent][:hostname]} | sudo tee /etc/hostname;"
    node.vm.provision "shell", inline: $hostname
  end

  config.vm.define "ubuntu-agent" do |node|

    node.vm.box = "roboxes/ubuntu1804"
    node.vm.network :private_network, ip: "#{hosts[:ubuntu_agent][:ipv4_address]}"
    node.vm.provision "shell", path: "puppet-bootstrap.sh"
    node.vm.provision "shell", inline: $hosts
    node.vm.provision "shell", inline: "echo #{hosts[:ubuntu_agent][:hostname]} | sudo tee /etc/hostname;"
    node.vm.provision "shell", inline: $hostname
  end

end
