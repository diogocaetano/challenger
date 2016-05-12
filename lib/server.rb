require 'timeout'
require 'socket'
require_relative 'event'
require_relative 'client'
require_relative 'log'

class Server
	def initialize
		@server_event = TCPServer.open(9090)   
		@server_clients = TCPServer.open(9099)
	end

	def event
      @event ||= Event.new
    end

    def client
      @client ||= Client
    end

    def log
		log ||= Log.new
		@log = log.logger
	end

	def run 
		Thread.fork { run_server_client }
	    run_server_event.join
	end

	def run_server_event
		log.info("SERVER"){ "start event server" }
		Thread.start(@server_event.accept) do |event_souce|
			while line = event_souce.gets 
				self.event.buff line.chop
			end
			event_souce.close   
		end
	end

	def run_server_client
		log.info("SERVER"){ "start client server" }
		loop{
			Thread.start(@server_clients.accept) do |client|
				while line = client.gets
					user_id = line.chop
					self.client.add_client(user_id.to_i, client)
				end
			end
		}.join
	end

	def stop
		@server_event.close
		@server_clients.close
	end

end

server = Server.new()
server.run