module Shutter
  module IPTables
    class Forward
      def initialize( path )
        file = File.open("#{path}/iface.forward", "r")
        @content = file.read
        @forward = ""
        @masq = ""
        @masq_ifaces = []
        @content.each_line do |line|
          line = line.strip
          if line =~ /^[a-z].+$/
            src, dst = line.split(' ')
            @forward += forward_ipt(src,dst)
            @masq_ifaces << dst unless @masq_ifaces.include?(dst)
          end
        end
        @masq_ifaces.each do |iface|
          @masq += masq_ipt(iface)
        end

      end

      def to_s
        @content
      end

      def to_forward_ipt
        @forward
      end

      def to_masq_ipt
        @masq
      end

      def forward_ipt( src, dst )
        rule = "-A FORWARD -i #{src} -o #{dst} -m state --state NEW,RELATED,ESTABLISHED -j ACCEPT\n"
        rule += "-A FORWARD -i #{dst} -o #{src} -m state --state RELATED,ESTABLISHED -j ACCEPT\n"
        rule
      end

      def masq_ipt( iface )
        "-A POSTROUTING -o #{iface} -j MASQUERADE\n"
      end
    end
  end
end