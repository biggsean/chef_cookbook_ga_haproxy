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

  [i[:chroot], i[:dotd], "#{i[:dotd]}/frontends", "#{i[:dotd]}/backends"].each do |dir|
    directory dir do
      owner 'haproxy'
      group 'haproxy'
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
    notifies :restart, "service[#{i[:svc]}]", :delayed
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

  [{ type: 'frontends', data: frontends }, { type: 'backends', data: backends }].each do |ends|
    ends[:data].each do |name, theend|
      template "#{i[:dotd]}/#{ends[:type]}/#{name}.cfg" do
        cookbook 'ga_haproxy'
        source "#{ends[:type]}.cfg.erb"
        owner 'root'
        group 'root'
        mode '0644'
        variables(
          name: name,
          theend: theend
        )
        action :create
        notifies :restart, "service[#{i[:svc]}]", :delayed
      end
    end
  end

  service i[:svc] do
    action [:enable, :start]
  end
end
