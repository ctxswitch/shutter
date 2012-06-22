module Shutter
  module IPTables
    class Base
      def initialize( path )
        @path = path
        file = File.open("#{path}/base.ipt", "r")
        @content = file.read
      end

      def to_s
        @content
      end

      def generate
        #generate_nat
        generate_filter
      end

      def generate_filter
        @dmz = Iface.new("#{@path}", :dmz).to_ipt
        @content = @content.gsub(/#\ \[RULES:DMZ\]/, @dmz)
        @bastards = EyePee.new("#{@path}", :deny).to_ipt
        @content = @content.gsub(/#\ \[RULES:BASTARDS\]/, @bastards)
        @public = Port.new("#{@path}", :public).to_ipt
        @content = @content.gsub(/#\ \[RULES:PUBLIC\]/, @public)
        @allow = EyePee.new("#{@path}", :allow).to_ipt
        @content = @content.gsub(/#\ \[RULES:ALLOWIP\]/, @allow)
        @private = Port.new("#{@path}", :private).to_ipt
        @content = @content.gsub(/#\ \[RULES:PRIVATE\]/, @private)

        # Make sure we are restoring what fail2ban has added
        @f2b_chains = Jail.new.fail2ban_chains
        @content = @content.gsub(/#\ \[CHAIN:FAIL2BAN\]/, @f2b_chains)
        @f2b_rules = Jail.new.fail2ban_rules
        @content = @content.gsub(/#\ \[RULES:FAIL2BAN\]/, @f2b_rules)
        @jail = Jail.new.jail_rules
        @content = @content.gsub(/#\ \[RULES:JAIL\]/, @jail)

        # Remove the rest of the comments and extra lines
        @content = @content.gsub(/^#.*$/, "")
        @content = @content.gsub(/^$\n/, "")        
      end
    end
  end
end