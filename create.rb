#!/usr/bin/env ruby

require 'net/http'
require 'uri'
require 'json'
require 'nokogiri'
require 'yaml'


config = YAML.load_file('config.yml')

@api_key  = config['api_key']
@base_url = config['server_url']

def push_projects
	json_url = 'projects.json'
	@query_projects = ARGV[0]

	@project_ids = Array.new

	url = "https://#{@base_url}/#{json_url}?api_key=#{@api_key}"
	uri = URI(url)

	response = Net::HTTP.get(uri)


	projects_json = JSON.parse("#{response}")

	projects_json.each { |project|
		@project_ids.push("#{project['project']['id']}")
	}


	build_projects = Nokogiri::XML::Builder.new { |xml|
		xml.items {
			xml.item('uuid' => 'string', 'type' => 'string') {
				xml.icon('src/info.png')
				xml.title('Choose a project and Tab to autocomplete')
			}
			projects_json.each { |project|
				if project['project']['name'].match(/#{@query_projects}/i)
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


def push_services
	json_url = 'services.json'
	@query_services = ARGV[1]

	url = "https://#{@base_url}/#{json_url}?api_key=#{@api_key}"
	uri = URI(url)
	response = Net::HTTP.get(uri)

	services_json=JSON.parse(response)

	build_services = Nokogiri::XML::Builder.new { |xml|
		xml.items {
			xml.item('uuid' => 'string', 'type' => 'string') {
				xml.icon('src/info.png')
				xml.title('Choose a service and Tab to autocomplete')
			}
			services_json.each { |service|
				if service['service']['name'].match(/#{@query_services}/i)
					xml.item('uuid' => 'string', 'arg' => "#{ARGV[0]} #{service['service']['id']}", 'autocomplete' => "#{ARGV[0]} #{service['service']['id']}", 'type' => 'string') {
						xml.title("#{service['service']['name']}")
						xml.subtitle("Billable = #{service['service']['billable']}")
					}
				end
			}
		}
	}

	puts build_services.to_xml

end

def push_times
	build_times = Nokogiri::XML::Builder.new { |xml|
		xml.items {
			xml.item('uuid' => 'string', 'type' => 'string') {
				xml.icon('src/info.png')
				xml.title('Choose a time in minutes')
			}
		}
	}
	puts build_times.to_xml
end

def push_comment
	build_comment = Nokogiri::XML::Builder.new { |xml|
		xml.items {
			xml.item('uuid' => 'string', 'arg' => "#{ARGV[0]} #{ARGV[1]} #{ARGV[2]} #{ARGV[3..-1]}", 'type' => 'string') {
			xml.icon('src/info.png')
			xml.title('Write a comment and type enter to complete')
			}
		}
	}
	puts build_comment.to_xml
end

if ARGV.empty?
	push_projects
elsif ARGV[0].match(/\A(?:[a-z0-9]\-?)*[a-z](?:\-?[a-z0-9])*/i)
	push_projects
elsif ARGV[0].match(/^\d+$/) and ARGV[1].nil?
	push_services
elsif ARGV[0].match(/^\d+$/) and ARGV[1].match(/\A(?:[a-z0-9]\-?)*[a-z](?:\-?[a-z0-9])*/i)
	push_services
elsif ARGV[0].match(/^\d+$/) and ARGV[1].match(/^\d+$/) and ARGV[2].nil?
	push_times
elsif ARGV[0].match(/^\d+$/) and ARGV[1].match(/^\d+$/) and ARGV[2].match(/^\d+$/)
	push_comment
else
	push_comment
end
