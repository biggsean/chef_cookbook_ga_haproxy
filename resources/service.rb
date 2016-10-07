include GAHAProxyCookbook::Helpers

resource_name :ga_haproxy

property :instance_name, String, name_property: true
property :frontends, Hash

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

  template config_file(instance_name) do
    cookbook 'ga_haproxy'
    source 'haproxy.cfg.erb'
    owner 'root'
    group 'root'
    mode '0644'
    variables(
      fes: frontends,
      svc: instance
    )
    action :create
    notifies :restart, "service[#{instance}]", :delayed
  end

  service instance do
    action [:enable, :start]
  end
end
