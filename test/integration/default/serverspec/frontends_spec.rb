require 'spec_helper'

instances.each do |instance|
  instance.frontends.each do |frontend|
    describe "Instance #{instance.name} frontend #{frontend.name} specific tests" do
      fecfg = "#{instance.fedir}/#{frontend.name}.cfg"
      felink = "#{instance.felinkdir}/#{frontend.name}.cfg"

      describe file(fecfg) do
        it { should be_file }
        it { should be_owned_by 'root' }
        it { should be_grouped_into 'root' }
        it { should be_mode 644 }
        its(:content) { should match(/^\s*frontend\s+#{Regexp.quote(frontend.name)}\s+#{Regexp.quote(frontend.socket)}$/) }
        its(:content) { should match(/^\s*default_backend\s+#{Regexp.quote(frontend.default_backend)}$/) }
      end

      case frontend.disabled
      when true
        describe file(felink) do
          it { should_not exist }
        end

        describe port(frontend.port) do
          it { should_not be_listening.with('tcp') }
        end
      else
        describe file(felink) do
          it { should be_linked_to fecfg }
        end

        describe port(frontend.port) do
          it { should be_listening.with('tcp') }
        end
      end
    end
  end
end
