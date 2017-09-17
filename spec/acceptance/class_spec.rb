require 'spec_helper_acceptance'

describe 'csf class' do
  context 'configserver firewall' do
    # Using puppet_apply as a helper
    it 'should work idempotently with no errors' do
      pp = <<-PUPPET
      class { 'csf': }
      PUPPET

      # Run it twice and test for idempotency
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)

      # Test our Docker implementation
      pp = <<-PUPPET
      class { 'csf': docker => 'present' }
      PUPPET

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end
  end

  describe 'test docker.sh' do
    describe file('/etc/csf/docker.sh') do
      it { should be_file }
      its(:content) { should match 'setup_isolation' }
    end

    describe file('/etc/csf/csfpost.sh') do
      it { should be_file }
      its(:content) { should match 'docker.sh' }
    end
  end
end
