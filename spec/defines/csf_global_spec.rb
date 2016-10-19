require 'spec_helper'
describe 'csf::global', :type => :define do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        let :title do
          'foo'
        end

        context "csf::global with parameters" do
          let(:params) {{
            :ipaddress => '10.12.34.56',
            :type => 'allow',
            :ensure => 'absent',
            :comment => 'foobar',
          }}
          it { is_expected.to contain_file_line('csf-10.12.34.56-allow').with('ensure' => 'absent') }
          it { is_expected.to contain_file_line('csf-10.12.34.56-allow').with('path' => '/etc/csf/csf.allow') }
          it { is_expected.to contain_file_line('csf-10.12.34.56-allow').with('line' => '10.12.34.56 # foobar - from foo') }
          it { is_expected.to contain_file_line('csf-10.12.34.56-allow').with('match' => '10.12.34.56.*') }
        end

        context "csf::global with invalid type" do
          let(:params) {{
            :type => 'wrong',
          }}

          it 'fails' do
            expect { subject.call } .to raise_error(/unknown value wrong/)
          end
        end
      end
    end 
  end
end