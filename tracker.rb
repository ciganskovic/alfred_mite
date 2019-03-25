#!/usr/bin/env ruby

require 'rubygems'
require 'net/http'
require 'nokogiri'
require 'json'
require 'yaml'
require 'time'

config = YAML.load_file('config.yml')

@api_key  = config['api_key']
@base_url = config['server_url']

json_url  = 'tracker.json'

url      = "https://#@base_url/#{json_url}?api_key=#{@api_key}"
uri      = URI(url)
response = Net::HTTP.get(uri)


@tracker_json = JSON.parse(response)['tracker']



def build_empty_tracker_xml
	build_tracker_empty = Nokogiri::XML::Builder.new { |xml|
		xml.items {
			xml.item('uuid' => 'string', 'arg' => "#@base_url", 'type' => 'string') {
				xml.title('Currently there is no running tracker')
			}
		}
	}
	puts build_tracker_empty.to_xml
end

def build_tracker_xml
	ticket_url      = "time_entries/#{@tracker_json['tracking_time_entry']['id']}.json"
	url_ticket      = "https://#@base_url/#{ticket_url}?api_key=#{@api_key}"
	ticket_uri      = URI(url_ticket)
	ticket_response = Net::HTTP.get(ticket_uri)
	ticket_json     = JSON.parse(ticket_response)['time_entry']


	date = Time.parse("#{@tracker_json['tracking_time_entry']['since']}").to_s.split(' ')[0]
	time = Time.parse("#{@tracker_json['tracking_time_entry']['since']}").to_s.split(' ')[1]

	build_tracker = Nokogiri::XML::Builder.new { |xml|
		xml.items {
			xml.item('uuid' => 'string', 'arg' => "#{@base_url}/time_entries/#{@tracker_json['tracking_time_entry']['id']}", 'type' => 'string') {
				xml.title("#{ticket_json['project_name']} - #{@tracker_json['tracking_time_entry']['minutes']} Minutes")
				xml.subtitle("Started Tracker on #{date} at #{time}")
			}
		}
	}
	puts build_tracker.to_xml
end

if response == '{"tracker":{}}'
	build_empty_tracker_xml
else
	build_tracker_xml
end
