# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'mumble class' do
  shared_examples_for 'a module working correctly' do |expected_port|
    it 'installs without error' do
      apply_manifest(pp, catch_failures: true)
    end

    it 'installs idempotently' do
      apply_manifest(pp, catch_changes: true)
    end

    describe service('mumble-server') do
      it { is_expected.to be_enabled }
      it { is_expected.to be_running }
    end

    describe port(expected_port) do
      it { is_expected.to be_listening }
    end
  end

  context 'with minimal parameters' do
    let(:pp) do
      %(
        class { 'mumble' :
          password => 'Fo0b@rr',
        }
      )
    end

    it_behaves_like 'a module working correctly', 64_738
  end

  context 'with a server_password' do
    let(:pp) do
      %(
        class { 'mumble' :
          server_password => 'It is Secret: $(rm -r /)',
        }
      )
    end

    it_behaves_like 'a module working correctly', 64_738
  end

  context 'with a changed port' do
    let(:pp) do
      %(
        class { 'mumble' :
          port => 64739,
        }
      )
    end

    it_behaves_like 'a module working correctly', 64_739
  end
end
