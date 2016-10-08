#
# Cookbook Name:: ga_haproxy_default
# Spec:: default
#
# Copyright (c) 2016 Sean McGowan, All Rights Reserved.

require 'spec_helper'

describe 'ga_haproxy_default::default' do
  context 'When all attributes are default, on an unspecified platform' do
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
  end
end
