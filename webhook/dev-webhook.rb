require 'sinatra'
require 'json'
require 'webrick'
require 'rubygems'

CWD		= Dir.pwd 
LOGFILE   	= "#{CWD}/server.log" #'/tmp/webhook.log' #'/var/lib/peadmin/webhook.log'
USER      	= 'admin'
PASS      	= 'admin'

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
		log = WEBrick::Log.new("#{CWD}/hook_session.log", WEBrick::Log::DEBUG)
		log.info("Server hooked..")
		output = IO.popen("cd #{CWD} && MONO=true rake pull <<< y")
		log.debug(output.readlines)
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
		throw(:halt, [401, "Not authorized: #{request.host}\n"]) 
	end
end

Rack::Handler::WEBrick.run(Server, opts) do |server|
	[:INT, :TERM].each { |sig| trap(sig) { server.stop } }
end

