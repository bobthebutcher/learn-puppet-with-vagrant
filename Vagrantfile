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
#{hosts[:puppet_server][:ipv4_address]} #{hosts[:puppet_server][:hostname]}.#{domain} #{hosts[:puppet_server][:hostname]} puppet
#{hosts[:centos_agent][:ipv4_address]} #{hosts[:centos_agent][:hostname]}.#{domain} #{hosts[:centos_agent][:hostname]}
#{hosts[:ubuntu_agent][:ipv4_address]} #{hosts[:ubuntu_agent][:hostname]}.#{domain} #{hosts[:ubuntu_agent][:hostname]}
EOF
SCRIPT

$hostname = <<~"SCRIPT"
echo $1 | sudo tee /etc/hostname;
sudo /bin/hostname -F /etc/hostname;
SCRIPT

$puppet_server_install = <<~"SCRIPT"
sudo yum install -y puppetserver;
sudo systemctl start puppetserver.service;
sudo systemctl enable puppetserver.service;
SCRIPT

$puppet_server_config = <<~"SCRIPT"
sudo /opt/puppetlabs/bin/puppet config set server #{hosts[:puppet_server][:hostname]}.#{domain} --section main;
sudo /opt/puppetlabs/bin/puppet config set certname #{hosts[:puppet_server][:hostname]}.#{domain} --section main;
echo *.#{domain} | sudo tee /etc/puppetlabs/puppet/autosign.conf;
SCRIPT

$puppet_server_restart = <<~"SCRIPT"
sudo systemctl restart puppetserver.service;
SCRIPT

$puppet_agent_config = <<~"SCRIPT"
sudo /opt/puppetlabs/bin/puppet config set server #{hosts[:puppet_server][:hostname]}.#{domain} --section main;
sudo /opt/puppetlabs/bin/puppet config set certname $1.#{domain} --section main;
SCRIPT

$puppet_server_firewall = <<~"SCRIPT"
sudo firewall-cmd --add-port=8140/tcp --permanent;
sudo firewall-cmd --reload;
SCRIPT

$puppet_server_ready_check = <<~"SCRIPT"
timeout 600 bash -c 'until printf "" 2>>/dev/null >>/dev/tcp/$0/$1; do sleep 1; done' #{hosts[:puppet_server][:hostname]}.#{domain} 8140;
SCRIPT

$puppet_agent_register = <<~"SCRIPT"
sudo /opt/puppetlabs/bin/puppet agent -t;
SCRIPT

Vagrant.configure("2") do |config|

  config.vm.define "puppet-server" do |node|

    hostname = hosts[:puppet_server][:hostname]

    node.vm.box = "roboxes/centos7"
    
    node.vm.provider :libvirt do |libvirt|
      libvirt.cpus = 2
      libvirt.memory = 4096
    end

    node.vm.network :private_network, ip: "#{hosts[:puppet_server][:ipv4_address]}"

    node.vm.provision "shell", path: "puppet-bootstrap.sh" 
    node.vm.provision "shell", inline: $hosts
    node.vm.provision "shell" do |s|
      s.inline = $hostname
      s.args = [hostname]
    end
    node.vm.provision "shell", inline: $puppet_server_install
    node.vm.provision "shell", inline: $puppet_server_config
    node.vm.provision "shell", inline: $puppet_server_restart
    node.vm.provision "shell", inline: $puppet_server_firewall

  end

  config.vm.define "centos-agent" do |node|

    hostname = hosts[:centos_agent][:hostname]

    node.vm.box = "roboxes/centos7"

    node.vm.network :private_network, ip: "#{hosts[:centos_agent][:ipv4_address]}"

    node.vm.provision "shell", path: "puppet-bootstrap.sh" 
    node.vm.provision "shell", inline: $hosts
    node.vm.provision "shell" do |s|
      s.inline = $hostname
      s.args = [hostname]
    end
    node.vm.provision "shell" do |s|
      s.inline = $puppet_agent_config
      s.args = [hostname]
    end
    node.vm.provision "shell", inline: $puppet_server_ready_check
    node.vm.provision "shell", inline: $puppet_agent_register

  end

  config.vm.define "ubuntu-agent" do |node|

    hostname = hosts[:ubuntu_agent][:hostname]

    node.vm.box = "roboxes/ubuntu1804"

    node.vm.network :private_network, ip: "#{hosts[:ubuntu_agent][:ipv4_address]}"

    node.vm.provision "shell", path: "puppet-bootstrap.sh"
    node.vm.provision "shell", inline: $hosts
    node.vm.provision "shell" do |s|
      s.inline = $hostname
      s.args = [hostname]
    end
    node.vm.provision "shell" do |s|
      s.inline = $puppet_agent_config
      s.args = [hostname]
    end
    node.vm.provision "shell", inline: $puppet_server_ready_check
    node.vm.provision "shell", inline: $puppet_agent_register

  end

end
