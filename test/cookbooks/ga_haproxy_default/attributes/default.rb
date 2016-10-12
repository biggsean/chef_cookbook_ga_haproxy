default['haproxy']['default']['frontends']['main'] =
  { socket: '*:5000', default_backend: 'default-backend' }

default['haproxy']['default']['frontends']['http'] =
  { socket: '*:80', default_backend: 'default-backend' }

default['haproxy']['test']['frontends']['main'] =
  { socket: '*:6000', default_backend: 'test-backend' }

default['haproxy']['test']['frontends']['https'] =
  { socket: '*:443', default_backend: 'test-backend' }

default['haproxy-shared']['default-backend']['servers'] = [
  { name: 'app1', socket: '127.0.0.1:5001', options: ['check'] },
  { name: 'app2', socket: '127.0.0.1:5002', options: ['check'] },
  { name: 'app3', socket: '127.0.0.1:5003', options: ['check'] },
  { name: 'app4', socket: '127.0.0.1:5004', options: ['check'] }
]

default['haproxy']['shared']['default-backend']['options'] = [
  'balance roundrobin',
  'option httpchk HEAD / HTTP/1.1\r\nHost:localhost'
]

default['haproxy-shared']['test-backend']['servers'] = [
  { name: 'app1', socket: '127.0.0.1:5001', options: ['check'] }
]
