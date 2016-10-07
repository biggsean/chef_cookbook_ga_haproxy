require 'spec_helper'

describe package('haproxy') do
  it { should be_installed }
end

describe file('/etc/haproxy') do
  it { should be_directory }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
  it { should be_mode 755 }
end

['haproxy', 'haproxy-test'].each do |s|
  config = "#{s}.cfg"

  describe file("/var/lib/#{s}") do
    it { should be_directory }
    it { should be_owned_by 'haproxy' }
    it { should be_grouped_into 'haproxy' }
    it { should be_mode 755 }
  end

  describe file("/etc/haproxy/#{config}") do
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    it { should be_mode 644 }
  end

  describe file("/etc/init.d/#{s}") do
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    it { should be_mode 755 }
    its(:content) { should match %r{^cfgfile=/etc/haproxy/#{Regexp.quote(config)}} }
    its(:content) { should match %r{^pidfile=/var/run/#{Regexp.quote(s)}\.pid} }
    its(:content) { should match %r{^lockfile=/var/lock/subsys/#{Regexp.quote(s)}} }
    its(:content) { should match(/^prog=#{Regexp.quote(s)}/) }
    its(:content) { should match(/daemon --pidfile=\$pidfile \$exec -D -f \$cfgfile -p \$pidfile \$OPTIONS/) }
  end

  describe service(s) do
    it { should be_enabled }
    it { should be_running }
  end
end

[5000, 6001].each do |p|
  describe port(p) do
    it { should be_listening.with('tcp') }
  end
end
