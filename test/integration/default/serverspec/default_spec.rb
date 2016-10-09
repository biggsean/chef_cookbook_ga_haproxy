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

instances.each do |i, i_hash|
  config = "#{i}.cfg"

  i_hash[:backends].each do |be, be_hash|
    describe file("/etc/haproxy/#{config}") do
      its(:content) { should match(/^\s*backend\s+#{Regexp.quote(be)}$/) }

      if be_hash[:options]
        be_hash[:options].each do |option|
          its(:content) { should match(/^\s*#{Regexp.quote(option)}$/) }
        end
      end

      be_hash[:servers].each do |server|
        server.each do |s_name, s_info|
          its(:content) do
            should match(/^\s*server\s+#{Regexp.quote(s_name)}\s+#{Regexp.quote(s_info[:socket])}\s#{Regexp.quote(s_info[:options].join(' '))}$/)
          end
        end
      end
    end
  end
end
