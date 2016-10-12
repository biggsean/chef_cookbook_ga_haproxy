# Provide custom resources with common methods
module GAHAProxyCookbook
  # Helper functions
  module Helpers
    class ResourceConfig
      PACKAGE_NAME = 'haproxy'
      PIDFILE = '/var/run/%s.pid'
      CHROOTDIR = '/var/lib/%s'
      SERVICEFILE = '/etc/init.d/%s'
      BASEDIR = '/etc/haproxy'
      CFG = BASEDIR + '/%s.cfg'
      DOTDIR = BASEDIR + '/%s.d'
      FEDIR = DOTDIR + '/frontends'
      BEDIR = DOTDIR + '/backends'
      FELINKDIR = FEDIR + '/enabled'
      BELINKDIR = BEDIR + '/enabled'

      FECFG = FEDIR + '/%s.cfg'
      BECFG = BEDIR + '/%s.cfg'
      FELINK = FEDIR + '/enabled/%s.cfg'
      BELINK = BEDIR + '/enabled/%s.cfg'

      attr_reader :package_name, :basedir, :pidfile, :chrootdir,
        :servicefile, :cfg, :dotdir, :fedir, :bedir, :felinkdir,
        :belinkdir, :fecfg, :becfg, :felink, :belink, :name

      def initialize(instance_name, options ={})
        @name = set_instance_name(instance_name)
        @package_name = PACKAGE_NAME
        @basedir = BASEDIR
        set_instance_specific_vars
        if options[:endtype] && options[:endname]
          set_end_specific_vars(options)
        end
      end

      def config_dirs
        [@basedir, @dotdir, @fedir, @bedir, @felinkdir, @belinkdir]
      end

      private

      def set_instance_name(instance_name)
        case instance_name
        when 'default'
          'haproxy'
        else "haproxy-#{instance_name}"
        end
      end

      def set_instance_specific_vars
        vars = %w(pidfile chrootdir servicefile cfg dotdir fedir bedir felinkdir belinkdir)
        vals = [PIDFILE, CHROOTDIR, SERVICEFILE, CFG, DOTDIR, FEDIR, BEDIR, FELINKDIR, BELINKDIR]
        vars.zip(vals).each do |var, val|
          instance_variable_set("@#{var}", sprintf(val, @name))
        end
      end

      def set_end_specific_vars(options)
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
          instance_variable_set("@#{var}", sprintf(val, @name, endname))
        end
      end
    end
  end
end
