require_relative 'client'
require_relative 'log'

class Event
	
	def initialize
		@buff_events = []
		@send_event_number = 1
	end

	def client
		@client ||= Client
	end

	def log
		log ||= Log.new
		@log = log.logger
	end

	def buff(event)
		event_decoded = decode event

		fire event_decoded if envent_seq_top? event_decoded[:seq]

		detect

		@buff_events << event_decoded

	end

	private
	
	def envent_seq_top? event_seq_id
		event_seq_id == @send_event_number ? true : false
	end

	def method_missing(m, *args, &block)  
	    puts "There's no method called #{m} here -- please try again."  
	end 

	def F event_decoded
		log.info("EVENT"){ "start follow event" }
		client_c = client.connection event_decoded[:to_user_id]

		if client_c
			p event_decoded[:from_user_id]
			p event_decoded[:to_user_id]
			p client.follow(event_decoded[:from_user_id], event_decoded[:to_user_id])
			event = encode event_decoded
			client_c.print(event)
			log.info("EVENT"){ "send event: #{envet}" }
		else
			log.warn("EVENT"){ "user not found: #{event_decoded[:to_user_id]}" }
		end
	end 

	def U event_decoded
		log.info("EVENT"){ "start unfollow event" }
		client_c = client.connection event_decoded[:to_user_id]

		if client_c
			client.unfollow(event_decoded[:from_user_id], event_decoded[:to_user_id])
			log.info("EVENT"){ "send event: #{event}" }
		else
			log.warn("EVENT"){ "user not found: #{event_decoded[:to_user_id]}" }
		end

	end

	def B event_decoded
		log.info("EVENT"){ "start broadcast event" }
		clients = client.all
		event = encode event_decoded
		clients.map do |client|
			client[:connection].print(event)
		end
	end

	def P event_decoded
		log.info("EVENT"){ "start private msg event" }
		client_u = client.connection event_decoded[:to_user_id]
		if client_u
			event = encode event_decoded
			client_u.print(event)
			log.info("EVENT"){ "send event: #{event}" }
		else
			log.warn("EVENT"){ "user not found: #{event_decoded[:to_user_id]}" }
		end
	end

	def S event_decoded
		log.info("EVENT"){ "start status update event" }
		client_u = client.by_id event_decoded[:from_user_id]
		if client_u
			if not client_u[:follow].empty?
				client_u[:follow].map do |user_id|
					client_u = client_u.connection user_id
					if client_u
						event = encode event_decoded
						client_u.print(event)
						log.info("EVENT"){ "send event: #{event}" }
					else
						log.warn("EVENT"){ "user not found: #{event_decoded[:to_user_id]}" }
					end

				end
			end
		else
			log.warn("EVENT"){ "user not found: #{event_decoded[:to_user_id]}" }
		end

	end

	def fire event_decoded
		log.info("EVENT"){ "Start to fire event: #{event_decoded[:seq]}" }

		send(event_decoded[:type], event_decoded)		

		@send_event_number += 1
	end

	def encode event_decoded
		event_decoded.values.flatten.compact.join("|") + "\r\n"
	end

	def decode event
		h = Hash[[:seq, :type, :from_user_id, :to_user_id].zip(event.split('|'))]
		h.merge(h) { |k, v| Integer(v) rescue v }
	end
	#recusivamente
	def detect
		event_to_fire = @buff_events.detect {|event| event[:seq].to_i == @send_event_number }
		if event_to_fire
			log.info("EVENT"){ "event detected" }
			fire event_to_fire			
			detect
		end

	end

end
