#!/usr/bin/env ruby

require 'net/http'
require 'uri'
require 'json'
require 'yaml'

config = YAML.load_file('config.yml')

api_key  = config['api_key']
base_url = config['server_url']
json_url = 'time_entries.json'

query  = ARGV[0]
query2 = ARGV[1]
query3 = ARGV[2]
query4 = ARGV[3..-1]

args = "#{query}#{query2}#{query3}#{query4}".split(' ')

project_id = args[0]
service_id = args[1]
time       = args[2]
note       = args[3..-1]

def sentence_maker(array)
	string = array.join(' ')
	string.delete '"' '[]' ','
end

comment = sentence_maker(note)

uri                  = URI.parse("https://#{base_url}/#{json_url}?api_key=#{api_key}")
request              = Net::HTTP::Post.new(uri)
request.content_type = "application/json"
request.body         = JSON.dump({
	"time_entry" => {
		"project_id" => "#{project_id}",
		"service_id" => "#{service_id}",
		"note"       => "#{comment}",
		"minutes"    => "#{time}"
	}
})

req_options = {
	use_ssl: uri.scheme == "https",
}

response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
	http.request(request)
end


puts "Project : #{project_id}"
puts "Ticket  : #{comment}"
