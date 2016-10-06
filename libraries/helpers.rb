# Provide custom resources with common methods
module GAHAProxyCookbook
  # Helper functions
  module Helpers
    def package_name
      'haproxy'
    end

    def haproxy_instance(iname)
      case iname
      when 'default' then 'haproxy'
      else "haproxy-#{iname}"
      end
    end

    def config_file(iname)
      hi = haproxy_instance(iname)
      "/etc/haproxy/#{hi}.cfg"
    end

    def service_file(iname)
      hi = haproxy_instance(iname)
      "/etc/init.d/#{hi}"
    end
  end
end
