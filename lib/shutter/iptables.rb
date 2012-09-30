module Shutter
  module Firewall
    class IPTables
      RULES_DMZ_BLOCK         = "# [RULES:DMZ]"
      RULES_FORWARD_BLOCK     = "# [RULES:FORWARD]"
      RULES_POSTROUTING_BLOCK = "# [RULES:POSTROUTING]"
      RULES_BASTARDS_BLOCK    = "# [RULES:BASTARDS]"
      RULES_PUBLIC_BLOCK      = "# [RULES:PUBLIC]"
      RULES_ALLOWIP_BLOCK     = "# [RULES:ALLOWIP]"
      RULES_PRIVATE_BLOCK     = "# [RULES:PRIVATE]"
      RULES_FAIL2BAN_BLOCK    = "# [RULES:FAIL2BAN]"
      RULES_JAIL_BLOCK        = "# [RULES:JAIL]"
      CHAIN_FAIL2BAN_BLOCK    = "# [CHAIN:FAIL2BAN]"

      def initialize(path)
        @path = path
        @base_ipt = read("base.ipt")
        @iface_forward = read("iface.forward")
        @ports_private = read("ports.private")
        @ports_public = read("ports.public")
        @ip_allow = read("ip.allow")
        @ip_deny = read("ip.deny")
        @os = Shutter::OS.new
      end

      def base_sub(block,content)
        @base = @base.gsub(/#{Regex.quote(block)}/, content)
      end

      def generate
        self.base_sub(RULES_DMZ_BLOCK,          self.dmz_device_block)
        self.base_sub(RULES_FORWARD_BLOCK,      self.forward_block)
        self.base_sub(RULES_POSTROUTING_BLOCK,  self.postrouting_block)
        self.base_sub(RULES_BASTARDS_BLOCK,     self.deny_ip_block)
        self.base_sub(RULES_PUBLIC_BLOCK,       self.allow_public_port_block)
        self.base_sub(RULES_ALLOWIP_BLOCK,      self.allow_ip_block)
        self.base_sub(RULES_PRIVATE_BLOCK,      self.allow_private_port_block)
        self.base_sub(RULES_FAIL2BAN_BLOCK,     self.fail2ban_rules_block)
        self.base_sub(RULES_JAIL_BLOCK,         self.jail_rules_block)
        self.base_sub(CHAINS_FAIL2BAN_BLOCK,    self.fail2ban_chains_block)
      end

      def clean
        @base = @content.gsub(/^#.*$/, "")
        @base = @content.gsub(/^$\n/, "") 
      end

      def read(file)
        lines = File.read("#{@path}/#{file}").split("\n")
        lines.keep_if{ |line| line =~ /^[a-z].+$/ }
        lines.map { |line| line.strip }
      end

      def save
        puts self.generate
      end

      def restore
        IO.popen("#{iptable_restore}", "r+") do |iptr|
          iptr.puts self.generate ; iptr.close_write
        end
      end

      def persist(pfile)
        File.open(pfile, "w") do |f|
          f.write(@ipt)
        end
      end

      ###
      ### IPTables Commands
      ###
      def iptables_save
        @iptable_save ||= `#{IPTABLES_SAVE}`
      end

      def iptables_restore
        #{IPTABLES_RESTORE}
      end

      ###
      ### Block Generation
      ###
      def forward_block
        content = ""
        @iface_forward.each do |line|
          src, dst = line.split(' ')
          content += self.forward_content(src,dst)
        end
        content
      end

      def postrouting_block
        masq_ifaces = []
        content = ""
        @iface_forward.each do |line|
          src, dst = line.split(' ')
          content += self.postrouting_content(dst) unless masq_ifaces.include?(dst)
          masq_ifaces << dst
        end
        content
      end

      def allow_private_port_block
        content = ""
        @ports_private.each do |line|
          port,proto = line.split
          content += self.allow_private_port_content(port, proto)
        end
        content
      end

      def allow_public_port_block
        content = ""
        @ports_public.each do |line|
          port,proto = line.split
          raise "Invalid port in port.allow" unless port =~ /^[0-9].*$/
          raise "Invalid protocol in port.allow" unless proto =~ /^(tcp|udp)$/
          content += self.allow_public_port_content(port, proto)
        end
        content
      end

      def allow_ip_block
        content = ""
        @ip_allow.each do |line|
          raise "Invalid IP address in ip.allow" unless line =~ /^[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}(\/[0-9]{0,2})*$/
          content += self.allow_ip_content(line)
        end
        content
      end

      def deny_ip_block
        content = ""
        @ip_deny.each do |line|
          raise "Invalid IP address in ip.deny" unless line =~ /^[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}(\/[0-9]{0,2})*$/
          content += self.deny_ip_content(line)
        end
        content
      end

      def dmz_device_block
        content = ""
        @dmz_device.each do |line|
          raise "Invalid device in iface.dmz" unless line =~ /^[a-z][a-z0-9].*$/
          content += self.dmz_device_content(line)
        end
        content
      end

      def fail2ban_chains_block
        iptables_save.scan(/^:fail2ban.*$/).join("\n")
      end

      def fail2ban_rules_block
        iptables_save.scan(/^-A fail2ban.*$/).join("\n")
      end

      def jail_rules_block
        lines = iptables_save.scan(/^-A Jail.*$/)
        jail += "-A Jail -j RETURN\n" unless lines.last =~ /-A Jail -j RETURN/
        jail
      end   

      ###
      ### Block Content
      ###
      def forward_content(src,dst)
        rule =  "-A FORWARD -i #{src} -o #{dst} -m state --state NEW,RELATED,ESTABLISHED -j ACCEPT\n"
        rule += "-A FORWARD -i #{dst} -o #{src} -m state --state RELATED,ESTABLISHED -j ACCEPT\n"
        rule
      end

      def postrouting_content(iface)
        "-A POSTROUTING -o #{iface} -j MASQUERADE\n"
      end

      def allow_private_port_content(port, proto)
        "-A Private -m state --state NEW -p #{proto} -m #{proto} --dport #{port} -j RETURN\n"
      end

      def allow_public_port_content(port, proto)
        "-A Public -m state --state NEW -p #{proto} -m #{proto} --dport #{port} -j ACCEPT\n"
      end

      def allow_ip_content(ip)
        "-A AllowIP -m state --state NEW -s #{ip} -j Allowed\n"
      end

      def deny_ip_content(ip)
        "-A Bastards -s #{ip} -j DropBastards\n"
      end

      def dmz_device_content(iface)
        "-A Dmz -i #{iface} -j ACCEPT\n"
      end

    end
  end
end