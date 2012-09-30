require File.dirname(__FILE__) + '/spec_helper'
require 'fileutils'

describe "Shutter::Firewall::IPTables" do
  before(:each) do
    @ipt = Shutter::Firewall::IPTables.new("./spec/files")
  end

  it "should return the correct forward block" do
    @ipt.forward_block.should == %q{-A FORWARD -i eth0 -o eth1 -m state --state NEW,RELATED,ESTABLISHED -j ACCEPT
-A FORWARD -i eth1 -o eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT
-A FORWARD -i eth0 -o eth2 -m state --state NEW,RELATED,ESTABLISHED -j ACCEPT
-A FORWARD -i eth2 -o eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT
}
  end

  it "should return the correct iface postrouting block" do
    @ipt.postrouting_block.should == %q{-A POSTROUTING -o eth1 -j MASQUERADE
-A POSTROUTING -o eth2 -j MASQUERADE
}
  end

  it "should return the correct output for allow_private_port_block" do
    @ipt.allow_private_port_block.should == %q{-A Private -m state --state NEW -p tcp -m tcp --dport 22 -j RETURN
}
  end

  it "should return the correct output for allow_public_port_block" do
    @ipt.allow_public_port_block.should == %q{-A Public -m state --state NEW -p tcp -m tcp --dport 80 -j ACCEPT
-A Public -m state --state NEW -p tcp -m tcp --dport 443 -j ACCEPT
}
  end

  it "should return the correct output for allow_ip_block" do
    @ipt.allow_ip_block.should == %q{-A AllowIP -m state --state NEW -s 192.168.0.0/16 -j Allowed
-A AllowIP -m state --state NEW -s 10.0.0.1 -j Allowed
}
  end

  it "should return the correct output for deny_ip_block" do
    @ipt.deny_ip_block.should == %q{-A Bastards -s 172.31.0.0/24 -j DropBastards
-A Bastards -s 8.8.9.9 -j DropBastards
}
  end

  it "should return the correct output for dmz_device_block" do
    @ipt.dmz_device_block.should == %q{-A Dmz -i eth0 -j ACCEPT
-A Dmz -i eth1 -j ACCEPT
}
  end

  it "should return the correct output for generate" do
    iptables_save = File.read("./spec/files/iptables_save.out")
    @ipt.stubs(:iptables_save).returns(iptables_save)
    @ipt.generate.should == %q{*filter
:INPUT DROP [0:0]
:FORWARD DROP [0:0]
:OUTPUT ACCEPT [0:0]
:Dmz - [0:0]
:ValidCheck - [0:0]
:Jail - [0:0]
:Bastards - [0:0]
:Public - [0:0]
:AllowIP - [0:0]
:Allowed - [0:0]
:Private - [0:0]
:DropJail - [0:0]
:DropBastards - [0:0]
:DropInvalid - [0:0]
:DropScan - [0:0]
:DropDDOS - [0:0]
:fail2ban-SSH - [0:0]
-A INPUT -i lo -j ACCEPT
-A INPUT -j Jail
-A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
-A INPUT -j ValidCheck
-A INPUT -j Dmz
-A INPUT -j Bastards
-A INPUT -j Public
-A INPUT -j AllowIP
-A INPUT ! -d 0.0.0.255/0.0.0.255 -m limit --limit 1/min -j LOG --log-prefix "iptables: Block:"
-A INPUT -j DROP
-A Jail -p tcp -m tcp --dport 22 -j fail2ban-SSH
-A Jail -j RETURN 
-A ValidCheck -m state --state INVALID -j DropInvalid
-A ValidCheck -p tcp --tcp-flags ALL FIN,URG,PSH -j DropScan
-A ValidCheck -p tcp --tcp-flags ALL SYN,RST,ACK,FIN,URG -j DropScan
-A ValidCheck -p tcp --tcp-flags ALL ALL -j DropScan
-A ValidCheck -p tcp --tcp-flags ALL FIN -j DropScan
-A ValidCheck -p tcp --tcp-flags ACK,FIN FIN -j DropScan
-A ValidCheck -p tcp --tcp-flags ACK,PSH PSH -j DropScan
-A ValidCheck -p tcp --tcp-flags ACK,URG URG -j DropScan
-A ValidCheck -p tcp --tcp-flags FIN,RST FIN,RST -j DropScan
-A ValidCheck -p tcp --tcp-flags ALL SYN,FIN -j DropScan
-A ValidCheck -p tcp --tcp-flags ALL URG,PSH,FIN -j DropScan
-A ValidCheck -p tcp --tcp-flags ALL URG,PSH,SYN,FIN -j DropScan
-A ValidCheck -p tcp --tcp-flags SYN,RST SYN,RST -j DropScan
-A ValidCheck -p tcp --tcp-flags SYN,FIN SYN,FIN -j DropScan
-A ValidCheck -p tcp --tcp-flags ALL NONE -j DropScan
-A ValidCheck -p tcp --tcp-option 64 -j DropScan
-A ValidCheck -p tcp --tcp-option 128 -j DropScan
-A ValidCheck -p tcp ! --dport 2049 -m multiport --sports 20,21,22,23,80,110,143,443,993,995 -j DropDDOS
-A ValidCheck -p udp ! --dport 2049 -m multiport --sports 20,21,22,23,80,110,143,443,993,995 -j DropDDOS
-A ValidCheck -j RETURN
-A Dmz -i eth0 -j ACCEPT
-A Dmz -i eth1 -j ACCEPT
-A Dmz -j RETURN
-A Bastards -s 172.31.0.0/24 -j DropBastards
-A Bastards -s 8.8.9.9 -j DropBastards
-A Bastards -j RETURN
-A Public -m state --state NEW -p tcp -m tcp --dport 80 -j ACCEPT
-A Public -m state --state NEW -p tcp -m tcp --dport 443 -j ACCEPT
-A Public -j RETURN
-A AllowIP -m state --state NEW -s 192.168.0.0/16 -j Allowed
-A AllowIP -m state --state NEW -s 10.0.0.1 -j Allowed
-A AllowIP -j RETURN
-A Allowed -p icmp -m state --state NEW -m icmp --icmp-type 0 -j ACCEPT
-A Allowed -p icmp -m state --state NEW -m icmp --icmp-type 3 -j ACCEPT
-A Allowed -p icmp -m state --state NEW -m icmp --icmp-type 8 -j ACCEPT
-A Allowed -p icmp -m state --state NEW -m icmp --icmp-type 11 -j ACCEPT
-A Allowed -j Private
-A Allowed ! -d 0.0.0.255/0.0.0.255 -m limit --limit 1/min -j LOG --log-prefix "iptables: Authorized:"
-A Allowed -j ACCEPT
-A Private -m state --state NEW -p tcp -m tcp --dport 22 -j RETURN
-A Private ! -d 0.0.0.255/0.0.0.255 -m limit --limit 3/min -j LOG --log-prefix "iptables: Unauthorized:"
-A Private -j DROP
-A DropJail ! -d 0.0.0.255/0.0.0.255 -m limit --limit 3/min -j LOG --log-prefix "iptables: Jail:"
-A DropJail -j DROP
-A DropBastards ! -d 0.0.0.255/0.0.0.255 -m limit --limit 3/min -j LOG --log-prefix "iptables: Bastards:"
-A DropBastards -j DROP
-A DropInvalid ! -d 0.0.0.255/0.0.0.255 -m limit --limit 3/min -j LOG --log-prefix "iptables: Invalid:"
-A DropInvalid -j DROP
-A DropScan ! -d 0.0.0.255/0.0.0.255 -m limit --limit 3/min -j LOG --log-prefix "iptables: Scan detected:"
-A DropScan -j DROP
-A DropDDOS ! -d 0.0.0.255/0.0.0.255 -m limit --limit 3/min -j LOG --log-prefix "iptables: DDOS detected:"
-A DropDDOS -j DROP
-A FORWARD -i eth0 -o eth1 -m state --state NEW,RELATED,ESTABLISHED -j ACCEPT
-A FORWARD -i eth1 -o eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT
-A FORWARD -i eth0 -o eth2 -m state --state NEW,RELATED,ESTABLISHED -j ACCEPT
-A FORWARD -i eth2 -o eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT
-A FORWARD ! -d 0.0.0.255/0.0.0.255 -m limit --limit 3/min -j LOG --log-prefix "iptables: Bad NAT:"
-A FORWARD -j DROP
-A fail2ban-SSH -j RETURN
COMMIT
*nat
:PREROUTING ACCEPT [0:0]
:POSTROUTING ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
-A POSTROUTING -o eth1 -j MASQUERADE
-A POSTROUTING -o eth2 -j MASQUERADE
COMMIT}
  end
end
