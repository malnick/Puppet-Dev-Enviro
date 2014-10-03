begin
  require 'os'
  require 'ptools'
rescue LoadError => e
  puts "Error during requires: \t#{e.message}"
  abort "You may be able to fix this problem by running 'bundle'."
end

mono = ENV['MONO']

task :default => 'deps'

necessary_programs = %w(VirtualBox vagrant)
necessary_plugins = %w(vagrant-auto_network vagrant-pe_build)
necessary_gems = %w(bundle r10k)
dir_structure = %w(puppet puppet/modules puppet/manifests) 
file_structure = %w(puppet/Puppetfile puppet/manifests/site.pp)

desc 'Check for the environment dependencies'
task :deps do
  puts 'Checking environment dependencies...'

  printf "Is this a POSIX OS?..."
  unless OS.posix?
    abort 'Sorry, you need to be running Linux or OSX to use this Vagrant environment!'
  end
  puts "OK"
 
  necessary_programs.each do |prog| 
    printf "Checking for %s...", prog
    unless File.which(prog)
      abort "\nSorry but I didn't find required program \'#{prog}\' in your PATH.\n"
    end
    puts "OK"
  end

  necessary_plugins.each do |plugin|
    printf "Checking for vagrant plugin %s...", plugin
    unless %x{vagrant plugin list}.include? plugin
      puts "\nSorry, I wasn't able to find the Vagrant plugin \'#{plugin}\' on your system, running 'rake setup'."
      Rake::Task['setup'].execute
    end
    puts "OK"
  end

  necessary_gems.each do |gem|
    printf "Checking for Ruby gem %s...", gem
    unless system("gem list --local -q --no-versions --no-details #{gem} | egrep '^#{gem}$' > /dev/null 2>&1")
      puts "\nSorry, I wasn't able to find the \'#{gem}\' gem on your system."
      puts "\nRunning 'rake setup'\n"
      Rake::Task['setup'].execute
    end
    puts "OK"
  end

  printf "Checking for additional gems via 'bundle check'..."
  unless %x{bundle check}
    abort ''
  end
  puts "OK"

  puts "\n" 
  puts '*' * 80
  puts "Congratulations! Everything looks a-ok."
  puts '*' * 80
  puts "\n"
end

desc 'Install the necessary Vagrant plugins'
task :setup do
  necessary_plugins.each do |plugin|
    unless system("vagrant plugin install #{plugin} --verbose")
      abort "Install of #{plugin} failed. Exiting..."
    end
  end

  necessary_gems.each do |gem|
    unless system("gem install #{gem}")
      abort "Install of #{gem} failed. Exiting..."
    end
  end

  unless %x{bundle check} 
    system('bundle install')
  end
end

desc "Push new modules to git, add none existing ones to Pfile and pull them down"
task :test do
	cwd = File.dirname(__FILE__)
	modules = [] 
	Dir.foreach("#{cwd}/puppet") do |m|
		if m =~ /^puppet/ 
			puts m
			modules.push(m)	
			new_modules = []
			puppetfile = File.open("#{cwd}/puppet/Puppetfile").read 
			puppetfile.each_line do |line| 
				puts "in open"
				if line =~ /#{m}/
					puts "#{m} is already in puppet/Puppetfile, not adding."
				else
					puts "Adding new module #{m} to puppet/Puppetfile"
					new_modules.push(m)
				end
			end

			File.open("#{cwd}/puppet/puppetfile", 'a') do |file|
				new_modules.each do |new|
					file.write("mod '#{new}', :git => 'https://github.com/malnick/#{new}' \n")
				end
			end
		end
		
	end
	modules.each do |repo| 
		puts "Pushing new code from #{repo} to git..."
		if system("ls #{cwd}/puppet/#{repo}/.git")
			unless system("cd #{cwd}/puppet/#{repo} && git add . && git commit -m 'automated push via rake' && git push")
				abort "Failed to push from the #{repo} repo"
			end
		else
			puts "Please initialize a git repo for #{repo}"
		end
	end
	Rake::Task["pull"].execute
end

desc "Create dir structure"
task :create_structure do 
puts "Checking CWD for directory structure..."
  dir_structure.each do |d|
	cwd = Dir.getwd
	check_dir = "#{cwd}/#{d}"
	if Dir.exists?(check_dir)
		puts "#{check_dir} exists, moving on."
	else
		puts "#{check_dir} does not exist, creating it."
		Dir.mkdir("#{check_dir}", 0777)
	end
  end
  file_structure.each do |f|
	fqp = "#{Dir.getwd}/#{f}"
	if File.exists?(fqp)
		puts "#{fqp} exists, moving on."
	elsif f == "puppet/Puppetfile" 
		puts "Writing a base Puppetfile with 'stdlib'"
		File.open(fqp, 'w') {|file| file.write("mod 'stdlib', :git => 'https://github.com/puppetlabs/puppetlabs-stdlib'")}
	else
		puts "Creating stub file for #{f}"
		File.open(fqp, 'w') {|file| file.write("# STUB FILE FOR #{f}")}
	end
  end
end

desc 'Deploying modules form Puppetfile and booting master and agent VMs' 
task :deploy do
  puts "Building out Puppet module directory..."
  confdir = Dir.pwd
  moduledir = "#{confdir}/puppet/modules"
  puppetfile = "#{confdir}/puppet/Puppetfile"
  puts "Placing modules in #{moduledir}"
  puts "Using Puppetfile at #{puppetfile}"
  unless system("PUPPETFILE=#{puppetfile} PUPPETFILE_DIR=#{moduledir} /usr/bin/r10k puppetfile install")
    abort 'Failed to build out Puppet module directory. Exiting...'
  end
  if Dir.exists?("#{moduledir}/puppet-configuration/")
  	unless system("cp -Rv #{moduledir}/puppet-configuration/* #{confdir}/puppet/data/")
		abort "Failed to move puppet-configuration"
	end
  end
  if mono
	puts "Moving modules out of monolithic dir #{moduledir}/puppet-modules to #{moduledir}"
	unless system("mv #{moduledir}/puppet-modules/* #{moduledir}")
		abort "Failed to move modules from monolithic repo to #{moduledir}"
	end
  end
  puts "Bringing up vagrant machines"
  unless system("vagrant up") 
	  abort 'Vagrant up failed. Exiting...'
  end
  puts "Vagrant Machines Up Successfully\n"
  puts "Access master at 'vagrant ssh master' or 'ssh vagrant@10.10.100.100'\n"
  puts "Password = vagrant"
  puts "-----"
  puts "Puppet modules brought in via puppet/Puppetfile are available on the Vagrant master VM at /etc/puppetlabs/puppet/modules"
  puts "-----"
  puts "Contact git owner for PR's & bug fixes"
  puts "-----"
  puts "Done."
end

desc 'Pull down modules in Puppetfile'
task :pull do
	puts "This will blow away everything in puppet/modules. Are you sure you want to continue? [y/n]"
	ans = STDIN.gets
	if ans =~ /^y/
		confdir = Dir.pwd
		moduledir = "#{confdir}/puppet/modules"
		puppetfile = "#{confdir}/puppet/Puppetfile"
		puts "Pulling down new modules in #{puppetfile} to #{moduledir}"
		unless system("PUPPETFILE=#{puppetfile} PUPPETFILE_DIR=#{moduledir} /usr/bin/r10k puppetfile install")
			abort 'Failed to build out Puppet module directory. Exiting...'
		end
		puts "New modules successfully pulled down" 
		if mono
			puts "Moving modules out of monolithic dir #{moduledir}/puppet-modules to #{moduledir}"
			unless system("mv #{moduledir}/puppet-modules/* #{moduledir}")
				abort "Failed to move modules from monolithic repo to #{moduledir}"
			end
		end
		if Dir.exists?("#{moduledir}/puppet-configuration/")
  			unless system("cp -Rv #{moduledir}/puppet-configuration/* #{confdir}/puppet/data/")
				abort "Failed to move puppet-configuration"
			end
  		end
	else puts "Exiting..."
		exit
	end
end
desc 'Destroy Vagrant Machines'
task :destroy do
	puts "Are you sure you want to destroy the environment? [y/n]"
	STDOUT.flush
	ans = STDIN.gets.chomp
	if ans =~ /^y/
		system("vagrant destroy -f")
	else
		abort 'Aborting vagrant destroy, exiting...'
	end		
end

