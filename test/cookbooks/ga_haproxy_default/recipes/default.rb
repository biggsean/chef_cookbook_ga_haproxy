#
# Cookbook Name:: ga_haproxy_default
# Recipe:: default
#
# Copyright (c) 2016 Sean McGowan, All Rights Reserved.
default_backends = {
  :'default-backend' => {
    options: [
      'balance roundrobin',
      'option httpchk HEAD / HTTP/1.1\r\nHost:localhost'
    ],
    servers: [
      app1: {
        socket: '127.0.0.1:5001',
        options: ['check']
      },
      app2: {
        socket: '127.0.0.1:5002',
        options: ['check']
      },
      app3: {
        socket: '127.0.0.1:5003',
        options: ['check']
      },
      app4: {
        socket: '127.0.0.1:5004',
        options: ['check']
      }
    ]
  },
  :'test-backend' => {
    servers: [
      app1: {
        socket: '127.0.0.1:5001',
        options: ['check']
      }
    ]
  }
}
default_frontends = {
  main: {
    ip: '*',
    port: '5000',
    default_backend: 'default-backend'
  },
  http: {
    ip: '*',
    port: '80',
    default_backend: 'test-backend'
  }
}
ga_haproxy 'default' do
  frontends default_frontends
  backends default_backends
end

test_frontends = {
  main: {
    ip: '*',
    port: '6000',
    default_backend: 'test-backend'
  }
}
ga_haproxy 'test' do
  frontends test_frontends
  backends default_backends
end
