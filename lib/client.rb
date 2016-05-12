require_relative 'log'

class Client

	@@clients = []

	def self.all
		@@clients.compact
	end

   	def self.log
		log ||= Log.new
		@log = log.logger
	end

	def self.by_id user_id
		@@clients[user_id] ? @@clients[user_id] : false
	end

	def self.connection user_id 
		@@clients[user_id] ? @@clients[user_id][:connection] : false
	end

	def self.add_client user_id, client
		@@clients[user_id] = { connection: client, follow: [] }
		log.info("CLIENT"){ "User client #{user_id} join the party!" }
	end

	def self.follow  from_user_id, user_id
		@@clients[user_id][:follow] << from_user_id
		log.info("CLIENT"){ "User client #{from_user_id} follow #{user_id}!" }
	end	

	def self.unfollow  from_user_id, user_id
		@@clients[user_id][:follow].delete(from_user_id)
		log.info("CLIENT"){ "User client #{from_user_id} unfollow #{user_id}!" }
	end

end