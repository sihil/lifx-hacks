require 'LIFX'
require 'eventmachine'

client = LIFX::Client.lan                  # Talk to bulbs on the LAN
lights = client.lights

# EventMachine.run {
# 	EventMachine.add_periodic_timer(5) {
# 		light_map = Hash[ lights.map{ [l.label, l.color(fetch: true, refresh: true)] } ]
# 		puts light_map
# 	}
# }
