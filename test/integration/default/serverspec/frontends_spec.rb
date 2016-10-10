require 'spec_helper'

instances.each do |name, instance|
  instance[:frontends].each do |fe, frontend|
    config = "/etc/haproxy/#{name}.d/frontends/#{fe}.cfg"
    socket = "#{frontend[:ip]}:#{frontend[:port]}"

    describe file(config) do
      it { should be_file }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'root' }
      it { should be_mode 644 }
      its(:content) { should match(/^\s*frontend\s+#{Regexp.quote(fe)}\s+#{Regexp.quote(socket)}$/) }
      its(:content) { should match(/^\s*default_backend\s+#{Regexp.quote(frontend[:default_backend])}$/) }
    end

    describe port(frontend[:port]) do
      it { should be_listening.with('tcp') }
    end
  end
end
