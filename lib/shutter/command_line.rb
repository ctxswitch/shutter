require 'optparse'

module Shutter
  class CommandLine
    DISPLAY_OPTS_INIT     = %q{Create the initial configuration files.}
    DISPLAY_OPTS_REINIT   = %q{Rereate the initial configuration files.}
    DISPLAY_OPTS_UPGRADE  = %q{Upgrade the configuration files that have changes with a new version.}
    DISPLAY_OPTS_DIR      = %q{Set the directory for configuration files.  Default is /etc/shutter.d.}
    DISPLAY_OPTS_SAVE     = %q{Output the firewall rules to stdout. This is the default behavior.}
    DISPLAY_OPTS_RESTORE  = %q{Restore the firewall rules through iptables-restore.}
    DISPLAY_OPTS_PERSIST  = %q{Write the firewall to the persistance file.  If an argument is given, it will be used as the persistance file.}
    DISPLAY_OPTS_CHECK    = %q{Check to see if the generated rules match the current firewall rules.}
    DISPLAY_OPTS_DEBUG    = %q{Turn on debugging for extra output.}
    DISPLAY_OPTS_HELP     = %q{Display help and exit.}
    DISPLAY_OPTS_VERSION  = %q{Display version and exit.}

    attr_reader :os

    def initialize( path = "/etc/shutter.d")
      @config_path = path
      @os = Shutter::OS.new
    end

    def persist
      @persist ||= false
    end

    def persist_file
      @persist_file ||= @os.persist_file
    end

    def command
      @command ||= :save
    end

    def debug
      @debug ||= false
    end

    def config_path
      @config_path ||= "/etc/shutter.d"
    end

    def firewall
      @firewall ||= Shutter::Firewall::IPTables.new(@config_path)
    end

    def execute(args, noop=false)
      options = {}
      optparse = OptionParser.new do |opts|
        opts.banner = "Usage: shutter [options]"
        # Initialize the configuration files
        opts.on( '--init', DISPLAY_OPTS_INIT ) do
          @command = :init
        end
        # Recreate the configuration files.  Overwrites all changes
        opts.on( '--reinit', DISPLAY_OPTS_REINIT ) do 
          @command = :reinit
        end
        # Upgrade the configuration files that have changes with a new version
        opts.on( '--upgrade', DISPLAY_OPTS_UPGRADE ) do 
          @command = :upgrade
        end
        # Output the firewall to stdout
        opts.on( '-s', '--save', DISPLAY_OPTS_SAVE) do
          @command = :save
        end
        # Restore the firewall through iptables-restore
        opts.on( '-r', '--restore', DISPLAY_OPTS_RESTORE) do
          @command = :restore
        end
        # Write the firewall to the persistance file
        opts.on( '-p', "--persist [FILE]", DISPLAY_OPTS_PERSIST) do |file| 
          @persist = true
          @persist_file = file || persist_file
        end
        # Check the generated rules against the current rules
        opts.on( '-c', "--check", DISPLAY_OPTS_PERSIST) do |file| 
          @command = :check
        end
        # Sets the directory for configuration files
        opts.on( '-d', '--dir DIR', DISPLAY_OPTS_DIR) do |dir| 
          @config_path = dir
        end
        # Turn on debugging
        opts.on_tail( '--debug', DISPLAY_OPTS_DEBUG) do 
          @debug = true
        end
        # Display help and exit
        opts.on_tail( '-h', '--help', DISPLAY_OPTS_HELP ) do 
          puts opts ; exit
        end
        # Display version and exit
        opts.on_tail( '--version', DISPLAY_OPTS_VERSION) do
          puts Shutter::VERSION ; exit
        end
      end
      optparse.parse!(args)
      puts "* Using config path: #{@config_path}" if @debug
      puts "* Running command: #{@command}" if @debug
      puts "* Using persistance file: #{persist_file}" if @debug && persist
      Shutter::Files.create_config_dir(config_path) unless noop
      Shutter::Files.create(config_path)
      run unless noop
    end

    def run
      case @command
      when :init
        Shutter::Files.create(config_path)
      when :reinit
        Shutter::Files.create(config_path,true)
      when :upgrade
        Shutter::Files.create(config_path,false,["base.ipt", "iface.forward"])
      when :save
        firewall.save
      when :restore
        firewall.restore
        puts "Writing to #{persist_file}" if persist
        firewall.persist(persist_file) if persist
      when :check
        if firewall.check
          puts "OK"
        else
          puts "MISMATCH"
        end
      end
    end
  end
end