#!/usr/bin/env ruby

require 'net/http'
require 'uri'
require 'json'
require 'nokogiri'
require 'yaml'


class Project

	def initialize(json_url, argument, type)
		@json_url = json_url
		@argument = argument
		@type     = type
		@config   = YAML.load_file('config.yml')
		@api_key  = @config['api_key']
		@base_url = @config['server_url']
	end


	def build_xml

		url = "https://#{@base_url}/#{@json_url}?api_key=#{@api_key}"
		uri = URI(url)

		response = Net::HTTP.get(uri)

		@type'_ids' = Array.new

		projects_json.each { |project|
			@Type'_ids'.push("#{project['project']['id']}")
		}
		@type = JSON.parse("#{response}")

		build_xml = Nokogiri::XML::Builder.new { |xml|
			xml.items {
				xml.item('uuid' => 'string', 'type' => 'string') {
					xml.icon('src/info.png')
					xml.title('Choose a project and Tab to autocomplete')
				}
				@type.each { |obj|
					if obj["project"]['name'].match(/#{@argument}/i)
						xml.item('uuid' => 'string', 'autocomplete' => "#{obj["project"]['id']}") {
							xml.title("#{obj["project"]['name']}")
							xml.subtitle("#{obj["project"]['id']}")
						}
					end
				}
			}
		}

		puts build_xml.to_xml
	end
end

class Service < Project
	def build_xml

		url = "https://#{@base_url}/#{@json_url}?api_key=#{@api_key}"
		uri = URI(url)

		response = Net::HTTP.get(uri)


		@type = JSON.parse("#{response}")

		build_xml = Nokogiri::XML::Builder.new { |xml|
			xml.items {
				xml.item('uuid' => 'string', 'type' => 'string') {
					xml.icon('src/info.png')
					xml.title('Choose a service and Tab to autocomplete')
				}
				@type.each { |obj|
					if obj["service"]['name'].match(/#{@argument}/i)
						xml.item('uuid' => 'string', 'autocomplete' => "#{ARGV[0]} #{obj["service"]['id']}") {
							xml.title("#{obj["service"]['name']}")
							xml.subtitle("Billable = #{obj['service']['billable']}")
						}
					end
				}
			}
		}

		puts build_xml.to_xml
	end
end

class Times

	def build_xml
		build_times = Nokogiri::XML::Builder.new { |xml|
			xml.items {
				xml.item('uuid' => 'string', 'type' => 'string') {
					xml.title('Choose a time and Tab to autocomplete')
				}
				(0..480).step(5) do |time|
					if time.to_s.match(/#{ARGV[2]}/)
						xml.item('uuid' => 'string', 'autocomplete' => "#{ARGV[0]} #{ARGV[1]} #{time}") {
							xml.title("#{time} Minutes")
						}
					end
				end
			}
		}
		puts build_times.to_xml
	end
end

class Comment

	def build_xml
		build_comment = Nokogiri::XML::Builder.new { |xml|
			xml.items {
				xml.item('uuid' => 'string', 'arg' => "#{ARGV[0]} #{ARGV[1]} #{ARGV[2]} #{ARGV[3]}") {
					xml.title('Type a comment within Quotes')
				}
			}
		}
		puts build_comment.to_xml
	end
end

projects = Project.new('projects.json', "#{ARGV[0]}", 'project')
services = Service.new('services.json', "#{ARGV[1]}", 'service')
times    = Times.new
comment  = Comment.new

if ARGV.empty?
	projects.build_xml
end

unless  ARGV[0].length >=6 and ARGV[1].nil?
	projects.build_xml
else
	if ARGV[1].nil?
	services.build_xml
	end
end

if !ARGV[0].nil? and ! ARGV[0].nil? and ARGV[2].nil?
	times.build_xml
end

