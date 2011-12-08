actions :create, :delete

attribute :domain, :kind_of => String
attribute :username, :kind_of => String
attribute :password, :kind_of => String
attribute :name, :kind_of => String
attribute :description, :kind_of => String, :default => "Input automatically created by Chef"
attribute :type, :kind_of => String, :equal_to => [ "http", "syslogudp", "syslogtcp", "syslog_tls", "syslogtcp_strip", "syslogudp_strip" ]
