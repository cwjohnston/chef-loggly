#
# Author:: Cameron Johnston <cameron@needle.com>
# Cookbook Name:: loggly
# Provider:: input
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

include Opscode::Loggly::Input

action :create do
  unless input_exists?(new_resource.domain, new_resource.name)
    create_input(new_resource.domain, new_resource.name, new_resource.type, new_resource.description)
    sleep(rand(5))
    Chef::Log.debug("Loggly/#{new_resource.domain}: Verifying that input #{new_resource.name} was created successfully...") 
    if input_exists?(new_resource.domain, new_resource.name)
      Chef::Log.info("Loggly/#{new_resource.domain}: Created input #{new_resource.name} of type #{new_resource.type}.")
    else
      Chef::Log.error("Loggly/#{new_resource.domain}: Attempted creation of input #{new_resource.name}, type #{new_resource.type} did not result in an error, but the new input does not seem to exist either.")
    end
  else
    Chef::Log.debug("Loggly/#{new_resource.domain}: Input #{new_resource.name} already exists, so I will not try to create it.")
  end
end

action :delete do
  if input_exists?(new_resource.domain, new_resource.name)
    Chef::Log.debug("Loggly/#{new_resource.domain}: Attempting to delete input #{new_resource.name} of type #{new_resource.type}...")
    delete_input(new_resource.domain, new_resource.name)
    sleep(rand(5))
    Chef::Log.debug("Loggly/#{new_resource.domain}: Verifying that input #{new_resource.name} was deleted successfully...")
    if input_exists?(new_resource.domain, new_resource.name)
       Chef::Log.error("Loggly/#{new_resource.domain}: Attempted deletion of input #{new_resource.name}, type #{new_resource.type}, did not result in an error, but the input still seems to exist.")
    end
  else
    Chef::Log.debug("Loggly/#{new_resource.domain}: Input #{new_resource.name} of type #{new_resource.type} does not exist, so I will not try to delete it.")
  end
end
