require 'frontend_helper'
require 'backend_helper'

# Module for data for integration tests
module SpecTestData
  # Helper functions
  module Helpers
    def instances
      [
        HAProxyInstance.new('haproxy', frontends: haproxy_frontends, backends: haproxy_backends),
        HAProxyInstance.new('haproxy-test', frontends: haproxy_test_frontends, backends: haproxy_test_backends)
      ]
    end

    def package_name
      'haproxy'
    end

    def haproxy_basedir
      '/etc/haproxy'
    end

    # configuration class
    class HAProxyInstance
      BASEDIR = '/etc/haproxy'.freeze
      SERVICEFILE = '/etc/init.d/%s'.freeze
      CFG = BASEDIR + '/%s.cfg'.freeze
      PIDFILE = '/var/run/%s.pid'.freeze
      LOCKFILE = '/var/lock/subsys/%s'.freeze
      DOTDIR = BASEDIR + '/%s.d'.freeze
      CHROOTDIR = '/var/lib/%s'.freeze
      STATSSOCKET = CHROOTDIR + '/stats'.freeze

      FEDIR = DOTDIR + '/frontends'.freeze
      BEDIR = DOTDIR + '/backends'.freeze
      FELINKDIR = FEDIR + '/enabled'.freeze
      BELINKDIR = BEDIR + '/enabled'.freeze
      FECFG = FEDIR + '/%s.cfg'.freeze
      BECFG = BEDIR + '/%s.cfg'.freeze
      FELINK = FEDIR + '/enabled/%s.cfg'.freeze
      BELINK = BEDIR + '/enabled/%s.cfg'.freeze

      attr_reader :pidfile, :lockfile, :chrootdir, :statssocket,
                  :servicefile, :cfg, :dotdir, :fedir, :bedir,
                  :felinkdir, :belinkdir, :name

      def initialize(instance_name, options = {})
        @name = instance_name
        @options = options
        make_instance_specific_vars
        @frontends = create_frontends(options[:frontends])
        @backends = create_backends(options[:backends])
      end

      def config_dirs
        [@dotdir, @fedir, @bedir, @felinkdir, @belinkdir]
      end

      private

      def format_instance_name(instance_name)
        case instance_name
        when 'default'
          'haproxy'
        else "haproxy-#{instance_name}"
        end
      end

      def make_instance_specific_vars
        vars = %w(pidfile lockfile chrootdir statssocket servicefile cfg dotdir fedir bedir felinkdir belinkdir)
        vals = [PIDFILE, LOCKFILE, CHROOTDIR, STATSSOCKET, SERVICEFILE, CFG, DOTDIR, FEDIR, BEDIR, FELINKDIR, BELINKDIR]
        vars.zip(vals).each do |var, val|
          instance_variable_set("@#{var}", format(val, @name))
        end
      end
    end
  end
end
