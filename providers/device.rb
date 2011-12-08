#
# Author:: Cameron Johnston <cameron@needle.com>
# Cookbook Name:: loggly
# Provider:: device
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

include Opscode::Loggly::Device
include Opscode::Loggly::Input

action :add do
  if device_exists?(new_resource.domain, new_resource.input, new_resource.name)
    Chef::Log.warn("Loggly/#{new_resource.domain}: Device #{new_resource.name} is already added to input #{new_resource.input}, so I will not attempt to add it again.")
  else
    Chef::Log.debug("Loggly/#{new_resource.domain}: Attempting to add device #{new_resource.name} to input #{new_resource.input}...")
    device_id = add_device(new_resource.domain, new_resource.input, new_resource.name)
    sleep(rand(5)) # give the service a few seconds to catch up
    Chef::Log.debug("Loggly/#{new_resource.domain}: Verifying that device #{new_resource.name} was added to input #{new_resource.input}...")
    if device_exists?(new_resource.domain, new_resource.input, new_resource.name)
      Chef::Log.info("Loggly/#{new_resource.domain}: Adding device #{new_resource.name} to input #{new_resource.input} succeded, device id is #{device_id}.")
    else
      Chef::Log.error("Loggly/#{new_resource.domain}: The attempt to add device #{new_resource.name} to input #{new_resource.input} did not result in an error, nor does the new device seem to exist.")
    end
  end
end

action :delete do
  if device_exists?(new_resource.domain, new_resource.input, new_resource.name)
    delete_device(new_resource.domain, new_resource.input, new_resource.name)
    sleep(rand(5))
    Chef::Log.debug("Loggly/#{new_resource.domain}: Verifying that the device #{new_resource.name} was successfully deleted from input #{new_resource.input}...")
    if device_exists?(new_resource.domain, new_resource.input, new_resource.name)
      Chef::Log.error("Loggly/#{new_resource.domain}: The attempt to delete device #{new_resource.name} from input #{new_resource.input} did not result in an error, but the device still seems to be associated with that input.")
    else
      Chef::Log.info("Loggly/#{new_resource.domain}: Successfully deleted device #{new_resource.name} from input #{new_resource.input}.")
    end
  else
    Chef::Log.warn("Loggly/#{new_resource.domain}: Device #{new_resource.name} does not exist on input #{new_resource.input} so I will not attempt to delete it.")
  end
end
