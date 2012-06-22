require 'optparse'
require 'shutter/iptables'

module Shutter
	class CommandLine
		def initialize( path = "/etc/shutter.d")
			@config_path = path
			# Make sure that we have the proper files
			files = %w[
				base.ipt
				iface.dmz
				ip.allow
				ip.deny
				ports.private
				ports.public
			]
			files.each do |name|
				file = "#{@config_path}/#{name}"
				unless File.exists?(file)
					# puts "Creating: #{file}"
					File.open(file, 'w') do |f| 
						f.write(Shutter.const_get(name.upcase.gsub(/\./, "_")))
					end
				end
			end
		end

		def execute
			options = {}
			optparse = OptionParser.new do |opts|
				opts.banner = "Usage: shutter [options]"
				options[:command] = :save
				opts.on( '-s', '--save', 'Output the firewall to stdout.') do
					options[:command] = :save
				end
				opts.on( '-r', '--restore', 'Load the firewall through iptables-restore.') do
					options[:command] = :restore
				end
				options[:debug] = false
				opts.on( '-d', '--debug', 'Be a bit more chatty') do
					options[:debug] = true
				end
				opts.on_tail( '-h', '--help', 'Display this screen' ) do
					puts opts
					exit
				end
				opts.on_tail( '--version', "Show the version") do
					puts Shutter::VERSION
					exit
				end
			end
			optparse.parse
			puts "* Using config path: #{@config_path}" if options[:debug]
			send(options[:command])
		end

		def save
			@ipt = Shutter::IPTables::Base.new(@config_path).generate
			puts @ipt
		end

		def restore
			@ipt = Shutter::IPTables::Base.new(@config_path).generate
			IO.popen("#{Shutter::IPTables::CMD}") do |iptr|
				iptr.puts @ipt 
			end
		end
		
	end
end