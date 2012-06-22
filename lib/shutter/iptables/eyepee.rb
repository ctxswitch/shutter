module Shutter
	module IPTables
		class EyePee
			def initialize( path, state )
				@state = state
				file = File.open("#{path}/ip.#{state.to_s}", "r")
				@content = file.read
			end

			def to_s
				@content
			end

			def to_ipt
				@rules = ""
				@content.each_line do |ip|
					ip_clean = ip.strip
					if ip_clean =~ /^[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}(\/[0-9]{0,2})*$/
						@rules += send(:"#{@state.to_s}_ipt", ip_clean)
					end
				end
				@rules
			end

			def allow_ipt(ip)
				"-A AllowIP -m state --state NEW -s #{ip} -j Allowed\n"
			end

			def deny_ipt(ip)
				"-A Bastards -s #{ip} -j DropBastards\n"
			end
		end
	end
end