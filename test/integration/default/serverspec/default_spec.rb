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
backends = {
  :'default-backend' => {
    servers: [
      app1: {
        socket: '127.0.0.1:5001',
        options: ['check']
      },
      app2: {
        socket: '127.0.0.1:5002',
        options: ['check']
      },
      app3: {
        socket: '127.0.0.1:5003',
        options: ['check']
      },
      app4: {
        socket: '127.0.0.1:5004',
        options: ['check']
      }
    ]
  },
  :'test-backend' => {
    servers: [
      app1: {
        socket: '127.0.0.1:5001',
        options: ['check']
      }
    ]
  }
}
instances = {
  haproxy: {
    frontends: {
      main: {
        ip: '*',
        port: 5000,
        default_backend: 'default-backend'
      },
      http: {
        ip: '*',
        port: 80,
        default_backend: 'test-backend'
      }
    },
    backends: backends
  },
  :'haproxy-test' => {
    frontends: {
      main: {
        ip: '*',
        port: 6000,
        default_backend: 'test-backend'
      }
    },
    backends: backends
  }
}

instances.each do |i, i_hash|
  config = "#{i}.cfg"

  describe file("/var/lib/#{i}") do
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
    its(:content) { should match %r{^\s*chroot\s+/var/lib/#{Regexp.quote(i)}} }
    its(:content) { should match %r{^\s*pidfile\s+/var/run/#{Regexp.quote(i)}.pid} }
    its(:content) { should match %r{^\s*stats socket\s+/var/lib/#{Regexp.quote(i)}/stats} }
  end

  i_hash[:frontends].each do |fe, fe_hash|
    socket = "#{fe_hash[:ip]}:#{fe_hash[:port]}"

    describe file("/etc/haproxy/#{config}") do
      its(:content) { should match(/^\s*frontend\s+#{Regexp.quote(fe)}\s+#{Regexp.quote(socket)}$/) }
      its(:content) { should match(/^\s*default_backend\s+#{Regexp.quote(fe_hash[:default_backend])}$/) }
    end

    describe port(fe_hash[:port]) do
      it { should be_listening.with('tcp') }
    end
  end

  i_hash[:backends].each do |be, be_hash|
    describe file("/etc/haproxy/#{config}") do
      its(:content) { should match(/^\s*backend\s+#{Regexp.quote(be)}$/) }

      be_hash[:servers].each do |server|
        server.each do |s_name, s_info|
          its(:content) do
            should match(/^\s*server\s+#{Regexp.quote(s_name)}\s+#{Regexp.quote(s_info[:socket])}\s#{Regexp.quote(s_info[:options].join(' '))}$/)
          end
        end
      end
    end
  end

  describe file("/etc/init.d/#{i}") do
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    it { should be_mode 755 }
    its(:content) { should match %r{^cfgfile=/etc/haproxy/#{Regexp.quote(config)}} }
    its(:content) { should match %r{^pidfile=/var/run/#{Regexp.quote(i)}\.pid} }
    its(:content) { should match %r{^lockfile=/var/lock/subsys/#{Regexp.quote(i)}} }
    its(:content) { should match(/^prog=#{Regexp.quote(i)}/) }
    its(:content) { should match(/daemon --pidfile=\$pidfile \$exec -D -f \$cfgfile -p \$pidfile \$OPTIONS/) }
  end

  describe service(i) do
    it { should be_enabled }
    it { should be_running }
  end
end
