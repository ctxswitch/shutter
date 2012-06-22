module Shutter
  module IPTables
    class Jail
      def initialize( iptables = "/sbin/iptables")
        @iptables =  iptables
      end

      def fail2ban_chains
        `/sbin/iptables-save | grep "^:fail2ban"`
      end

      def fail2ban_rules
        `/sbin/iptables-save | grep "^-A fail2ban"`
      end

      def jail_rules
        jail = `/sbin/iptables-save | grep "^-A Jail"`
        lines = jail.split('\n')
        unless lines.last =~ /-A Jail -j RETURN/
          jail += "-A Jail -j RETURN\n"
        end
        jail
      end
    end
  end
end