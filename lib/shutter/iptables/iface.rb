module Shutter
	module IPTables
		class Iface
			def initialize( path, type )
				@type = type
				file = File.open("#{path}/iface.#{type.to_s}", "r")
				@content = file.read
			end

			def to_s
				@content
			end

			def to_ipt
				@rules = ""
				@content.each_line do |line|
					line = line.strip
					if line =~ /^[a-z].+$/
						@rules += send(:"#{@type.to_s}_ipt", line)
					end
				end
				@rules
			end

			def dmz_ipt( iface )
				"-A Dmz -i #{iface} -j ACCEPT\n"
			end
		end
	end
end