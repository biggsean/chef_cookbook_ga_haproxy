# Module for data for integration tests
module SpecTestData
  # Helper functions
  module Helpers
    def haproxy_backends
      backend_main.merge(backend_http)
    end

    def haproxy_test_backends
      backend_test_main.merge(backend_https)
    end

    def backend_http
      { :'http-backend' => backend_test }
    end

    def backend_https
      { :'https-backend' => backend_test.merge(disabled: true) }
    end

    def backend_main
      { :'main-backend' => backend_default }
    end

    def backend_test_main
      { :'test-main-backend' => backend_test }
    end

    def backend_default
      backend_default_servers.merge(backend_default_options)
    end

    def backend_default_servers
      { servers: [
        { name: 'app1', socket: '127.0.0.1:5001', options: ['check'] },
        { name: 'app2', socket: '127.0.0.1:5002', options: ['check'] },
        { name: 'app3', socket: '127.0.0.1:5003', options: ['check'] },
        { name: 'app4', socket: '127.0.0.1:5004', options: ['check'] }
      ]
      }
    end

    def backend_default_options
      {
        options: [
          'balance roundrobin',
          'option httpchk HEAD / HTTP/1.1\r\nHost:localhost'
        ]
      }
    end

    def backend_test
      { servers: [{ name: 'app1', socket: '127.0.0.1:5001', options: ['check'] }] }
    end

    # configuration class
    class HAProxyInstance
      def backend(name)
        @backends[name]
      end

      def backends
        @backends.values
      end

      private

      def create_backends(bes)
        be_hash = {}
        bes.each do |name, be|
          be_hash.merge!(name => HAProxyBackend.new(name, be))
        end
        be_hash
      end
    end
    # backend class
    class HAProxyBackend
      attr_reader :name, :servers, :options, :disabled

      def initialize(name, options)
        @name = name
        @servers = options[:servers]
        @options = options[:options] ? options[:options] : []
        @disabled = options[:disabled] || false
      end
    end
  end
end
