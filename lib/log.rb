require 'logger'

class Log
	def initialize
		file = File.open('server.log', File::WRONLY | File::APPEND | File::CREAT)
		@logger = Logger.new(file, 'daily') 
		@logger.formatter = proc do |severity, datetime, progname, msg|
		 	print "#{datetime.strftime('%s%3N')} [#{severity}] [#{progname}] #{msg}\n"
		 	"#{datetime.strftime('%s%3N')} [#{severity}] [#{progname}] #{msg}\n"
		end	 
	end

	def logger
		@logger
	end

end