# a ruby script that monitors broadcast network traffic to look for devices
# that join and leave the network
require 'rubygems'
require 'pcaplet'
include Pcap

# config
router_ip = "192.168.0.1"
device_mac_addresses = ["10:68:3f:4f:a8:f9"]

# initialise PCAP
pcaplet = Pcaplet.new

DHCP_REQUEST = Pcap::Filter.new('dst port 67', pcaplet.capture)
ARP_WHO_HAS_REQUEST = Pcap::Filter.new("arp and src host %{router_ip}", httpdump.capture)

pcaplet.add_filter(DHCP_REQUEST | ARP_WHO_HAS_REQUEST)

# inspect packets
pcaplet.each_packet { |pkt|
  puts pkt
}
