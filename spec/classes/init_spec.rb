# frozen_string_literal: true

require 'spec_helper'

describe 'mumble', type: 'class' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
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

      context 'with a server_password' do
        let(:params) do
          {
            server_password: 'It is Secret: $(rm -r /)'
          }
        end

        it { is_expected.to contain_exec('mumble_set_password').with(command: %r{-supw It\\ is\\ Secret:\\ \\\$\\\(rm\\ -r\\ /\\\) 2>&1 \|}) }
      end
    end
  end
end
