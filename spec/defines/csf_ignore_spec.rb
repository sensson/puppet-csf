require 'spec_helper'
describe 'csf::ignore' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        let :title do
          '10.12.34.56'
        end

        let(:pre_condition) do
          'class { "::csf": }'
        end

        context 'csf::ignore with parameters' do
          let(:params) do
            {
              comment: 'foobar'
            }
          end

          it { is_expected.to contain_csf__global('csf-global-ignore-10.12.34.56').with('ensure' => 'present') }
          it { is_expected.to contain_csf__global('csf-global-ignore-10.12.34.56').with('comment' => 'foobar') }
          it { is_expected.to contain_csf__global('csf-global-ignore-10.12.34.56').with('type' => 'ignore') }
          it { is_expected.to contain_csf__global('csf-global-ignore-10.12.34.56').with('ipaddress' => '10.12.34.56') }

          it { is_expected.to contain_file_line('csf-10.12.34.56-ignore') }
        end
      end
    end
  end
end
