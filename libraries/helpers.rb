# Provide custom resources with common methods
module GAHAProxyCookbook
  # Helper functions
  module Helpers
    def package_name
      'haproxy'
    end

    def get_config(instance)
      i = servicename(instance)
      {
        svc: i,
        cfg: "/etc/haproxy/#{i}.cfg",
        dotd: "/etc/haproxy/#{i}.d",
        init: "/etc/init.d/#{i}",
        chroot: "/var/lib/#{i}",
        pidfile: "/var/run/#{i}.pid"
      }
    end

    def servicename(instance)
      case instance
      when 'default' then 'haproxy'
      else "haproxy-#{instance}"
      end
    end
  end
end
