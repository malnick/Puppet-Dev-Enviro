puppet-dev-environment
======================

A development environment for testing puppet modue(s) via rake tasks &amp; vagrant. 
## Deployment
I wanted to create a way to easily write modules using my local editor and dotfiles (tmux etc) but have them available on the VM for testing purposes.  

To do this I wrote a Rakefile that pulls down modules via r10k (if needed) and adds them to puppet/modules, then deploys the three VM's I use most often in class.

1. Master

	A standard master VM 

2. Agent

	A standard agent for testing code on / demonstration

3. Standalone

	A standalone VM for testing with ```puppet apply```

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
