module Shutter
  class OS
    class << self
      def family
        return ENV['OS'] ? ENV['OS'] : RUBY_PLATFORM.split('-').last
      end

      def linux?
        return self.family == "linux"
      end

      def dist
        if File.exist?('/proc/version')
          name = "Unknown"
          case IO.read('/proc/version')
          when /Red Hat/
            name = "RedHat"
          when /Debian/
            name = "Debian"
          when /Ubuntu/
            name = "Ubuntu"
          end
          name
        else
          "Unknown"
        end
      end

      def redhat?
        dist == "RedHat"
      end

      alias :centos? :redhat 
      alias :fedora? :redhat
    end
  end
end