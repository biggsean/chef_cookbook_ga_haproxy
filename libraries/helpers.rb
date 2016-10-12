# Provide custom resources with common methods
module GAHAProxyCookbook
  # Helper functions
  module Helpers
    # configuration class
    class ResourceConfig
      PACKAGE_NAME = 'haproxy'.freeze
      PIDFILE = '/var/run/%s.pid'.freeze
      CHROOTDIR = '/var/lib/%s'.freeze
      SERVICEFILE = '/etc/init.d/%s'.freeze
      BASEDIR = '/etc/haproxy'.freeze
      CFG = BASEDIR + '/%s.cfg'.freeze
      DOTDIR = BASEDIR + '/%s.d'.freeze
      FEDIR = DOTDIR + '/frontends'.freeze
      BEDIR = DOTDIR + '/backends'.freeze
      FELINKDIR = FEDIR + '/enabled'.freeze
      BELINKDIR = BEDIR + '/enabled'.freeze
      FECFG = FEDIR + '/%s.cfg'.freeze
      BECFG = BEDIR + '/%s.cfg'.freeze
      FELINK = FEDIR + '/enabled/%s.cfg'.freeze
      BELINK = BEDIR + '/enabled/%s.cfg'.freeze

      attr_reader :package_name, :basedir, :pidfile, :chrootdir,
                  :servicefile, :cfg, :dotdir, :fedir, :bedir,
                  :felinkdir, :belinkdir, :fecfg, :becfg, :felink,
                  :belink, :name

      def initialize(instance_name, options = {})
        @name = format_instance_name(instance_name)
        @package_name = PACKAGE_NAME
        @basedir = BASEDIR
        make_instance_specific_vars
        return unless options[:endtype] && options[:endname]
        make_end_specific_vars(options)
      end

      def config_dirs
        [@basedir, @dotdir, @fedir, @bedir, @felinkdir, @belinkdir]
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
        vars = %w(pidfile chrootdir servicefile cfg dotdir fedir bedir felinkdir belinkdir)
        vals = [PIDFILE, CHROOTDIR, SERVICEFILE, CFG, DOTDIR, FEDIR, BEDIR, FELINKDIR, BELINKDIR]
        vars.zip(vals).each do |var, val|
          instance_variable_set("@#{var}", format(val, @name))
        end
      end

      def make_end_specific_vars(options)
        if options[:endname]
          case options[:endtype]
          when :frontend
            create_end_vars(%w(fecfg felink), [FECFG, FELINK], options[:endname])
          when :backend
            create_end_vars(%w(becfg belink), [BECFG, BELINK], options[:endname])
          end
        end
      end

      def create_end_vars(vars, vals, endname)
        vars.zip(vals).each do |var, val|
          instance_variable_set("@#{var}", format(val, @name, endname))
        end
      end
    end
  end
end
