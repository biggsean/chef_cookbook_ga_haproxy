require 'spec_helper'

instances.each do |instance|
  frontends(instance).each do |name, frontend|
    cfgdir = "/etc/haproxy/#{instance}.d/frontends"
    config = "#{cfgdir}/#{name}.cfg"
    link = "#{cfgdir}/#{name}.cfg"
    socket = "#{frontend[:ip]}:#{frontend[:port]}"

    describe file(config) do
      it { should be_file }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'root' }
      it { should be_mode 644 }
      its(:content) { should match(/^\s*frontend\s+#{Regexp.quote(name)}\s+#{Regexp.quote(socket)}$/) }
      its(:content) { should match(/^\s*default_backend\s+#{Regexp.quote(frontend[:default_backend])}$/) }
    end

    case frontend[:disabled]
    when true
      describe file(link) do
        it { should_not exist }
      end

      describe port(frontend[:port]) do
        it { should_not be_listening.with('tcp') }
      end
    else
      describe file(link) do
        it { should be_linked_to config }
      end

      describe port(frontend[:port]) do
        it { should be_listening.with('tcp') }
      end
    end
  end
end
