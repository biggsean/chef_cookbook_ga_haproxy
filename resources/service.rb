include GAHAProxyCookbook::Helpers

resource_name :ga_haproxy

property :instance_name, String, name_property: true
property :source_config_file, String

default_action :create

action :create do
  instance = haproxy_instance(instance_name)

  package package_name do
    action :install
  end

  directory "/var/lib/#{instance}" do
    owner 'haproxy'
    group 'haproxy'
    mode '0755'
    action :create
  end

  template service_file(instance_name) do
    cookbook 'ga_haproxy'
    source 'haproxy-default-service.erb'
    owner 'root'
    group 'root'
    mode '0755'
    variables(
      cfg: config_file(instance_name),
      svc: instance
    )
    action :create
  end

  use_this_cb = !property_is_set?(:source_config_file)
  cookbook_file config_file(instance_name) do
    cookbook 'ga_haproxy' if use_this_cb
    source 'haproxy.cfg'
    owner 'root'
    group 'root'
    mode '0644'
    action :create
    notifies :restart, "service[#{instance}]", :delayed
  end

  service instance do
    action [:enable, :start]
  end
end
