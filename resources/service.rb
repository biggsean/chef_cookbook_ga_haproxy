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

  template i[:init] do
    cookbook 'ga_haproxy'
    source 'haproxy-default-service.erb'
    owner 'root'
    group 'root'
    mode '0755'
    variables(
      cfg: i[:cfg],
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
      fes: frontends,
      bes: backends,
      svc: i[:svc],
      pidfile: i[:pidfile],
      chroot: i[:chroot]
    )
    action :create
    notifies :restart, "service[#{i[:svc]}]", :delayed
  end

  service i[:svc] do
    action [:enable, :start]
  end
end
