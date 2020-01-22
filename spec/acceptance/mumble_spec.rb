require 'spec_helper_acceptance'

describe 'mumble class' do
  shared_examples_for 'a module working correctly' do
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

    describe command('netstat -napt') do
      its(:stdout) { is_expected.to match %r{^tcp.*64738.*LISTEN.*murmurd} }
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

    it_behaves_like 'a module working correctly'
  end

  context 'with a server_password' do
    let(:pp) do
      %(
        class { 'mumble' :
          server_password => 'It is Secret: $(rm -r /)',
        }
      )
    end

    it_behaves_like 'a module working correctly'
  end
end
