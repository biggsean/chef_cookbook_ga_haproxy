include GAHAProxyCookbook::Helpers

resource_name :ga_haproxy

property :instance_name, String, name_property: true
property :frontends, Hash
property :backends, Hash

default_action :create

action :create do
  instance = ResourceConfig.new(instance_name)

  package instance.package_name do
    action :install
  end

  directory instance.chrootdir do
    owner 'haproxy'
    group 'haproxy'
    mode '0755'
    action :create
  end

  instance.config_dirs.each do |dir|
    directory dir do
      owner 'root'
      group 'root'
      mode '0755'
      action :create
    end
  end

  template instance.servicefile do
    cookbook 'ga_haproxy'
    source 'haproxy-default-service.erb'
    owner 'root'
    group 'root'
    mode '0755'
    variables(
      cfg: instance.cfg,
      dotd: instance.dotdir,
      svc: instance.name,
      pidfile: instance.pidfile
    )
    action :create
  end

  template instance.cfg do
    cookbook 'ga_haproxy'
    source 'haproxy.cfg.erb'
    owner 'root'
    group 'root'
    mode '0644'
    variables(
      svc: instance.name,
      pidfile: instance.pidfile,
      chroot: instance.chrootdir
    )
    action :create
  end

  service instance.name do
    action [:enable]
  end

  notifies_delayed(:restart, resources("ga_haproxy[#{instance_name}]"))
end

action :restart do
  instance = ResourceConfig.new(instance_name)

  service instance.name do
    action [:restart]
  end
end
