require 'spec_helper'

describe 'Ensure the package install is successful' do
  describe package(package_name) do
    it { should be_installed }
  end

  describe file(haproxy_basedir) do
    it { should be_directory }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    it { should be_mode 755 }
  end
end
