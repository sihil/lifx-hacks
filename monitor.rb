require 'lifx'
require 'eventmachine'

client = LIFX::Client.lan                  # Talk to bulbs on the LAN
EventMachine.run {
	EventMachine.add_periodic_timer(5) {
		client.discover()
		lights = client.lights
		tuples = lights.map{ |l| [l.label, l.color] } 
		light_map = Hash[ tuples ]
		puts light_map
	}
}
