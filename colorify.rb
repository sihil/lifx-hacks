# Ruby script to poll spotify for what track is currently playing
# and update the colour of your spotify bulbs in response
require 'rubygems'
require 'appscript'
require 'lifx'

$spot = Appscript.app("Spotify")

TAG = "Lounge"

TRACK_COLOUR_HASH = {
  "spotify:track:4q650OiSDQIwccxDFpuuBm" => {
    :desc => "yellow haze",
    :lifx => LIFX::Color.hsb(60, 0.5, 0.5)
  }, # Film
  "spotify:track:51JbeFz87DNrvoYkXf7XHE" => {
    :desc => "warm white, slightly leaning towards yellow",
    :lifx => LIFX::Color.hsbk(60, 0.2, 0.5, 2500)
  }, # 1936
  "spotify:track:6J8SONJwAIizCJm0QhEi4Y" => {
    :desc => "bluey green", # Busy Earnin'
    :lifx => LIFX::Color.hsb(170, 1.0, 0.5)
  },
  "spotify:track:7iX0HyQ120nNwTtCAwyw06" => {
    :desc => "sexy purple", # Rumble
    :lifx => LIFX::Color.hsb(280, 1.0, 0.3)
  },
  "spotify:track:1eKc2ysg5FhOU2jswOlvC2" => {
    :desc => "sexy red", # Gooey
    :lifx => LIFX::Color.hsb(0, 1.0, 0.3)
  },
  "spotify:track:1ANOv63SRuUpI9w347Mgg7" => {
    :desc => "dark, dark, dark- black", # You Got Me
    :lifx => LIFX::Color.hsb(0, 0, 0)
  },
  "spotify:track:7JzlGmut2XLe3HHQPD56Wr" => {
    :desc => "orangey", # Golden Retriever
    :lifx => LIFX::Color.hsb(36, 0.7, 0.5)
  },
  "spotify:track:3BLxSMHBC4DcMsTGFwjUH0" => {
    :desc => "lime", # I Think Ur A Contra
    :lifx => LIFX::Color.hsb(80, 0.9, 0.8)
  },
  "spotify:track:5r3fH9LJLpvwAiyQcg3ghd" => {
    :desc => "warm blue", # Litle Garçon
    :lifx => LIFX::Color.hsbk(240, 0.95, 0.1, 2500)
  },
  "spotify:track:7dwcqXB6BbiFqo7dyKr7hF" => {
    :desc => "pink", # Facing West
    :lifx => LIFX::Color.hsb(325, 1.0, 0.5)
  },
  "spotify:track:7FNZGGbem0YmOOKwzpMZRz" => {
    :desc => "autumn brown", # Bad Bad Love
    :lifx => LIFX::Color.hsb(40, 0.7, 0.4)
  },
  "spotify:track:7Kj05XVesE9nbuGY7dwczs" => {
    :desc => "green", # Pandas
    :lifx => LIFX::Color.hsb(120, 1.0, 0.5)
  },
  "spotify:track:3FzBRKgDtjtv0Xu0diOzib" => {
    :desc => "smokey hazy loveliness", #On a clear day
    :lifx => LIFX::Color.hsb(40, 0.4, 0.1)
  },
  "spotify:track:6Cse7Q7PiuTfSK7A82Df2a" => {
    :desc => "excited neon", # Scoobidoo Love
    :lambda => lambda { |lights|
      lights.set_color(LIFX::Color.hsb(195, 1.0, 1.0), duration:0)
      lights.sine(LIFX::Color.hsb(195, 1.0, 0.1), cycles:1000, period:0.4)
    }
  },
  "spotify:track:4MYAriiSUzgFNvd16mOtHS" => {
    :desc => "light blue", # People Get Up and Drive...
    :lifx => LIFX::Color.hsb(215, 0.25, 0.5)
  },
  "spotify:track:3gUZfVRU0QjyigIeA3Dxao" => {
    :desc => "dark moody blue", # Jesus Gonna Be Here
    :lifx => LIFX::Color.hsb(250, 1.0, 0.5)
  },
  "spotify:track:3J9TIFkGe9nshHbbnWy1Xw" => {
    :desc => "bright white", # Three White Horses
    :lifx => LIFX::Color.hsbk(0, 0, 1, 4500)
  },
  "spotify:track:66mUNi5aAthKWCXPreQW7S" => {
    :desc => "pinky red", # On The Road
    :lifx => LIFX::Color.hsb(335, 0.9, 0.5)
  },
}

$last_known = ""

$lifx = LIFX::Client.lan
$lifx.discover!
sleep 1 # wait for responses

def set_lights(colour)
  lights = TAG ? $lifx.lights.with_tag(TAG) : $lifx.lights
  # puts "Found lights: #{lights}"
  if colour[:lifx]
    puts "setting colour to #{colour[:desc]}"
    lights.set_color(colour[:lifx], duration: 5.0)
  end
  if colour[:lambda]
    puts "running lambda #{colour[:desc]}"
    colour[:lambda].call(lights)
  end
end

def check_and_update
  current = $spot.current_track.spotify_url.get
  # look up current in hash
  if $last_known != current
    print "Playing '#{$spot.current_track.name.get}' by '#{$spot.current_track.artist.get}': "
    $last_known = current
    colour = TRACK_COLOUR_HASH[current]
    if colour then
      for attempt in 1..3 do
        set_lights(colour)
        sleep 1
      end
    else
      puts "no colour for spotify track #{current}"
    end
  end
end

while true do
  check_and_update
  sleep 1
end
