require 'spec_helper'
describe 'csf::docker', :type => :class do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        context "csf::docker class without parameters" do
          it { is_expected.to compile.with_all_deps }

          # verify classes
          it { is_expected.to contain_class('csf::docker') }

          # verify docker.sh
          it { is_expected.to contain_file('/etc/csf/docker.sh') }
          it { is_expected.to contain_file('/etc/csf/docker.sh').with_ensure('absent') }
          it { is_expected.to contain_file('/etc/csf/docker.sh').with_mode('0755') }
          it { is_expected.to contain_file('/etc/csf/docker.sh').with_content(/bin\/sh/) }
        end

        context "csf::docker class with paramters" do
          let(:pre_condition) do
            'class { "::csf": docker => present }'
          end

          it { is_expected.to contain_file('/etc/csf/docker.sh').with_ensure('present') }
          it { is_expected.to contain_csf__rule('csf-rule-docker') }
          it { is_expected.to contain_csf__rule('csf-rule-docker').with_content('. /etc/csf/docker.sh') }
          it { is_expected.to contain_concat__fragment('csf-rule-docker') }
        end

      end
    end 
  end
end