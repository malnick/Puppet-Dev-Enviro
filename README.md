MASTER BRANCH: puppet-dev-environment
======================
## Code changse READ THIS IT'S IMPORTANT!!!!
***ALL CODE IN puppet/modules/ WILL BE BLOWN AWAY ON EITHER ```rake deploy``` or ```rake pull``` DO NOT EDIT CODE IN THIS DIRECTORY***

See the section on "Code Change Pipeline" for workflow.

## Overview
#### Metadata
Enviro: MTLB Development

Machines:

* 1 Puppet Master
* 1 MTLB Node

Notes: MTLB rapid development 

POC: jeff.malnick@connectsolutions.com

## Deployment
WARNING: All data in puppet/modules will be blown away on ```rake deploy```. Do not leave sensitive modules in there before running deploy.

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

Example: 

```ruby
# Puppet Modules
mod 'puppet-modules', :git => 'git@github.com:connectsolutions/puppet-modules', :ref => ${some_branch}

# Puppet Data
mod 'puppet-configuration', :git => 'git@github.com:connectsolutions/puppet-configuration'

# Aux Modules
mod 'nginx', :git => 'https://github.com/jfryman/puppet-nginx'
mod 'apt', :git => 'https://github.com/puppetlabs/puppetlabs-apt'
```

1. Add hieradata repo to ```puppet/puppetfile```

```bash
vi puppet/Puppetfile
# Add the :git repo for your puppet-configuration
```

1. Configure hieradata

```bash
vi puppet/hiera.yaml
# Make neccessary edits
```

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

# Code Change Pipeline
READ THIS IT'S IMPORTANT!!!!
***ALL CODE IN puppet/modules/ WILL BE BLOWN AWAY ON EITHER ```rake deploy``` or ```rake pull``` DO NOT EDIT CODE IN THIS DIRECTORY***

1. If you haven't already, git clone the puppet-modules repo (git@github.com:connectsolutions/puppet-modules)
1. In one terminal, have an open ssh session going with your dev node in puppet-dev-enviro
1. In another terminal have an editor open to the module code for $your_dev_class which is directly editing code from puppet-modules/$my_dev_modules

	DO NOT DIRECTLY EDIT THE CODE IN puppet/modules!

1. Run the puppet agent on your node, make code changes in your editor
1. When ready to test new code on the node:
	1. git add $my_code
	1. git commit -m "my awesome message"
	1. git push origin $my_branch
1. Then in the puppet-dev-enviro directory
	
	MONO=true rake pull

1. Make sure puppet/Puppetfile specifies the correct :ref branch for puppet-modules
1. Run the agent on your dev node again

To speed this up you can create an alias like:

```
alias fuckit="git commit -am 'I'm in a huge rush' && git push origin $my_branch"
```

and in your terminal running puppet-dev-enviro

```
MONO=true rake pull
```

and on your agent node

```
puppet agent -t
```

