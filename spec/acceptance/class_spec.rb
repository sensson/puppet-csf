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
    end
  end

  context 'test docker.sh' do
    it 'should install docker.sh with no errors' do
      pp = <<-PUPPET
      class { 'csf': docker => 'present' }
      PUPPET

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe file('/etc/csf/docker.sh') do
      it { should be_file }
      its(:content) { should match 'setup_isolation' }
    end

    describe file('/etc/csf/csfpost.sh') do
      it { should be_file }
      its(:content) { should match 'docker.sh' }
    end
  end

  context 'test reload' do
    it 'should reload the firewall' do
      pp = <<-PUPPET
      class { 'csf': }
      PUPPET

      apply_manifest(pp, catch_failures: true)

      rule = <<-PUPPET
      class { 'csf': }
      csf::rule { 'test':
        content => '/sbin/iptables -I INPUT -p tcp --dport 80 -s 192.168.0.1/32 -j ACCEPT'
      }
      PUPPET

      apply_manifest(rule, catch_failures: true)
    end

    describe iptables do
      # This uses iptables -S, keep in mind that iptables rules may not look
      # exactly the same as you have added them. This is why this check is
      # really basic
      it { should have_rule('-s 192.168.0.1/32') }
    end
  end
end
