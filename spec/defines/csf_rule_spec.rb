require 'spec_helper'
describe 'csf::rule' do
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

        context 'csf::rule with parameters' do
          let(:params) do
            {
              content: 'bar',
              order: '2',
              target: '/etc/csf/csfpre.sh'
            }
          end

          it { is_expected.to contain_concat__fragment('foo').with_content('bar') }
          it { is_expected.to contain_concat__fragment('foo').with_order('2') }
          it { is_expected.to contain_concat__fragment('foo').with_target('/etc/csf/csfpre.sh') }
        end
      end
    end
  end
end
