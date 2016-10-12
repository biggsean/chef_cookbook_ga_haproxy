include GAHAProxyCookbook::Helpers

property :backend_name, String, name_property: true
property :instance_name, String
property :servers, Array
property :options, Array

default_action :enable

action :enable do
  i = get_config(instance_name)
  cfgdir = "#{i[:dotd]}/backends"
  config = "#{cfgdir}/#{backend_name}"
  link = "#{cfgdir}/enabled/#{backend_name}"

  template config do
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

  link link do
    to config
    link_type :symbolic
    owner 'root'
    group 'root'
    action :create
  end

  notifies_delayed(:restart, resources("ga_haproxy[#{instance_name}]"))
end

action :disable do
  i = get_config(instance_name)
  cfgdir = "#{i[:dotd]}/backends"
  link = "#{cfgdir}/enabled/#{backend_name}"

  link link do
    action :delete
  end

  notifies_delayed(:restart, resources("ga_haproxy[#{instance_name}]"))
end
