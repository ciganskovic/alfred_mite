#!/usr/bin/env ruby

require 'rubygems'
require 'net/http'
require 'nokogiri'
require 'json'
require 'yaml'

config = YAML.load_file('config.yml')

api_key  = config['api_key']
base_url = config['server_url']
json_url = 'time_entries.json'

url = "https://#{base_url}/#{json_url}?api_key=#{api_key}&user_id=current&at=#{ARGV[0]}"
uri = URI(url)
response = Net::HTTP.get(uri)

time_entries_json=JSON.parse(response)

build_entries = Nokogiri::XML::Builder.new { |xml|
	xml.items {
		time_entries_json.each { |time_entry|
			xml.item('uuid' => 'string', 'autocomplete' => "#{time_entry['time_entry']['id']}", 'arg' => "#{base_url}", 'type' => 'string') {
				xml.title("#{time_entry['time_entry']['project_name']} - #{time_entry['time_entry']['note'].split(' ')[0]}")
				xml.subtitle("#{time_entry['time_entry']['minutes']} Minutes as #{billable}")
			}
		}
	}
}

build_entries_empty = Nokogiri::XML::Builder.new { |xml|
	xml.items {
		xml.item('uuid' => 'string', 'arg' => "#{base_url}", 'type' => 'string') {
			xml.title("No worklogs have been made at #{ARGV[0]}")
		}
	}
}

if response == "[]"
	puts build_entries_empty.to_xml
else
	puts build_entries.to_xml
end

