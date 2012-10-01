module Shutter
  class OS
    def initialize
      unless File.exist?('/proc/version')
        @version = "Unknown"
      end
    end

    def validate!
      if unknown?
        puts "Shutter is currently only compatible with RedHat and its variants."
        puts "Help make it compatible with others (github.com/rlyon/shutter)"
        raise "ERROR: Unsupported version"
      end
    end

    def family
      @family ||= ENV['OS'] ? ENV['OS'] : RUBY_PLATFORM.split('-').last
    end

    def version
      @version ||= IO.read('/proc/version')
    end

    def linux?
      family == "linux"
    end

    def iptables_save
      "/sbin/iptables-save"
    end

    def iptables_restore
      "/sbin/iptables-restore"
    end

    def persist_file
      case version
      when /Red Hat/
        "/etc/sysconfig/iptables"
      when /Debian/
        "/etc/iptables/rules"
      when /Ubuntu/
        "/etc/iptables/rules"
      else
        "/tmp/iptables.rules"
      end
    end

    def dist
      case version
      when /Red Hat/
        "RedHat"
      when /Debian/
        "Debian"
      when /Ubuntu/
        "Ubuntu"
      else
        "Unknown"
      end
    end

    def redhat?
      dist == "RedHat"
    end

    def ubuntu?
      dist == "Ubuntu"
    end

    def debian?
      dist == "Debian"
    end

    def unknown?
      dist == "Unknown"
    end

    alias :centos? :redhat? 
    alias :fedora? :redhat?
  end
end