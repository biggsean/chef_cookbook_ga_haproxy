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

instance = {
  'haproxy' => {
    'frontends' => {
      'main' => {
        'ip' => '*',
        'port' => '5000',
        'default_backend' => 'default-backend'
      }
    }
  },
  'haproxy-test' => {
    'frontends' => {
      'main' => {
        'ip' => '*',
        'port' => '6000',
        'default_backend' => 'test-backend'
      }
    }
  }
}

instance.keys.each do |s|
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
    its(:content) { should match %r{^\s*chroot\s+/var/lib/#{Regexp.quote(s)}} }
    its(:content) { should match %r{^\s*pidfile\s+/var/run/#{Regexp.quote(s)}.pid} }
    its(:content) { should match %r{^\s*stats socket\s+/var/lib/#{Regexp.quote(s)}/stats} }
  end

  instance[s]['frontends'].each do |fe, details|
    socket = "#{details['ip']}:#{details['port']}"

    describe file("/etc/haproxy/#{config}") do
      its(:content) { should match(/^\s*frontend\s+#{Regexp.quote(fe)}\s+#{Regexp.quote(socket)}$/) }
      its(:content) { should match(/^\s*default_backend\s+#{Regexp.quote(details['default_backend'])}$/) }
    end

    describe port(details['port']) do
      it { should be_listening.with('tcp') }
    end
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
