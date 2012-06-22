require 'shutter/iptables/base'
require 'shutter/iptables/eyepee'
require 'shutter/iptables/iface'
require 'shutter/iptables/jail'
require 'shutter/iptables/port'
require 'shutter/os'

module Shutter
  module IPTables
    IPTABLES_RESTORE="/sbin/iptables-restore"

    def persist_file(os)
      "/etc/sysconfig/iptables"
    end
  end
end