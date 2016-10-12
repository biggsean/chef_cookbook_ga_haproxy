#
# Cookbook Name:: ga_haproxy_default
# Spec:: default
#
# Copyright (c) 2016 Sean McGowan, All Rights Reserved.

require 'spec_helper'

describe 'ga_haproxy_default::default' do
  context 'The default recipe on CentOS 6.7' do
    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new(platform: 'centos', version: '6.7')
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end

    it 'creates haproxy service' do
      expect(chef_run).to create_ga_haproxy('default')
    end

    it 'creates test haproxy service' do
      expect(chef_run).to create_ga_haproxy('test')
    end

    it 'enables main and http frontends for default instance of haproxy' do
      expect(chef_run).to enable_ga_haproxy_frontend('main').with(
        instance_name: 'default',
        socket: '*:5000',
        default_backend: 'default-backend'
      )
      expect(chef_run).to enable_ga_haproxy_frontend('http').with(
        instance_name: 'default',
        socket: '*:80',
        default_backend: 'test-backend'
      )
    end

    it 'enables main and https frontend for haproxy test instance' do
      expect(chef_run).to enable_ga_haproxy_frontend('main').with(
        instance_name: 'test',
        socket: '*:6000',
        default_backend: 'test-backend'
      )
      expect(chef_run).to enable_ga_haproxy_frontend('https').with(
        instance_name: 'test',
        socket: '*:443',
        default_backend: 'test-backend'
      )
    end

    %w(default test).each do |instance|
      it "enables default-backend and test-backend for #{instance}" do
        expect(chef_run).to enable_ga_haproxy_backend('default-backend').with(
          instance_name: instance
          servers: [
            { name: 'app1', socket: '127.0.0.1:5001', options: ['check'] },
            { name: 'app2', socket: '127.0.0.1:5002', options: ['check'] },
            { name: 'app3', socket: '127.0.0.1:5003', options: ['check'] },
            { name: 'app4', socket: '127.0.0.1:5004', options: ['check'] }
          ],
          options: [
            'balance roundrobin',
            'option httpchk HEAD / HTTP/1.1\r\nHost:localhost'
          ]
        )
        expect(chef_run).to enable_ga_haproxy_backend('test-backend').with(
          servers: [{ name: 'app1', socket: '127.0.0.1:5001', options: ['check'] }]
        )
      end
    end

    it 'disables https frontend and default-backend for test instance' do
      expect(chef_run).to disable_ga_haproxy_frontend('https')
      expect(chef_run).to disable_ga_haproxy_backend('test-backend')
    end
  end
end
