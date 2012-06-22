module Shutter
	module IPTables
		class Port
			def initialize( path, type )
				@type = type
				file = File.open("#{path}/ports.#{type.to_s}", "r")
				@content = file.read
			end

			def to_s
				@content
			end

			def to_ipt
				@rules = ""
				@content.each_line do |line|
					line = line.strip
					if line =~ /^[1-9].+$/
						port,proto = line.split
						@rules += send(:"#{@type.to_s}_ipt", port, proto)
					end
				end
				@rules
			end

			def private_ipt( port, proto )
				"-A Private -m state --state NEW -p #{proto} -m #{proto} --dport #{port} -j RETURN\n"
			end

			def public_ipt( port, proto )
				"-A Public -m state --state NEW -p #{proto} -m #{proto} --dport #{port} -j ACCEPT\n"
			end
		end
	end
end