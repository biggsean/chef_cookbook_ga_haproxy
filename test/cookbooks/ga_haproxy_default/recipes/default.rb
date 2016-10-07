#
# Cookbook Name:: ga_haproxy_default
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.
ga_haproxy 'default'

ga_haproxy 'test' do
  source_config_file 'haproxy.cfg'
end
