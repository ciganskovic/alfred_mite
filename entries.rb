#!/usr/bin/env ruby

require 'rubygems'
require 'net/http'
require 'nokogiri'
require 'json'
require 'yaml'

def push_arg_types
	types = ['today', 'yesterday', 'last_week', 'this_month', 'last_month', 'this_year', 'last_year' ]

	arg_types = Nokogiri::XML::Builder.new { |xml|
		xml.items {
			xml.item('uuid' => 'string', 'type' => 'string') {
				xml.icon('src/info.png')
				xml.title("Type date 'YYYY-MM-DD' or choose keyword")
			}
			types.each { |type|
				if types.to_s.match("#{ARGV[0]}")
				xml.item('uuid' => 'string', 'autocomplete' => "#{type}",'type' => 'string') {
				xml.icon('src/search-icon.png')
					xml.title("#{type}")
				}
				end
			}

		}
	}
	puts arg_types.to_xml
	exit
end


config = YAML.load_file('config.yml')

@api_key  = config['api_key']
@base_url = config['server_url']

def push_entries
	json_url = 'time_entries.json'


	url = "https://#{@base_url}/#{json_url}?api_key=#{@api_key}&user_id=current&at=#{ARGV[0]}"
	uri = URI(url)

	@response = Net::HTTP.get(uri)

	times = Array.new

	time_entries_json=JSON.parse(@response)


	build_entries = Nokogiri::XML::Builder.new { |xml|
		xml.items {
			time_entries_json.each { |time_entry|
				times.push("#{time_entry['time_entry']['minutes']}")
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
				xml.item('uuid' => 'string', 'arg' => "https://#{@base_url}/time_entries/#{time_entry['time_entry']['id']}", 'type' => 'string') {
					xml.title("#{time_entry['time_entry']['project_name']} - #{time_entry['time_entry']['note'].split(' ')[0]}")
					xml.subtitle("#{time_entry['time_entry']['minutes']} Minutes as #{billable}")
				}
			}
		}
	}
	puts build_entries.to_xml
end



build_entries_empty = Nokogiri::XML::Builder.new { |xml|
	xml.items {
		xml.item('uuid' => 'string', 'arg' => "#{@base_url}", 'type' => 'string') {
			xml.title("No worklogs have been made at #{ARGV[0]}")
		}
	}
}


if @response == "[]"
	puts build_entries_empty.to_xml
end

if ARGV[0].nil?
	push_arg_types
elsif ! ARGV[0].nil? and ARGV[1].nil?
	push_entries
end
