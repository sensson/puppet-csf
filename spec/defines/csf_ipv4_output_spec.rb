require 'spec_helper'
describe 'csf::ipv4::output', :type => :define do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        let :title do
          '80'
        end

        context "csf::ipv4::output without parameters" do
          it { is_expected.to contain_csf__rule('csf-tcp-OUTPUT-80') }
          it { is_expected.to contain_csf__rule('csf-tcp-OUTPUT-80').with_content(/iptables -I OUTPUT -p tcp --dport 80 -j ACCEPT/) }
          it { is_expected.to contain_concat__fragment('csf-tcp-OUTPUT-80') }
        end
      end
    end 
  end
end