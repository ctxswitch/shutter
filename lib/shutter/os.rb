module Shutter
  class OS
    def initialize
      unless File.exist?('/proc/version')
        @version = "Unknown"
      end
    end

    def family
      @family ||= ENV['OS'] ? ENV['OS'] : RUBY_PLATFORM.split('-').last
    end

    def version
      @version ||= IO.read('/proc/version')
    end

    def linux?
      return family == "linux"
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

    alias :centos? :redhat? 
    alias :fedora? :redhat?
  end
end