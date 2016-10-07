#
# Cookbook Name:: ga_haproxy_default
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.
default_frontends = {
  'main' => {
    'ip' => '*',
    'port' => '5000'
  }
}
ga_haproxy 'default' do
  frontends default_frontends
end

test_frontends = {
  'main' => {
    'ip' => '*',
    'port' => '6000'
  }
}
ga_haproxy 'test' do
  frontends test_frontends
end
