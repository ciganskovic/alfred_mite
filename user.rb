#!/usr/bin/env ruby

require 'rubygems'
require 'net/http'
require 'nokogiri'
require 'json'
require 'yaml'
require 'time'

config = YAML.load_file('config.yml')

api_key  = config['api_key']
base_url = config['server_url']
json_url = 'myself.json'

url = "https://#{base_url}/#{json_url}?api_key=#{api_key}"
uri = URI(url)
response = Net::HTTP.get(uri)

user_json=JSON.parse(response)
user_hash=user_json['user']

user    = user_hash['name']
email   = user_hash['email']
userid  = user_hash['id']
role    = user_hash['role']
lang    = user_hash['language']
created = user_hash['created_at']

creation_date = Time.parse("#{created}").to_s.split(' ')[0]

items = [
	[ 'User'         , "#{user}" ]   ,
	[ 'User ID'      , "#{userid}"]  ,
	[ 'Role'         , "#{role}"]    ,
	[ 'eMail'        , "#{email}"]   ,
	[ 'Language'     , "#{lang}"]    ,
	[ 'Created User' , "#{creation_date}"]
]

build_xml = Nokogiri::XML::Builder.new { |xml|
	xml.items {
		items.each { |item|
			xml.item('uuid' => 'string', 'arg' => "#{item[1]}", 'type' => 'string') {
				xml.title("#{item[1]}")
				xml.subtitle("#{item[0]}")
				xml.valid('no')
			}
		}
	}
}

puts build_xml.to_xml
