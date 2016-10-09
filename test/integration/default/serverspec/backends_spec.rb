require 'spec_helper'

instances.each do |name, instance|
  config = "/etc/haproxy/#{name}.cfg"

  instance[:backends].each do |be, backend|
    describe file(config) do
      its(:content) { should match(/^\s*backend\s+#{Regexp.quote(be)}$/) }

      if backend[:options]
        backend[:options].each do |option|
          its(:content) { should match(/^\s*#{Regexp.quote(option)}$/) }
        end
      end

      backend[:servers].each do |server|
        server.each do |s_name, s_info|
          its(:content) do
            should match(/^\s*server\s+#{Regexp.quote(s_name)}\s+#{Regexp.quote(s_info[:socket])}\s#{Regexp.quote(s_info[:options].join(' '))}$/)
          end
        end
      end
    end
  end
end
