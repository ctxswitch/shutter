require "shutter/version"
require "shutter/content"
require "shutter/command_line"

module Shutter
  CONFIG_FILES = %w[
        base.ipt
        iface.dmz
        iface.forward
        ip.allow
        ip.deny
        ports.private
        ports.public
  ]
end
