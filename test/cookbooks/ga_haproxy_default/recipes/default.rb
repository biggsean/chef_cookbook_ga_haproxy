#
# Cookbook Name:: ga_haproxy_default
# Recipe:: default
#
# Copyright (c) 2016 Sean McGowan, All Rights Reserved.
node['haproxy'].each do |instance_name, instance|
  ga_haproxy instance_name

  instance['frontends'].each do |fe_name, frontend|
    ga_haproxy_frontend fe_name do
      instance_name instance_name
      socket frontend['socket']
      default_backend frontend['default_backend']
      action enable
    end
  end

  node['haproxy-shared'].each do |be_name, backend|
    ga_haproxy_backend be_name do
      instance_name instance_name
      servers backend['servers']
      options backend['options']
      action enable
    end
  end
end

ga_haproxy_frontend 'https' do
  instance_name 'test'
  action disable
end

ga_haproxy_backend 'default-backend' do
  instance_name 'test'
  action disable
end
