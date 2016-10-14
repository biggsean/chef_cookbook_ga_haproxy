require 'spec_helper'

instances.each do |instance|
  instance.backends.each do |backend|
    describe "Instance #{instance.name} backend #{backend.name} specific tests" do
      becfg = "#{instance.bedir}/#{backend.name}.cfg"
      belink = "#{instance.belinkdir}/#{backend.name}.cfg"

      describe file(becfg) do
        it { should be_file }
        it { should be_owned_by 'root' }
        it { should be_grouped_into 'root' }
        it { should be_mode 644 }
        its(:content) { should match(/^\s*backend\s+#{Regexp.quote(backend.name)}$/) }

        if backend.options
          backend.options.each do |option|
            its(:content) { should match(/^\s*#{Regexp.quote(option)}$/) }
          end
        end

        backend.servers.each do |server|
          its(:content) do
            should match(/^\s*server\s+#{Regexp.quote(server[:name])}\s+#{Regexp.quote(server[:socket])}\s#{Regexp.quote(server[:options].join(' '))}$/)
          end
        end
      end

      case backend.disabled
      when true
        describe file(belink) do
          it { should_not exist }
        end
      else
        describe file(belink) do
          it { should be_linked_to becfg }
        end
      end
    end
  end
end
