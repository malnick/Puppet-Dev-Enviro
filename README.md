Webhook-based Local Integration Environment
======================
This environment leverages a webhook running on ```localhost:6969``` and local paths to your repositories to automatically pull in changes on each git commit. 

## Overview
Machines:

* 1 Puppet Master
* 1 Dev Node

## Things that make it go

### Webhook

```webhook/run_hook_server.sh``` 	=> {start|stop} Executable to run dev-webhook.rb 
```webhook/post-commit``` 		=> Hook to be placed in ```/my/repo/.git/hooks``` to auto update this enviro on commit
```webhook/server.log```		=> Server logging
```webhook/hook_session.log```		=> Hook session log: output from curl's to the server. 

### Puppetfile
Update ```puppet/Puppetfile``` to use local paths to your repos:

```ruby
# Puppet Modules
mod 'puppet-modules', :git => '/Users/malnick/projects/puppet-connect_solutions/puppet-modules/', :ref => 'mtlb_sso'

# Puppet Data
mod 'puppet-configuration', :git => '/Users/malnick/projects/puppet-connect_solutions/puppet-configuration/', :ref => 'mtlb_sso'
```

## Deployment

#### ```rake```

* Environment setup:
	* Checks for neccessary programs
	* Checks for neccessary gems
	* Checks for neccessary vagrant plugins
	* Runs ```rake setup``` if any are not found. 

#### ```rake deploy```

* Deploys a master VM with Puppet Enterprise 3.2.3 (configurable in the Vagrantfile).
* Pulls down modules declared in ```puppet/Puppetfile```.
* Symlinks modules in ```puppet/Puppetfile``` to the VM for easy testing.
* You can live edit on your host machine with your local tools all test code.

#### ```MONO=true rake deploy```

* Same as 'deploy' but works with a monolithic puppet repo.
* When set, moves all modules out of cloned repo to ```puppet/modules```
* Declare single monolithic repo in ```puppet/Pupeptfile``` as you would any other repo.
* WARNING: Will break if you declare other modules that are not in a monolithic repo in the Puppetfile - currently this enviro only works for mono or non-mono at a time only, you can't do both at once.

#### ```rake create_structure```

* Ensures the correct directory structure for the environment
* Creates stub Puppetfile

#### ```rake pull```

**WARNING:** This will blow away everything in ```puppet/modules```
* Runs r10k on Puppetfile to pull down modules again, if needed.

#### ```rake test```

**WARNING:** Currently in development. 
* *SHOULD* Add stuff to git and push to repo for given module, i.e., automate the git add/commit/push process.

## Pipeline

1. Add modules to ```puppet/Puppetfile```

1. Add hieradata repo to ```puppet/puppetfile```

1. Configure site.pp

```bash
vi puppet/manifests/site.pp
# Add or edit node definitions
node 'my.node.dev' {
	include my::test::code
}
```

1. Deploy the environment:

```
# Deploy with MONO=true b/c our puppet-modules repo is monolithic
MONO=true rake deploy
```

1. Test the code

```
vagrant ssh ${vagrant_machine_name}
sudo su root
puppet agent -t
```

1. Update the code
	1. In your local puppet-modules or puppet-configuration repo, make changes
	1. On commit, the hook you placed in ./.git/hooks will curl the server in the dev enviro
	1. Your new code should be available on your master. 

1. REPL
