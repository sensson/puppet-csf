require 'spec_helper'
describe 'csf::ipv6::output' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts.merge(Facts.override_facts)
        end

        let :title do
          '80'
        end

        let(:pre_condition) do
          'class { "::csf": }'
        end

        context 'csf::ipv6::output without parameters' do
          it { is_expected.to contain_csf__rule('csf-ip6-tcp-OUTPUT-80') }
          it { is_expected.to contain_csf__rule('csf-ip6-tcp-OUTPUT-80').with_content(/ip6tables -I OUTPUT -p tcp --dport 80 -j ACCEPT/) }
          it { is_expected.to contain_concat__fragment('csf-ip6-tcp-OUTPUT-80') }
        end
      end
    end
  end
end
