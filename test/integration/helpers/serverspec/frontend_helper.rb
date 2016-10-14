# Module for data for integration tests
module SpecTestData
  # Helper functions
  module Helpers
    def haproxy_frontends
      frontend_main.merge(frontend_http)
    end

    def haproxy_test_frontends
      frontend_test_main.merge(frontend_https)
    end

    def frontend_http
      { http: { ip: '*', port: 80, default_backend: 'http-backend' } }
    end

    def frontend_https
      { https: { ip: '*', port: 443, default_backend: 'https-backend', disabled: true } }
    end

    def frontend_main
      { main: { ip: '*', port: 5000, default_backend: 'main-backend' } }
    end

    def frontend_test_main
      { :'test-main' => { ip: '*', port: 6000, default_backend: 'test-main-backend' } }
    end

    # configuration class
    class HAProxyInstance
      def frontend(name)
        @frontends[name]
      end

      def frontends
        @frontends.values
      end

      private

      def create_frontends(fes)
        fe_hash = {}
        fes.each do |name, fe|
          fe_hash.merge!(name => HAProxyFrontend.new(name, fe))
        end
        fe_hash
      end
    end
    # frontend class
    class HAProxyFrontend
      attr_reader :name, :ip, :port, :socket, :default_backend, :disabled

      def initialize(name, options)
        @name = name
        @ip = options[:ip]
        @port = options[:port]
        @socket = "#{options[:ip]}:#{options[:port]}"
        @default_backend = options[:default_backend]
        @disabled = options[:disabled] || false
      end
    end
  end
end
