include GAHAProxyCookbook::Helpers

property :frontend_name, String, name_property: true
property :instance_name, String
property :socket, String
property :default_backend, String

default_action :enable

action :enable do
  instance = ResourceConfig.new(instance_name, endtype: :frontend, endname: frontend_name)

  template instance.fecfg do
    cookbook 'ga_haproxy'
    source 'frontends.cfg.erb'
    owner 'root'
    group 'root'
    mode '0644'
    variables(
      name: frontend_name,
      socket: socket,
      default_backend: default_backend
    )
    action :create
  end

  link instance.felink do
    to instance.fecfg
    link_type :symbolic
    owner 'root'
    group 'root'
    action :create
  end

  notifies_delayed(:restart, resources("ga_haproxy[#{instance_name}]"))
end

action :disable do
  instance = ResourceConfig.new(instance_name, endtype: :frontend, endname: frontend_name)

  link instance.felink do
    action :delete
  end

  notifies_delayed(:restart, resources("ga_haproxy[#{instance_name}]"))
end
