#!/usr/bin/env ruby

require 'net/http'
require 'uri'
require 'json'
require 'yaml'

config = YAML.load_file('config.yml')

api_key  = config['api_key']
base_url = config['server_url']

id    = ARGV[0]
key   = ARGV[1]
value = ARGV[2]

json_url = "#{id}.json"

uri                  = URI.parse("https://#{base_url}/time_entries/#{json_url}?api_key=#{api_key}")
request              = Net::HTTP::Patch.new(uri)
request.content_type = "application/json"
request.body         = JSON.dump({
  "time_entry" => {
    "#{key}" => "#{value}"
  }
})

req_options = {
  use_ssl: uri.scheme == "https",
}

response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
  http.request(request)
end

puts "#{key} : #{value}"
