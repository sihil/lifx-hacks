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
ARP_WHO_HAS_REQUEST = Pcap::Filter.new("arp and src host #{router_ip}", pcaplet.capture)

pcaplet.add_filter(DHCP_REQUEST | ARP_WHO_HAS_REQUEST)

def parse_ethertype(raw_data)
	raw_data[12,2].unpack('H*')[0]
end

def wrap(pkt)
	case parse_ethertype(pkt.raw_data)
	when "0806"
		ArpPacket.new(pkt)
	else
		WrapperPacket.new(pkt)
	end
end

class WrapperPacket
	def initialize(pkt)
		@raw_data = pkt.raw_data
	end

	def to_mac(s)
		return s.chars.map{ |c| c.to_s.unpack("H*")[0] }.join(':')
	end

	def to_ip(s)
		return s.bytes.join('.')
	end

	def mac_dest
		return to_mac(@raw_data[0,6])
	end

	def mac_src
		return to_mac(@raw_data[6,6])
	end

	def ethertype
		parse_ethertype(@raw_data)
	end

	def is_arp?
		ethertype == "0806"
	end

	def to_s
		"#{mac_src}->#{mac_dest} (#{ethertype})" 
	end
end

class ArpPacket < WrapperPacket
	def initialize(pkt)
		super(pkt)
		@arp_raw_data = pkt.raw_data[14..-1]
	end

	def to_s
		super() + "#{hardware_type} #{protocol_type} #{hardware_address_length} #{protocol_address_length} #{sender_pa} #{target_pa}"
	end

        def hardware_type
		@arp_raw_data[0,2].unpack('H*')[0]
	end

        def protocol_type
		@arp_raw_data[2,2].unpack('H*')[0]
	end

        def hardware_address_length
		@arp_raw_data[4,1].unpack("H2")[0]
	end

        def protocol_address_length
		@arp_raw_data[5,1].unpack("H2")[0]
	end

	def sender_ha
		to_mac(@arp_raw_data[8,6])
	end

	def sender_pa
		to_ip(@arp_raw_data[14,4])
	end

	def target_ha
		to_mac(@arp_raw_data[18,6])
	end

	def target_pa
		to_ip(@arp_raw_data[24,4])
	end
end 

class FadingCounter
	def initialize(period)
		@keys = []
		@period = period
	end

	def increment(key)
		@keys.push({:key => key, :expiry => Time.now + @period})
	end

	def get_count(key)
		now = Time.now
		@keys.reject!{|element| element[:expiry] < now }
		@keys.count{|element| element[:key] == key}
	end
end

counter = FadingCounter.new(15)

# inspect packets
pcaplet.each_packet { |pkt|
  wrapper = wrap(pkt)
  if pkt.ip? 
    #this should be a dhcp request
    puts "Looks like #{wrapper.mac_src} is joining the network"
  else 
    counter.increment(wrapper.target_pa)
    if counter.get_count(wrapper.target_pa) > 10
	puts "Looks like #{wrapper.target_pa} has dropped off the network"
    end
  end
}
