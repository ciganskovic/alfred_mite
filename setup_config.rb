#!/usr/bin/env ruby

require 'yaml'

config = YAML.load_file('config.yml')

if ARGV.empty?
	puts "No Args have benn specified"
	exit
end

config['server_url'] = ARGV[0]
config['api_key']    = ARGV[1]

File.open('config.yml', 'w')  {|f| f.write(config.to_yaml) }

puts "Domain: #{config['server_url']}"
puts "ApiKey: #{config['api_key']}"
