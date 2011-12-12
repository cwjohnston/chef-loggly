Loggly Cookbook
====================
This cookbook provides an LWRP for managing Loggly inputs and devices. 

Cookbook written and maintained by Cameron Johnston of Needle Inc., <http://github.com/cwjohnston/chef-loggly/>

Requirements
--------------------
* Loggly account

Attributes
--------------------
Required:

* `loggly.domain` - Loggly domain (e.g., "mysite.loggly.com")
* `loggly.username` - Loggly username
* `loggly.password` - Loggly password

JSON example:

    "loggly": {
      "username": "lumberjack",
      "password": "thatsok",
      "domain": "logtown"
    }


Usage
--------------------
Example:

    loggly_input "production-syslog" do
        domain node[:loggly][:domain]
        type "syslogtcp"
        description "syslog messages from production nodes"
        action :create
    end

    loggly_device node[:ipaddress] do
        domain node[:loggly][:domain]
        input "production-syslog"
        action :add
    end

Contributing
--------------------
Want to contribute?  Fork the GitHub repository, apply your changes in a topic branch and send a pull request.
I'll review, merge, and publish the changes. If you have any questions, email <cameron@needle.com>.


License
--------------------

    Copyright 2011 Needle Inc.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
