require 'spec_helper'
describe 'csf::config' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        let :title do
          'foo'
        end

        let(:pre_condition) do
          'class { "::csf": }'
        end

        context 'csf::config without parameters' do
          it 'fails' do
            expect { subject.call } .to raise_error(/Please set a value for/)
          end
        end

        context 'csf::config with parameters' do
          let(:params) do
            {
              value: 'bar'
            }
          end

          it { is_expected.to contain_file_line('csf-config-set-foo-bar').with('ensure' => 'present') }
          it { is_expected.to contain_file_line('csf-config-set-foo-bar').with('path' => '/etc/csf/csf.conf') }
          it { is_expected.to contain_file_line('csf-config-set-foo-bar').with('line' => 'foo = "bar"') }
          it { is_expected.to contain_file_line('csf-config-set-foo-bar').with('match' => '^foo =') }
          it { is_expected.to contain_file_line('csf-config-set-foo-bar').with('require' => 'Exec[csf-install]') }
          it { is_expected.to contain_file_line('csf-config-set-foo-bar').with('notify' => 'Service[csf]') }
        end
      end
    end
  end
end
