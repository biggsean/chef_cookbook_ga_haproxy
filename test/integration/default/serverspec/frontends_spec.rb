require 'spec_helper'

instances.each do |name, instance|
  config = "/etc/haproxy/#{name}.cfg"

  instance[:frontends].each do |fe, frontend|
    socket = "#{frontend[:ip]}:#{frontend[:port]}"

    describe file(config) do
      its(:content) { should match(/^\s*frontend\s+#{Regexp.quote(fe)}\s+#{Regexp.quote(socket)}$/) }
      its(:content) { should match(/^\s*default_backend\s+#{Regexp.quote(frontend[:default_backend])}$/) }
    end

    describe port(frontend[:port]) do
      it { should be_listening.with('tcp') }
    end
  end
end
