require 'spec_helper_acceptance'

describe 'mumble class' do
  context 'with minimal parameters' do
    pp = %(
      class { 'mumble' :
        password => 'Fo0b@rr',
      }
    )

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
end
