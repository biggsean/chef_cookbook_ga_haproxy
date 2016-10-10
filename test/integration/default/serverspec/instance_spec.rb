require 'spec_helper'

instances.keys.each do |instance|
  cfgdir = '/etc/haproxy'
  config = "#{cfgdir}/#{instance}.cfg"
  dotd = "#{cfgdir}/#{instance}.d"

  describe file("/etc/init.d/#{instance}") do
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    it { should be_mode 755 }
    its(:content) { should match(/^cfgfile=#{Regexp.quote(config)}/) }
    its(:content) { should match %r{^pidfile=/var/run/#{Regexp.quote(instance)}\.pid} }
    its(:content) { should match %r{^lockfile=/var/lock/subsys/#{Regexp.quote(instance)}} }
    its(:content) { should match(/^prog=#{Regexp.quote(instance)}/) }
    its(:content) { should match(/daemon --pidfile=\$pidfile \$exec -D -f \$cfgfile -p \$pidfile \$OPTIONS/) }
  end

  describe file("/var/lib/#{instance}") do
    it { should be_directory }
    it { should be_owned_by 'haproxy' }
    it { should be_grouped_into 'haproxy' }
    it { should be_mode 755 }
  end

  describe file(config) do
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    it { should be_mode 644 }
    its(:content) { should match %r{^\s*chroot\s+/var/lib/#{Regexp.quote(instance)}} }
    its(:content) { should match %r{^\s*pidfile\s+/var/run/#{Regexp.quote(instance)}.pid} }
    its(:content) { should match %r{^\s*stats socket\s+/var/lib/#{Regexp.quote(instance)}/stats} }
  end

  describe file(dotd) do
    it { should be_directory }
    it { should be_owned_by 'haproxy' }
    it { should be_grouped_into 'haproxy' }
    it { should be_mode 755 }
  end

  %w(frontends backends).each do |dir|
    describe file("#{dotd}/#{dir}") do
      it { should be_directory }
      it { should be_owned_by 'haproxy' }
      it { should be_grouped_into 'haproxy' }
      it { should be_mode 755 }
    end
  end

  describe service(instance) do
    it { should be_enabled }
    it { should be_running }
  end
end
