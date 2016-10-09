require 'yaml'

# data for integration test
# rubocop:disable Metrics/ModuleLength
module SpecTestData
  # helper to return hash of data
  module Helpers
    # rubocop:disable Metrics/MethodLength
    def instances
      {
        haproxy: {
          frontends: {
            main: {
              ip: '*',
              port: 5000,
              default_backend: 'default-backend'
            },
            http: {
              ip: '*',
              port: 80,
              default_backend: 'test-backend'
            }
          },
          backends: {
            :'default-backend' => {
              options: [
                'balance roundrobin',
                'option httpchk HEAD / HTTP/1.1\r\nHost:localhost'
              ],
              servers: [
                {
                  app1: {
                    socket: '127.0.0.1:5001',
                    options: ['check']
                  }
                },
                {
                  app2: {
                    socket: '127.0.0.1:5002',
                    options: ['check']
                  }
                },
                {
                  app3: {
                    socket: '127.0.0.1:5003',
                    options: ['check']
                  }
                },
                {
                  app4: {
                    socket: '127.0.0.1:5004',
                    options: ['check']
                  }
                }
              ]
            },
            :'test-backend' => {
              servers: [
                {
                  app1: {
                    socket: '127.0.0.1:5001',
                    options: ['check']
                  }
                }
              ]
            }
          }
        },

        :'haproxy-test' => {
          frontends: {
            main: {
              ip: '*',
              port: 6000,
              default_backend: 'test-backend'
            }
          },
          backends: {
            :'default-backend' => {
              options: [
                'balance roundrobin',
                'option httpchk HEAD / HTTP/1.1\r\nHost:localhost'
              ],
              servers: [
                {
                  app1: {
                    socket: '127.0.0.1:5001',
                    options: ['check']
                  }
                },
                {
                  app2: {
                    socket: '127.0.0.1:5002',
                    options: ['check']
                  }
                },
                {
                  app3: {
                    socket: '127.0.0.1:5003',
                    options: ['check']
                  }
                },
                {
                  app4: {
                    socket: '127.0.0.1:5004',
                    options: ['check']
                  }
                }
              ]
            },
            :'test-backend' => {
              servers: [
                {
                  app1: {
                    socket: '127.0.0.1:5001',
                    options: ['check']
                  }
                }
              ]
            }
          }
        }
      }
    end
    # rubocop:enable Metrics/MethodLength
  end
end
# rubocop:enable Metrics/ModuleLength
