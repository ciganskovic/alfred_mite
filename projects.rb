#!/usr/bin/env ruby

require 'net/http'
require 'uri'
require 'json'
require 'nokogiri'
require 'yaml'

config = YAML.load_file('config.yml')

api_key  = config['api_key']
base_url = config['server_url']
json_url = 'projects.json'

url = "https://#{base_url}/#{json_url}?api_key=#{api_key}"
uri = URI(url)

response = Net::HTTP.get(uri)

@projects_json = JSON.parse("#{response}")

def autocomplete
	query = ARGV[0]
	build_projects = Nokogiri::XML::Builder.new { |xml|
		xml.items {
			@projects_json.each { |project|
				if project['project']['name'].match(/#{query}/i)
					xml.item('uuid' => 'string', 'autocomplete' => "#{project['project']['id']}", 'type' => 'string') {
						xml.title("#{project['project']['name']}")
						xml.subtitle("#{project['project']['id']}")
					}
				end
			}
		}
	}
		puts build_projects.to_xml
end


autocomplete
