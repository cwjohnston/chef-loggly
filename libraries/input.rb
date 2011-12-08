#
# Author:: Cameron Johnston <cameron@needle.com>
# Cookbook Name:: loggly
# Library:: input
#
# Copyright 2011 Needle, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'net/http'
require 'json'

module Opscode
  module Loggly
    module Input

      # retrieve a list of inputs for the specified domain
      # returns JSON formatted data
      def get_inputs(domain)
        Chef::Log.debug("Loggly/#{domain}: Retreiving list of inputs...")
        begin
          http = Net::HTTP.new("#{domain}.loggly.com")
          request = Net::HTTP::Get.new("/api/inputs/")
          request.basic_auth node[:loggly][:username], node[:loggly][:password]
          response = http.request(request)
          Chef::Log.debug("Loggly/#{domain}: Recieved data on the following inputs:")
          Chef::Log.debug(response.body.inspect)
          return JSON.parse(response.body)
        rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
               Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError, JSON::ParserError => e
          Chef::Log.error("Loggly/#{domain}: Error getting inputs from Loggly: #{e} ")
        end
      end
      
      # determine if a named input exists in a specified domain
      # returns true or nil
      def input_exists?(domain,input_name)
        answer = false
        get_inputs(domain).each do |input|
          if input["name"] == input_name
            answer = true
          end
        end
        return answer
      end
      
      # find the input id of an input in a specified domain given the input name
      # returns the input id
      def find_input_id(domain,input_name)
        Chef::Log.debug("Loggly/#{domain}: Looking up input id for input #{input_name}...")
        input_id = nil
        get_inputs(domain).each do |input|
          Chef::Log.debug("Loggly/#{domain}: Processing input #{input["name"]}...")
          if input["name"] == input_name
            input_id = input["id"]
            Chef::Log.debug("Loggly/#{domain}: Resolved input #{input_name} to input id #{input_id}.")
          end
          break unless input_id.nil?
        end
        return input_id
      end

      def find_input_port(domain,input_name)
        port = nil
        get_inputs(domain).each do |input|
          if input["name"] == input_name
            port = input["port"]
          end
        end
        return port
      end
 
      # create a new input of specified name and type
      # returns hash containing resulting input id and port number
      def create_input(domain,input_name,service_type,service_description) 
        new_input = { "id" => nil, "port" => nil }
        Chef::Log.debug("Loggly/#{domain}: Attempting to create input #{input_name} of type #{service_type}...")
        begin
          http = Net::HTTP.new("#{domain}.loggly.com")
          request = Net::HTTP::Post.new("/api/inputs/")
          request.basic_auth node[:loggly][:username], node[:loggly][:password]
          request.set_form_data({'name' => input_name, 'service' => service_type, 'description' => service_description})
          request.set_content_type("text/plain")
          response = JSON.parse(http.request(request).body)
          unless response["id"] == nil
            new_input["id"] = response["id"]
          end
          if service_type == "http" and response["port"].nil?
            new_input["port"] = 80
          else
            new_input["port"] = response["port"]
          end
          return new_input
        rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
          Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError, JSON::ParserError => e
          Chef::Log.error("Loggly/#{domain}: Error creating input #{input_name}: #{e}")
        end
      end

      def delete_input(domain,input_name)
        success = false
        input_id = nil
        if input_exists?(domain,input_name)
          input_id = find_input_id(domain,input_name)
          Chef::Log.debug("Loggly/#{domain}: Found input id #{input_id} for input #{input_name}.")
          Chef::Log.debug("Loggly/#{domain}: Attempting to delete input #{input_name}...")
          begin
            http = Net::HTTP.new("#{domain}.loggly.com")
            request = Net::HTTP::Delete.new("/api/inputs/#{input_id}")
            request.basic_auth node[:loggly][:username], node[:loggly][:password]
            response = http.request(request)
            if response.code == '204'
              Chef::Log.info("Loggly/#{domain}: Deleted input #{input_name}.")
              success = true
            end
            return success
          rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
            Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError => e
            Chef::Log.error("Loggly/#{domain}: Error deleting input #{input_name}: #{e}")
          end
        else
          Chef::Log.debug("Loggly/#{domain}: Could not find input #{input_name} so I won't try to delete it.")
        end
      end

    end
  end
end
