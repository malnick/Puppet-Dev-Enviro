puppet-dev-environment
======================

A development environment for testing puppet modue(s) via rake tasks &amp; vagrant. 

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

#### '''MONO=true rake deploy```

* Same as 'deploy' but works with a monolithic puppet repo.
* When set, moves all modules out of cloned repo to ```puppet/modules```
* Declare single monolithic repo in ```puppet/Pupeptfile``` as you would any other repo.
* WARNING: Will break if you declare other modules that are not in a monolithic repo in the Puppetfile - currently this enviro only works for mono or non-mono at a time only, you can't do both at once.

### ```rake create_structure```

* Ensures the correct directory structure for the environment
* Creates stub Puppetfile

### ```rake pull```

**WARNING:** This will blow away everything in ```puppet/modules```
* Runs r10k on Puppetfile to pull down modules again, if needed.

#### ```rake test```

**WARNING:** Currently in development. 
* *SHOULD* Add stuff to git and push to repo for given module, i.e., automate the git add/commit/push process.



## Pipeline

1. Create modules with the following structure in puppet/:

	puppet/puppet-${module_name}

You can edit these modules live, or you can specify modules deps in the Puppetfile directly:

1. Add modules to ```puppet/Puppetfile```

	I usually add puppetlabs-apache, mysql, stdlib, etc that I will need during the training. 

1. ```rake setup```
1. ```rake test```
2  ```rake deploy```

Once you've made some changes to ```puppet-${module_name}``` you can run ``` rake test``` and it will add new changes to commit and push them to git, then pull them back down to the symlinked module dir via r10k for testing on the VM.
