require 'sinatra'
require 'json'
require 'webrick'
require 'rubygems'

GITSERVER 	= 'master.puppetlabs.vm' # Change to gitlab or whatever server you're using
LOGFILE   	= '/tmp/webhook.log' #'/var/lib/peadmin/webhook.log'
USER      	= 'admin'
PASS      	= 'admin'
HIERA_DIR	= '/Users/malnick/projects/puppet-connect_solutions/puppet-configuration' # replace in prod

ENV['HOME'] = '/root'
ENV['PATH'] = '/sbin:/usr/sbin:/bin:/usr/bin:/opt/puppet/bin'

opts = {
         :Port               => 6969,
         :Logger             => WEBrick::Log::new(LOGFILE, WEBrick::Log::DEBUG),
         :ServerType         => WEBrick::Daemon,
         :SSLEnable          => false,
         }

class Server < Sinatra::Base
	
	get '/' do
		log = WEBrick::Log.new('/tmp/webhook.log', WEBrick::Log::DEBUG)
		output = IO.popen('cd /Users/malnick/projects/puppet-connect_solutions/puppet-dev-environment && MONO=true rake pull <<< y')
		log.info(output.readlines)
	end

	#post '/devhook' do
	#	unless system('MONO=true rake pull <<< y')
	#		abort "Something broke in your puppet modules repo, I couldn't pull..."
	#	end
	#	puts "Successfully pulled down puppet-modules"
	#end

	not_found do
		halt 404, 'You shall not pass! (page not found)'
	end

	def protected!
		# only allow access from the git server.
		throw(:halt, [401, "Not authorized: #{request.host}\n"]) unless request.host == GITSERVER
	end
end

Rack::Handler::WEBrick.run(Server, opts) do |server|
	[:INT, :TERM].each { |sig| trap(sig) { server.stop } }
end

