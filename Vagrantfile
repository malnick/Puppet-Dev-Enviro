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
    master.vm.provision "shell", inline: "rm -rf /etc/puppetlabs/puppet/modules/ && ln -s /tmp/modules/ /etc/puppetlabs/puppet/"
    master.vm.provision "shell", inline: "rm -rf /etc/puppetlabs/puppet/manifests/ && ln -s /tmp/manifests/ /etc/puppetlabs/puppet/"
    master.vm.provision "shell", inline: "rm -rf /etc/puppetlabs/puppet/data && ln -s /tmp/data /etc/puppetlabs/puppet/"
  end

## dev machine - ssh in and puppet apply or a "whatever" box 
  #config.vm.define :dev1 do |dev|
  #  dev.vm.network :private_network, ip: "10.28.126.140"
  #  dev.vm.hostname = 'dev1.puppetlabs.vm'
  #  dev.vm.provision :hosts
  #  dev.vm.provision :pe_bootstrap do |pe|
  #    pe.role   =  :agent
  #    pe.master = 'master.dev'
  #  end
  #end

# CSX machines 
  # start csx_mysql first, csx_frontend depends on it
  config.vm.define "csx_mysql" do |frontend|
    frontend.vm.network "private_network", ip: "10.28.126.142"
    frontend.vm.hostname = "u-du-csxstgsql.fed.cs.int"
    frontend.vm.provision :hosts
    frontend.vm.provision :pe_bootstrap do |pe|
    	pe.role		= :agent
	pe.master	= 'master.dev'
    end
  end

  config.vm.define "csx_frontend" do |frontend|
    frontend.vm.network   "private_network", ip: "10.28.126.144"
    frontend.vm.network   "private_network", ip: "173.46.143.13"
    frontend.vm.hostname = "u-du-csxstgnode.fed.cs.int"
    frontend.vm.provision :hosts
    frontend.vm.provision :pe_bootstrap do |pe|
    	pe.role		= :agent
	pe.master	= 'master.dev'
    end
  end

  # start csx_backend, it is a dependency
  config.vm.define "csx_backend" do |backend|
    backend.vm.network   "private_network", ip: "10.28.126.143"
    backend.vm.hostname = "u-du-csxstgnode.fed.cs.int"
    backend.vm.provision :hosts
    backend.vm.provision :pe_bootstrap do |pe|
    	pe.role		= :agent
	pe.master	= 'master.dev'
    end
  end

  # this uses the host vpn for accessing eng.wopr resources
  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
  end
end
