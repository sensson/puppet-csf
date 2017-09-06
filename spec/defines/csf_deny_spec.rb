require 'spec_helper'
describe 'csf::deny' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts.merge(Facts.override_facts)
        end

        let :title do
          '10.12.34.56'
        end

        let(:pre_condition) do
          'class { "::csf": }'
        end

        context 'csf::deny with parameters' do
          let(:params) do
            {
              comment: 'foobar'
            }
          end

          it { is_expected.to contain_csf__global('csf-global-deny-10.12.34.56').with('ensure' => 'present') }
          it { is_expected.to contain_csf__global('csf-global-deny-10.12.34.56').with('comment' => 'foobar') }
          it { is_expected.to contain_csf__global('csf-global-deny-10.12.34.56').with('type' => 'deny') }
          it { is_expected.to contain_csf__global('csf-global-deny-10.12.34.56').with('ipaddress' => '10.12.34.56') }

          it { is_expected.to contain_file_line('csf-10.12.34.56-deny') }
        end
      end
    end
  end
end
