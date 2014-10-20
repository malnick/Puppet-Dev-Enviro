# -*- mode: ruby -*-
# vi: set ft=ruby :
# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "ubuntuamd64"
  config.vm.box_url = "https://cloud-images.ubuntu.com/vagrant/precise/current/precise-server-cloudimg-amd64-vagrant-disk1.box"
  config.pe_build.download_root = 'https://s3.amazonaws.com/pe-builds/released/:version'
  config.pe_build.version = "3.3.0"
  config.ssh.forward_agent  = true

## Master
  config.vm.define :master do |master|
    master.vm.provider :virtualbox do |v|
    	v.memory = 2048
	v.cpus = 1
    end
    master.vm.network :private_network, ip: "10.28.126.141"
    master.vm.hostname = 'master.dev'
    master.vm.provision :hosts
    master.vm.provision :pe_bootstrap do |pe|
      pe.role = :master
    end
    master.vm.synced_folder "puppet/modules", "/tmp/modules"
    master.vm.synced_folder "puppet/manifests", "/tmp/manifests"
    master.vm.synced_folder "puppet/data", "/tmp/data"
    master.vm.synced_folder "puppet/", "/tmp/puppet"
    master.vm.synced_folder "puppet/filestore", "/tmp/filestore"
    master.vm.synced_folder "puppet/fileserver.conf", "/tmp/fileserver.conf"
    master.vm.provision "shell", inline: "rm -rf /etc/puppetlabs/puppet/modules/ && ln -sf /tmp/modules/ /etc/puppetlabs/puppet/"
    master.vm.provision "shell", inline: "rm -rf /etc/puppetlabs/puppet/manifests/ && ln -sf /tmp/manifests/ /etc/puppetlabs/puppet/"
    master.vm.provision "shell", inline: "rm -rf /etc/puppetlabs/puppet/data && ln -sf /tmp/data/ /etc/puppetlabs/puppet/"
    master.vm.provision "shell", inline: "rm -rf /etc/puppetlabs/puppet/filestore && ln -sf /tmp/filestore/ /etc/puppetlabs/puppet/"
    master.vm.provision "shell", inline: "rm -f /etc/puppetlabs/puppet/hiera.yaml && ln -sf /tmp/puppet/hiera.yaml /etc/puppetlabs/puppet/hiera.yaml"
    master.vm.provision "shell", inline: "rm -f /etc/puppetlabs/puppet/fileserver.conf && ln -sf /tmp/puppet/fileserver.conf /etc/puppetlabs/puppet/fileserver.conf"
  end

## dev machine - ssh in and puppet apply or a "whatever" box 
  config.vm.define :dev1 do |dev|
    dev.vm.network :private_network, ip: "10.28.126.140"
    dev.vm.hostname = 'do.dev.here'
    dev.vm.provision :hosts
    dev.vm.provision :pe_bootstrap do |pe|
      pe.role   =  :agent
      pe.master = 'master.dev'
    end
  end

config.vm.define :mtlb do |dev|
    dev.vm.network :private_network, ip: "10.28.126.150"
    dev.vm.hostname = 'mtlb.dev'
    dev.vm.provision :hosts
    dev.vm.provision :pe_bootstrap do |pe|
      pe.role   =  :agent
      pe.master = 'master.dev'
    end
  end

# this uses the host vpn for accessing eng.wopr resources
  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
  end
end
    
