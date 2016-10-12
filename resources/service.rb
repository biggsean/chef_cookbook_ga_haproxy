include GAHAProxyCookbook::Helpers

resource_name :ga_haproxy

property :instance_name, String, name_property: true
property :frontends, Hash
property :backends, Hash

default_action :create

action :create do
  i = get_config(instance_name)

  package package_name do
    action :install
  end

  directory i[:chroot] do
    owner 'haproxy'
    group 'haproxy'
    mode '0755'
    action :create
  end

  directory i[:dotd] do
    owner 'root'
    group 'root'
    mode '0755'
    action :create
  end

  %w(frontends backends).each do |leaf|
    dir = "#{i[:dotd]}/#{leaf}"
    directory dir do
      owner 'root'
      group 'root'
      mode '0755'
      action :create
    end

    linkdir = "#{dir}/enabled"
    directory linkdir do
      owner 'root'
      group 'root'
      mode '0755'
      action :create
    end
  end

  template i[:init] do
    cookbook 'ga_haproxy'
    source 'haproxy-default-service.erb'
    owner 'root'
    group 'root'
    mode '0755'
    variables(
      cfg: i[:cfg],
      dotd: i[:dotd],
      svc: i[:svc],
      pidfile: i[:pidfile]
    )
    action :create
  end

  template i[:cfg] do
    cookbook 'ga_haproxy'
    source 'haproxy.cfg.erb'
    owner 'root'
    group 'root'
    mode '0644'
    variables(
      svc: i[:svc],
      pidfile: i[:pidfile],
      chroot: i[:chroot]
    )
    action :create
  end

  service i[:svc] do
    action [:enable]
  end

  notifies_delayed(:restart, resources("ga_haproxy[#{instance_name}]"))
end

action :restart do
  i = get_config(instance_name)

  service i[:svc] do
    action [:restart]
  end
end
