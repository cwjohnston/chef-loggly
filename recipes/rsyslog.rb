class Chef::Recipe
  include Opscode::Loggly::Input
end

service "rsyslog"

environment = node.chef_environment
protocol = node[:loggly][:syslog_protocol]

port = find_input_port(node[:loggly][:domain],"#{environment}-syslog")

if node.has_key?('ec2')
  device_ip = node[:ec2][:local_ipv4]
  loggly_endpoint = "ec2.logs.loggly.com"
else
  device_ip = node[:ipaddress]
  loggly_endpoint = "logs.loggly.com"
end

loggly_input "#{environment}-syslog" do
  domain node[:loggly][:domain]
  type "syslog#{protocol}"
  description "syslog messages from nodes in the #{environment} environment"
  action :create
end

loggly_device device_ip do
  domain node[:loggly][:domain]
  input "#{environment}-syslog"
  action :add
end

template "/etc/rsyslog.d/loggly.conf" do
  source "rsyslog-forwarding.conf.erb"
  backup false
  variables(
    :protocol => protocol,
    :server => loggly_endpoint,
    :port => port
  )
  owner "root"
  group "root"
  mode 0644
  notifies :restart, resources(:service => "rsyslog"), :delayed
end
