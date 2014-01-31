#!/usr/bin/ruby
#

require "json"

conf_file = "ks.json"
settings  = {
              "machine_definitions"   =>  "definitions",
              "machine_definitions"   =>  "definitions"
            };

puts JSON.pretty_generate(settings)
