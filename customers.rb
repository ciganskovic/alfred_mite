#!/usr/bin/env ruby

require 'rubygems'
require 'net/http'
require 'nokogiri'
require 'json'
require 'yaml'

config = YAML.load_file('config.yml')

api_key  = config['api_key']
base_url = config['server_url']
json_url = 'customers.json'

url = "https://#{base_url}/#{json_url}?api_key=#{api_key}"
uri = URI(url)
response = Net::HTTP.get(uri)

@customers_json = JSON.parse(response)

def autocomplete
	query = ARGV[0]
	build_customers = Nokogiri::XML::Builder.new { |xml|
		xml.items {
			@customers_json.each { |customer|
				if customer['customer']['name'].match(/#{query}/i)
					xml.item('uuid' => 'string', 'arg' => "#{customer['customer']['name']}", 'type' => 'string') {
						xml.title("#{customer['customer']['name']}")
						xml.subtitle("#{customer['customer']['note'].split(' ').last}")
					}
				end
			}
		}
	}
				puts build_customers.to_xml
end


autocomplete
