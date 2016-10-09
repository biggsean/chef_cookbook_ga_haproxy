Cookbook Name ga_haproxy
=========

This is a very basic install and configuration of haproxy, supporting multiple instances of haproxy.

Requirements
------------

Tested on chef 12.5.1 and CentOS 6.7


Example
-------
```
frontends = node['haproxy']['frontends']
backends = node['haproxy']['backends']
ga_haproxy 'default' do
  frontends frontends
  backends backends
  action :create
end
```

Attributes
```
default['haproxy']['frontends'] = {
  main: {
    ip: '*',
    port: 80,
    default_backend: 'google'
  }
}
default['haproxy']['backends'] = {
  google: {
    servers: [
      google1: {
        socket: 'www.google.com:80',
        options: ['check']
      }
    ],
    options: [
      'option  httpchk  HEAD / HTTP/1.1\r\nHost:\ www.google.com',
      'http-request set-header Host www.google.com',
      'http-request set-header User-Agent GoogleProxy'
    ]
  }
}
```


