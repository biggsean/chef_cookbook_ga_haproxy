include GAHAProxyCookbook::Helpers

property :frontend_name, String, name_property: true
property :instance_name, String
property :socket, String
property :default_backend, String

default_action :enable

action :enable do
  i = get_config(instance_name)
  cfgdir = "#{i[:dotd]}/frontends"
  config = "#{cfgdir}/#{frontend_name}"
  link = "#{cfgdir}/enabled/#{frontend_name}"

  template config do
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

  link link do
    to config
    link_type :symbolic
    owner root
    group root
    action :create
  end

  notifies_delayed(:restart, resources("ga_haproxy[#{instance_name}]"))
end

action :disable do
  i = get_config(instance_name)
  cfgdir = "#{i[:dotd]}/frontends"
  link = "#{cfgdir}/enabled/#{frontend_name}"

  link link do
    action :delete
  end

  notifies_delayed(:restart, resources("ga_haproxy[#{instance_name}]"))
end
