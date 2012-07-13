require 'optparse'
require 'shutter/iptables'
require 'shutter/os'

module Shutter
  class CommandLine
    def initialize( path = "/etc/shutter.d")
      # Currently only available to RedHat variants uless testing
      unless ENV['SHUTTER_MODE'] == "testing"
        @os = Shutter::OS.new
        unless @os.redhat?
          puts "Shutter is currently only compatible with RedHat and its variants."
          puts "Help make it compatible with others (github.com/rlyon/shutter)"
          exit
        end
      end

      @config_path = path
    end

    def iptables
      @iptables ||= Shutter::IPTables::Base.new(@config_path)
    end

    def execute
      options = {}
      optparse = OptionParser.new do |opts|
        opts.banner = "Usage: shutter [options]"
        options[:command] = :save
        opts.on( '--init', 'Create the initial configuration files' ) do
          options[:command] = :init
        end
        opts.on( '--reinit', 'Rereate the initial configuration files' ) do
          options[:command] = :reinit
        end
        opts.on( '-s', '--save', 'Output the firewall to stdout. (DEFAULT)') do
          options[:command] = :save
        end
        opts.on( '-r', '--restore', 'Load the firewall through iptables-restore.') do
          options[:command] = :restore
        end
        @persist = false
        opts.on( '-p', '--persist', 'Make the changes persistant. (with --restore)') do
          @persist = true
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
      optparse.parse!
      puts "* Using config path: #{@config_path}" if @debug
      puts "* Running command: #{options[:command].to_s}" if @debug
      send(options[:command])
    end

    def init
      create_config_dir
      Shutter::CONFIG_FILES.each do |name|
        file = "#{@config_path}/#{name}"
        unless File.exists?(file)
          # puts "Creating: #{file}"
          File.open(file, 'w') do |f| 
            f.write(Shutter.const_get(name.upcase.gsub(/\./, "_")))
          end
        end
      end
    end

    def reinit
      create_config_dir
      Shutter::CONFIG_FILES.each do |name|
        file = "#{@config_path}/#{name}"
        File.open(file, 'w') do |f| 
          f.write(Shutter.const_get(name.upcase.gsub(/\./, "_")))
        end
      end
    end

    def save
      init
      @ipt = iptables.generate
      puts @ipt
    end

    def restore
      init
      @ipt = iptables.generate
      IO.popen("#{Shutter::IPTables::IPTABLES_RESTORE}", "r+") do |iptr|
        iptr.puts @ipt ; iptr.close_write
      end
      persist if @persist
    end

    def persist
      pfile = ENV['SHUTTER_PERSIST_FILE'] ? ENV['SHUTTER_PERSIST_FILE'] : iptables.persist_file(@os)
      File.open(pfile, "w") do |f|
        f.write(@ipt)
      end
    end

    private
    def create_config_dir
      # Check to see if the path to the config files exist
      unless File.directory?(@config_path)
        begin
          Dir.mkdir(@config_path)
        rescue Errno::ENOENT
          raise "Could not create the configuration directory.  Check to see if the parent directory exists."
        end
      end
    end

  end
end