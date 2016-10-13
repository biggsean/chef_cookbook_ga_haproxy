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
        default_backend: 'main-backend'
      )
      expect(chef_run).to enable_ga_haproxy_frontend('http').with(
        instance_name: 'default',
        socket: '*:80',
        default_backend: 'http-backend'
      )
    end

    it 'enables main and https frontend for haproxy test instance' do
      expect(chef_run).to enable_ga_haproxy_frontend('test-main').with(
        instance_name: 'test',
        socket: '*:6000',
        default_backend: 'test-main-backend'
      )
      expect(chef_run).to enable_ga_haproxy_frontend('https').with(
        instance_name: 'test',
        socket: '*:443',
        default_backend: 'https-backend'
      )
    end

    %w(default test).zip(%w(main-backend test-main-backend)).each do |instance, backend|
      it "enables #{backend} for #{instance}" do
        expect(chef_run).to enable_ga_haproxy_backend(backend).with(
          instance_name: instance,
          servers: [
            { 'name' => 'app1', 'socket' => '127.0.0.1:5001', 'options' => ['check'] },
            { 'name' => 'app2', 'socket' => '127.0.0.1:5002', 'options' => ['check'] },
            { 'name' => 'app3', 'socket' => '127.0.0.1:5003', 'options' => ['check'] },
            { 'name' => 'app4', 'socket' => '127.0.0.1:5004', 'options' => ['check'] }
          ],
          options: [
            'balance roundrobin',
            'option httpchk HEAD / HTTP/1.1\r\nHost:localhost'
          ]
        )
      end
    end
    %w(default test).zip(%w(http-backend https-backend)).each do |instance, backend|
      it "enables #{backend} for #{instance}" do
        expect(chef_run).to enable_ga_haproxy_backend(backend).with(
          instance_name: instance,
          servers: [
            { 'name' => 'app1', 'socket' => '127.0.0.1:5001', 'options' => ['check'] }
          ]
        )
      end
    end

    it 'disables https frontend and https-backend for test instance' do
      expect(chef_run).to disable_ga_haproxy_frontend('https').with(instance_name: 'test')
      expect(chef_run).to disable_ga_haproxy_backend('https-backend').with(instance_name: 'test')
    end
  end
end
