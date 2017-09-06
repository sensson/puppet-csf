require 'spec_helper'
describe 'csf::global' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts.merge(Facts.override_facts)
        end

        let :title do
          'foo'
        end

        let(:pre_condition) do
          'class { "::csf": }'
        end

        context 'csf::global with parameters' do
          let(:params) do
            {
              ipaddress: '10.12.34.56',
              type: 'allow',
              ensure: 'absent',
              comment: 'foobar'
            }
          end

          it { is_expected.to contain_file_line('csf-10.12.34.56-allow').with('ensure' => 'absent') }
          it { is_expected.to contain_file_line('csf-10.12.34.56-allow').with('path' => '/etc/csf/csf.allow') }
          it { is_expected.to contain_file_line('csf-10.12.34.56-allow').with('line' => '10.12.34.56 # foobar - from foo') }
          it { is_expected.to contain_file_line('csf-10.12.34.56-allow').with('match' => '10.12.34.56.*') }
        end

        context 'csf::global with invalid type' do
          let(:params) do
            {
              type: 'wrong'
            }
          end

          it 'fails' do
            expect { subject.call } .to raise_error(/unknown value wrong/)
          end
        end
      end
    end
  end
end
