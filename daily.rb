#!/usr/bin/env ruby

require 'rubygems'
require 'net/http'
require 'nokogiri'
require 'json'
require 'yaml'

config = YAML.load_file('config.yml')

api_key  = config['api_key']
base_url = config['server_url']
json_url = 'daily.json'

url = "https://#{base_url}/#{json_url}?api_key=#{api_key}"
uri = URI(url)

response = Net::HTTP.get(uri)

times = Array.new

time_entries_json=JSON.parse(response)

build_daily = Nokogiri::XML::Builder.new { |xml|
	xml.items {
		time_entries_json.each { |time_entry|
			times.push("#{time_entry['time_entry']['minutes'].to_i}")
		}

		sum = times.inject(&:+)
		@total_time = Time.at(sum).gmtime.strftime('%T')

		xml.item('uuid' => 'string', 'type' => 'string') {
			xml.icon('src/info.png')
			xml.title("Total: #{@total_time}")
		}
		time_entries_json.each { |time_entry|
			if time_entry['time_entry']['billable']
				billable = 'Billable'
			else
				billable = 'Non Billable'
			end
			xml.item('uuid' => 'string', 'arg' => "#{base_url}/time_entries/#{time_entry['time_entry']['id']}", 'type' => 'string') {
				xml.title("#{time_entry['time_entry']['project_name']} - #{time_entry['time_entry']['note'].split(' ')[0]}")
				xml.subtitle("#{time_entry['time_entry']['minutes']} Minutes as #{billable}")
			}
		}
	}
}

build_daily_empty = Nokogiri::XML::Builder.new { |xml|
	xml.items {
		xml.item('uuid' => 'string', 'arg' => "#{base_url}", 'type' => 'string') {
			xml.title('No worklogs have been made yet')
		}
	}
}

if response == "[]"
	puts build_daily_empty.to_xml
else
	puts build_daily.to_xml
end
