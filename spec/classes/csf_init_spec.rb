require 'spec_helper'
describe 'csf', :type => :class do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        context "csf class with parameters" do
          it { is_expected.to compile.with_all_deps }

          # verify classes
          it { is_expected.to contain_class('csf') }
          it { is_expected.to contain_class('csf::install') }
          it { is_expected.to contain_class('csf::params') }

          # setup our 'service'
          it { is_expected.to contain_exec('csf-reload').with('refreshonly' => 'true') }

          # csf-open-puppet is our fallback scenario
          it { is_expected.to contain_exec('csf-open-puppet').with('command' => '/sbin/iptables -I OUTPUT -p tcp --dport 8140 -j ACCEPT') }
          it { is_expected.to contain_exec('csf-open-puppet').with('unless' => '/sbin/iptables -L OUTPUT -n | grep "8140"') }

          # /etc/csf/csfpost.sh
          it { is_expected.to contain_concat('/etc/csf/csfpost.sh').with('ensure' => 'present') }
          it { is_expected.to contain_concat('/etc/csf/csfpost.sh').with('ensure_newline' => 'true' ) }
          it { is_expected.to contain_concat('/etc/csf/csfpost.sh').with('mode' => '0700' ) }
          it { is_expected.to contain_concat('/etc/csf/csfpost.sh').with('order' => 'numeric' ) }
          it { is_expected.to contain_concat('/etc/csf/csfpost.sh').with('require' => 'Exec[csf-install]' ) }
          it { is_expected.to contain_concat('/etc/csf/csfpost.sh').with('notify' => 'Exec[csf-reload]' ) }
          it { is_expected.to contain_concat__fragment('csf-post-header').with('target' => '/etc/csf/csfpost.sh') }
          it { is_expected.to contain_concat__fragment('csf-post-header').with('order' => '00') }

          # /etc/csf/csfpre.sh
          it { is_expected.to contain_concat('/etc/csf/csfpre.sh').with('ensure' => 'present') }
          it { is_expected.to contain_concat('/etc/csf/csfpre.sh').with('ensure_newline' => 'true') }
          it { is_expected.to contain_concat('/etc/csf/csfpre.sh').with('mode' => '0700') }
          it { is_expected.to contain_concat('/etc/csf/csfpre.sh').with('order' => 'numeric') }
          it { is_expected.to contain_concat('/etc/csf/csfpre.sh').with('require' => 'Exec[csf-install]') }
          it { is_expected.to contain_concat('/etc/csf/csfpre.sh').with('notify' => 'Exec[csf-reload]') }
          it { is_expected.to contain_concat__fragment('csf-pre-header').with('target' => '/etc/csf/csfpre.sh') }
          it { is_expected.to contain_concat__fragment('csf-pre-header').with('order' => '00') }
        end

      end
    end 
  end
end