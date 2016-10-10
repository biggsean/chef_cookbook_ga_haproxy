require 'spec_helper'

instances.each do |name, instance|
  instance[:backends].each do |be, backend|
    config = "/etc/haproxy/#{name}.d/backends/#{be}.cfg"

    describe file(config) do
      it { should be_file }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'root' }
      it { should be_mode 644 }
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
