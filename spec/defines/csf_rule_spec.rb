require 'spec_helper'
describe 'csf::rule', :type => :define do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        let :title do
          'foo'
        end

        context "csf::rule with parameters" do
          let(:params) {{
            :content => 'bar',
            :order => '2',
            :target => '/etc/csf/csfpre.sh'
          }}

          it { is_expected.to contain_concat__fragment('foo').with('content' => 'bar') }
          it { is_expected.to contain_concat__fragment('foo').with('order' => '2') }
          it { is_expected.to contain_concat__fragment('foo').with('target' => '/etc/csf/csfpre.sh') }
        end
      end
    end 
  end
end