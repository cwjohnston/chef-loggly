#
# Author:: Cameron Johnston <cameron@needle.com>
# Cookbook Name:: loggly
# Library:: device
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
    module Device

      def get_devices(domain,input_name)
        input_id = find_input_id(domain,input_name)
        unless input_id.nil?
          devices = nil
          begin
            http = Net::HTTP.new("#{domain}.loggly.com")
            request = Net::HTTP::Get.new("/api/inputs/#{input_id}/")
            request.basic_auth node[:loggly][:username], node[:loggly][:password]
            response = JSON.parse(http.request(request).body)
            if response.has_key?("devices")
              devices = response["devices"]
              Chef::Log.debug("Loggly/#{domain}: Parsed the following device ids from input #{input_name}:")
              Chef::Log.debug(devices.inspect)
            end
            return devices
          rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
            Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError, JSON::ParserError => e
            Chef::Log.error("Loggly/#{domain}: Error retreiving devices: #{e}")
          end
        else
          Chef::Log.error("Loggly/#{domain}: Failed to query devices on input #{input_name}, does the input exist?")
          raise
        end
      end

      # determine if a device exists
      def device_exists?(domain,input_name,device_ip)
        Chef::Log.debug("Loggly/#{domain}: Checking to see if device IP #{device_ip} exists on input #{input_name}...")
        answer = false
        devices = get_devices(domain,input_name)
        unless devices.nil?
          devices.each do |device|
            if device.has_value?(device_ip)
              Chef::Log.debug("Loggly/#{domain}: Found existing device for IP #{device_ip} on input #{input_name}.")
              answer = true
            else
              Chef::Log.debug("Loggly/#{domain}: Did not find existing device for IP #{device_ip} on input #{input_name}.")
            end
          end
        end
        return answer
      end

      # find the node's device id for a given domain and input_name
      def find_device_id(domain,input_name,device_ip)
        Chef::Log.debug("Loggly/#{domain}: Attempting to find device id for device #{device_ip} on input #{input_name}")
        input_id = find_input_id(domain,input_name)
        get_devices(domain,input_name).each do |device|
          if device.has_value?(device_ip)
            Chef::Log.debug("Loggly/#{domain}: Found id #{device["id"]} for device #{device_ip}")
            return device["id"]
          end
        end
      end

      # add the node as a device on the specified domain and input_name
      # returns the resulting device id
      def add_device(domain,input_name,device_ip)
        input_id = find_input_id(domain,input_name)
        begin
          Chef::Log.debug("Loggly/#{domain}: Attempting to add device #{device_ip} to input #{input_name}...")
          http = Net::HTTP.new("#{domain}.loggly.com")
          request = Net::HTTP::Post.new("/api/devices/")
          request.set_form_data({'input_id' => input_id, 'ip' => device_ip})
          request.set_content_type("text/plain")
          request.basic_auth node[:loggly][:username], node[:loggly][:password]
          response = http.request(request)
          parsed_response = JSON.parse(http.request(request).body)
          Chef::Log.debug("Loggly/#{domain}: Received response code #{response.code}.")
          unless response["id"].nil?
            Chef::Log.info("Loggly/#{domain}: Added device #{device_ip} on input #{input_name} as device id #{parsed_response["id"]}.")
          end
          return response["id"]
        rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
          Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError, JSON::ParserError => e
          Chef::Log.error("Loggly/#{domain}: Error adding node to input #{input_name}: #{e}")
        end
      end

      def delete_device(domain,input_name,device_ip) #FIXME find a way to delete specified device from specified input only
        success = false
        input_id = nil
        Chef::Log.debug("Loggly/#{domain}: Attempting to delete device #{device_ip} from input #{input_name}...")
        input_id = find_input_id(domain,input_name)
        device_id = find_device_id(domain,input_name,device_ip)
        Chef::Log.debug("Loggly/#{domain}: Sending delete request for device id #{device_id} on input #{input_name}")
        begin
          http = Net::HTTP.new("#{domain}.loggly.com")
          request = Net::HTTP::Delete.new("/api/devices/#{device_id}/")
          request.basic_auth node[:loggly][:username], node[:loggly][:password]
          response = http.request(request)
          Chef::Log.debug("Loggly/#{domain}: Received response code #{response.code}.")
          if response.code == '204'
            Chef::Log.info("Loggly/#{domain}: Deleted device id #{device_id} from #{input_name}.")
            success = true
          end
          return success
        rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
          Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError => e
          Chef::Log.error("Loggly/#{domain}: Error deleting device #{device_ip} on input #{input_name}: #{e}")
        end
      end

    end
  end
end
