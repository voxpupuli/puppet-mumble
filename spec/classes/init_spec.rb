require 'spec_helper'

describe 'mumble', type: 'class' do
  on_supported_os.each do |os, facts|
    context "on #{os} " do
      let :facts do
        facts
      end

      context 'with all defaults' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('mumble') }
        it { is_expected.to contain_file('/etc/mumble-server.ini') }
        it { is_expected.to contain_group('mumble-server') }
        it { is_expected.to contain_package('mumble-server') }
        it { is_expected.to contain_service('mumble-server') }
        it { is_expected.to contain_user('mumble-server') }
      end
    end
  end
end
