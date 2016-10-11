# data for integration test
module SpecTestData
  # helper to return hash of data
  module Helpers
    def instances
      ['haproxy', 'haproxy-test']
    end

    def frontends(instance)
      case instance
      when 'haproxy'
        haproxy_frontends
      when 'haproxy-test'
        haproxy_test_frontends
      else {}
      end
    end

    def haproxy_frontends
      {
        main: { ip: '*', port: 5000, default_backend: 'default-backend' },
        http: { ip: '*', port: 80, default_backend: 'default-backend' }
      }
    end

    def haproxy_test_frontends
      {
        main: { ip: '*', port: 6000, default_backend: 'test-backend' },
        https: { ip: '*', port: 443, default_backend: 'test-backend', disabled: true }
      }
    end

    def backends(instance)
      case instance
      when 'haproxy'
        haproxy_backends
      when 'haproxy-test'
        haproxy_test_backends
      else {}
      end
    end

    def haproxy_backends
      {
        :'default-backend' => default_backend
      }
    end

    def haproxy_test_backends
      {
        :'default-backend' => default_backend,
        :'test-backend' => {
          servers: [{ app1: { socket: '127.0.0.1:5001', options: ['check'] } }],
          disabled: true
        }
      }
    end

    def default_backend
      {
        servers: default_backend_servers,
        options: [
          'balance roundrobin',
          'option httpchk HEAD / HTTP/1.1\r\nHost:localhost'
        ]
      }
    end

    def default_backend_servers
      [
        { app1: { socket: '127.0.0.1:5001', options: ['check'] } },
        { app2: { socket: '127.0.0.1:5002', options: ['check'] } },
        { app3: { socket: '127.0.0.1:5003', options: ['check'] } },
        { app4: { socket: '127.0.0.1:5004', options: ['check'] } }
      ]
    end
  end
end
