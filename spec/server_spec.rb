require "spec_helper"
require "server"
require "socket"

describe Server do

	it "Open TCPSocket on ports 9090 and 9090" do		
		expect(TCPSocket).to receive(:open).with(9099)
		expect(TCPSocket).to receive(:open).with(9090)
	
	end

end