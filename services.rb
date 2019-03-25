#!/usr/bin/env ruby

require 'rubygems'
require 'net/http'
require 'nokogiri'
require 'json'
require 'yaml'

config = YAML.load_file('config.yml')

api_key  = config['api_key']
base_url = config['server_url']
json_url = 'services.json'

url = "https://#{base_url}/#{json_url}?api_key=#{api_key}"
uri = URI(url)
response = Net::HTTP.get(uri)

@services_json = JSON.parse(response)

def autocomplete
	query = ARGV[0]
	build_services = Nokogiri::XML::Builder.new { |xml|
		xml.items {
			@services_json.each { |service|
				if service['service']['name'].match(/#{query}/i)
					xml.item('uuid' => 'string', 'autocomplete' => "#{ARGV[0]} #{service['service']['id']}", 'type' => 'string') {
						xml.title("#{service['service']['name']}")
						xml.subtitle("Billable = #{service['service']['billable']}")
					}
				end
			}
		}
	}
				puts build_services.to_xml
end


autocomplete
