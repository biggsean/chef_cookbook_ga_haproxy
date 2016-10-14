require 'spec_helper'

instances.each do |instance|
  describe "Instance specific tests for #{instance.name}" do
    describe 'Ensure service file is delivered and configured' do
      describe file(instance.servicefile) do
        it { should be_file }
        it { should be_owned_by 'root' }
        it { should be_grouped_into 'root' }
        it { should be_mode 755 }
        its(:content) { should match(/^cfgfile=#{Regexp.quote(instance.cfg)}/) }
        its(:content) { should match(/^pidfile=#{Regexp.quote(instance.pidfile)}/) }
        its(:content) { should match(/^lockfile=#{Regexp.quote(instance.lockfile)}/) }

        findcmd = "/bin/find #{instance.dotdir} -type l -name '*.cfg' -path '*enabled*' -print0"
        sedcmd = %q{/bin/sed 's/\([^\x0][^\x0]*\)/-f "\1" /g'}
        its(:content) { should match(/^#{Regexp.quote("dotdfiles=$(#{findcmd}|#{sedcmd})")}$/) }
        its(:content) { should match(/^prog=#{Regexp.quote(instance.name)}/) }
        its(:content) { should match(/daemon --pidfile=\$pidfile \$exec -D -f \$cfgfile -p \$pidfile \$dotdfiles \$OPTIONS/) }
      end
    end

    describe 'Ensure we create a chroot dir' do
      describe file(instance.chrootdir) do
        it { should be_directory }
        it { should be_owned_by 'haproxy' }
        it { should be_grouped_into 'haproxy' }
        it { should be_mode 755 }
      end
    end

    describe 'Ensure the main configuration exists and is configured' do
      describe file(instance.cfg) do
        it { should be_file }
        it { should be_owned_by 'root' }
        it { should be_grouped_into 'root' }
        it { should be_mode 644 }
        its(:content) { should match(/^\s*chroot\s+#{Regexp.quote(instance.chrootdir)}/) }
        its(:content) { should match(/^\s*pidfile\s+#{Regexp.quote(instance.pidfile)}/) }
        its(:content) { should match(/^\s*stats socket\s+#{Regexp.quote(instance.statssocket)}/) }
      end
    end

    describe 'Ensure the necessary configuration dirs exist' do
      instance.config_dirs.each do |dir|
        describe file(dir) do
          it { should be_directory }
          it { should be_owned_by 'root' }
          it { should be_grouped_into 'root' }
          it { should be_mode 755 }
        end
      end
    end

    describe service(instance.name) do
      it { should be_enabled }
      it { should be_running }
    end
  end
end
