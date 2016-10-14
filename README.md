Cookbook Name ga_haproxy
=========

This is a very basic install and configuration of haproxy, supporting multiple instances of haproxy.

It configures haproxy to load with multiple configuration files.
* /etc/haproxy/_instance_.cfg          # Global configurations
* /etc/haproxy/_instance_.d/frontends  # Frontend configurations
* /etc/haproxy/_instance_.d/backends   # Backend configurations

Requirements
------------

Tested on chef 12.5.1 and CentOS 6.7

Resources
---------
### ga_haproxy
#### Actions
* `:create` Create a haproxy service (default)
* `:restart` Restart the haproxy service

#### Properties
* `instance_name` _String_ Name of the service (name property)

```
ga_haproxy 'servicename'
```

### ga_haproxy_frontend
#### Actions
* `:enable` Enable a frontend for an existing haproxy service (default)
* `:disable` Disable a frontend for an existing haproxy service

#### Properties
* `frontend_name` _String_ Name of the frontend (name property)
* `instance_name` _String_ The instance with which it is associated
* `socket` _String_ The socket on which to listen
* `default_backend` _String_ The default_backend haproxy directive.

```
ga_haproxy_frontend 'frontend-foo'
  instance_name 'servicename'
  socket '*:80'
  default_backend 'backend-foo'
  action :enable
```
*OR*
```
ga_haproxy_frontend 'frontend-foo'
  action :disable
```

### ga_haproxy_backend
#### Actions
* `:enable` Enable a backend for an existing haproxy service (default)
* `:disable` Disable a backend for an existing haproxy service

#### Properties
* `backend_name` _String_ Name of the backend (name property)
* `instance_name` _String_ The instance with which it is associated
* `servers` _Array_ The servers for the backend.
* `options` _[Array, nil]_ Additional options for the backend. (optional)j

```
servers = [
  { 
    name: 'servername1',
    socket: '127.0.0.1:5001',
    options: ['check']
  }
]
options = [
  'balance roundrobin'
]
ga_haproxy_backend 'backend-foo'
  instance_name 'servicename'
  servers servers
  options options
  action :enable
```
*OR*
```
ga_haproxy_backend 'backend-foo'
  action :disable
```
