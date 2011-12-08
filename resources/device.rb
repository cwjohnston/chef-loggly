actions :add, :delete

attribute :domain, :kind_of => String
attribute :username, :kind_of => String
attribute :password, :kind_of => String
attribute :input, :kind_of => String
attribute :device, :kind_of => String, :regex => /^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})?$/
