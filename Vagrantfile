# -*- mode: ruby -*-
# vi: set ft=ruby :

domain = "testlab"

hosts = {
  server01: {
    hostname: "server01",
    ipv4_address: "192.168.50.10",
    vagrant_box: "roboxes/centos7",
    puppet_server: true,
  },
  agent01: {
    hostname: "agent01",
    ipv4_address: "192.168.50.111",
    vagrant_box: "roboxes/centos7",
    puppet_server: false,
  },
  agent02: {
    hostname: "agent02",
    ipv4_address: "192.168.50.112",
    vagrant_box: "roboxes/ubuntu1804",
    puppet_server: false,
  }
}

def get_hosts(hosts, domain)

  output = ""

  hosts.each do |host, data|
    entry = "#{data[:ipv4_address]} #{data[:hostname]}.#{domain} #{data[:hostname]}"
    if data[:puppet_server]
      output << "#{entry} puppet\n"
    else
      output << "#{entry} \n"
    end
  end

  return output

end

puppet_bootstrap_file = "https://raw.githubusercontent.com/bobthebutcher/puppet-utils/master/puppet-bootstrap.sh"

puppet_binary = "/opt/puppetlabs/bin/puppet"

$hosts = <<~"SCRIPT"
echo "#### EDITING HOSTS FILE ####"
sudo tee -a /etc/hosts > /dev/null << "EOF"
#{get_hosts(hosts, domain)}
EOF
SCRIPT

$hostname = <<~"SCRIPT"
echo "#### EDITING HOSTNAME ####"
echo $1 | sudo tee /etc/hostname;
sudo /bin/hostname -F /etc/hostname;
SCRIPT

$puppet_server_install = <<~"SCRIPT"
echo "#### PUPPET SERVER01 INSTALL ####"
sudo yum install -y puppetserver;
sudo systemctl start puppetserver.service;
sudo systemctl enable puppetserver.service;
SCRIPT

$puppet_server_config = <<~"SCRIPT"
echo "#### PUPPET SERVER01 CONFIG ####"
sudo #{puppet_binary} config set server #{hosts[:server01][:hostname]}.#{domain} --section main;
sudo #{puppet_binary} config set certname #{hosts[:server01][:hostname]}.#{domain} --section main;
echo *.#{domain} | sudo tee /etc/puppetlabs/puppet/autosign.conf;
SCRIPT

$puppet_server_restart = <<~"SCRIPT"
echo "#### PUPPET SERVER01 RESTART ####"
sudo systemctl restart puppetserver.service;
SCRIPT

$puppet_agent_config = <<~"SCRIPT"
echo "#### PUPPET AGENT CONFIG ####"
sudo #{puppet_binary} config set server #{hosts[:server01][:hostname]}.#{domain} --section main;
sudo #{puppet_binary} config set certname $1.#{domain} --section main;
SCRIPT

$puppet_server_firewall = <<~"SCRIPT"
echo "#### PUPPET SERVER01 FIREWALL ####"
sudo firewall-cmd --add-port=8140/tcp --permanent;
sudo firewall-cmd --reload;
SCRIPT

$puppet_server_ready_check = <<~"SCRIPT"
echo "#### PUPPET SERVER01 READY CHECK ####"
timeout 600 bash -c 'until printf "" 2>>/dev/null >>/dev/tcp/$0/$1; do sleep 1; done' #{hosts[:server01][:hostname]}.#{domain} 8140;
SCRIPT

$puppet_agent_register = <<~"SCRIPT"
echo "#### PUPPET AGENT REGISTER ####"
sudo #{puppet_binary} agent -t;
SCRIPT

Vagrant.configure("2") do |config|

  hosts.each do |host, data|

    config.vm.define host do |node|

      node.vm.box = data[:vagrant_box]

      node.vm.network :private_network, ip: data[:ipv4_address]

      if data[:puppet_server]

        node.vm.synced_folder "./puppet-code/environments/", "/etc/puppetlabs/code/environments/", type: "rsync"

        node.vm.provider :libvirt do |libvirt|
          libvirt.cpus = 2
          libvirt.memory = 4096
        end

      end

      node.vm.provision "shell", path: puppet_bootstrap_file
      node.vm.provision "shell", inline: $hosts
      node.vm.provision "shell" do |s|
        s.inline = $hostname
        s.args = [data[:hostname]]
      end

      if data[:puppet_server]

        node.vm.provision "shell", inline: $puppet_server_install
        node.vm.provision "shell", inline: $puppet_server_config
        node.vm.provision "shell", inline: $puppet_server_restart
        node.vm.provision "shell", inline: $puppet_server_firewall

      else

        node.vm.provision "shell" do |s|
          s.inline = $puppet_agent_config
          s.args = [data[:hostname]]

      end
      
      node.vm.provision "shell", inline: $puppet_server_ready_check
      node.vm.provision "shell", inline: $puppet_agent_register

      end

    end

  end

end
