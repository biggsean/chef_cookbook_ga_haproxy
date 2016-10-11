require 'spec_helper'

instances.each do |instance|
  backends(instance).each do |name, backend|
    cfgdir = "/etc/haproxy/#{instance}.d/backends"
    config = "#{cfgdir}/#{name}.cfg"
    link = "#{cfgdir}/enabled/#{name}.cfg"

    describe file(config) do
      it { should be_file }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'root' }
      it { should be_mode 644 }
      its(:content) { should match(/^\s*backend\s+#{Regexp.quote(name)}$/) }

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

    case backend[:disabled]
    when true
      describe file(link) do
        it { should_not exist }
      end
    else
      describe file(link) do
        it { should be_linked_to config }
      end
    end
  end
end
