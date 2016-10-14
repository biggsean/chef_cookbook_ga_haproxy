include GAHAProxyCookbook::Helpers

property :backend_name, String, name_property: true
property :instance_name, String
property :servers, Array
property :options, [Array, nil]

default_action :enable

action :enable do
  instance = ResourceConfig.new(instance_name, endtype: :backend, endname: backend_name)

  template instance.becfg do
    cookbook 'ga_haproxy'
    source 'backends.cfg.erb'
    owner 'root'
    group 'root'
    mode '0644'
    variables(
      name: backend_name,
      servers: servers,
      options: options
    )
    action :create
  end

  link instance.belink do
    to instance.becfg
    link_type :symbolic
    owner 'root'
    group 'root'
    action :create
  end

  notifies_delayed(:restart, resources("ga_haproxy[#{instance_name}]"))
end

action :disable do
  instance = ResourceConfig.new(instance_name, endtype: :backend, endname: backend_name)

  link instance.belink do
    action :delete
  end

  notifies_delayed(:restart, resources("ga_haproxy[#{instance_name}]"))
end
