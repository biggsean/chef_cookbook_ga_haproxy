include GAHAProxyCookbook::Helpers

resource_name :ga_haproxy

property :instance_name, String, name_property: true
property :source_config_file, String, default: 'haproxy.cfg'

default_action :create

action :create do
  package package_name do
    action :install
  end

  template service_file(:instance_name) do
    source 'haproxy-default-service.erb'
    owner 'root'
    group 'root'
    mode '0755'
    variables(
      config_file(:instance_name) => cfg,
      service_file(:instance_name) => svc
    )
    action :create
  end

  cookbook_file config_file(:instance_name) do
    source :source_config_file
    owner 'root'
    group 'root'
    mode '0755'
    action :create
  end

  service haproxy_instance do
    action :start
  end
end
