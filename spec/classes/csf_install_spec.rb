require 'spec_helper'
require_relative '../facts.rb'

describe 'csf::install' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts.merge(Facts.override_facts)
        end

        context 'csf::install class with parameters' do
          it { is_expected.to compile.with_all_deps }

          # verify classes
          it { is_expected.to contain_class('csf::install') }

          # verify packages and installation
          it { is_expected.to contain_package('perl') }
          it { is_expected.to contain_exec('csf-install').with('cwd' => '/tmp') }
          it { is_expected.to contain_exec('csf-install').with('command' => '/usr/bin/curl -o csf.tgz https://download.configserver.com/csf.tgz && tar -xzf csf.tgz && cd csf && sh install.sh') }
          it { is_expected.to contain_exec('csf-install').with('creates' => '/usr/sbin/csf') }
          it { is_expected.to contain_exec('csf-install').with('notify' => 'Service[csf]') }
          it { is_expected.to contain_exec('csf-install').with('require' => 'Package[perl]') }

          it { is_expected.to contain_package('iptables').with('ensure' => 'present') }

          if facts[:operatingsystem] == 'CentOS'
            it { is_expected.to contain_package('perl-libwww-perl').with('ensure' => 'present') }
            it { is_expected.to contain_package('perl-LWP-Protocol-https').with('ensure' => 'present') }
            it { is_expected.to contain_package('perl-GDGraph').with('ensure' => 'present') }
          end

          if facts[:operatingsystem] == 'Ubuntu'
            it { is_expected.to contain_package('libwww-perl').with('ensure' => 'present') }
            it { is_expected.to contain_package('liblwp-protocol-https-perl').with('ensure' => 'present') }
            it { is_expected.to contain_package('libgd-graph-perl').with('ensure' => 'present') }
          end

          # check our configuration
          it { is_expected.to contain_csf__config('TESTING').with('value' => '0') }
          it { is_expected.to contain_file_line('csf-config-set-TESTING') }

          # make sure port 8140 is always open
          it { is_expected.to contain_csf__ipv4__output('8140').with('require' => 'Exec[csf-install]') }
          it { is_expected.to contain_csf__rule('csf-ip4-tcp-OUTPUT-8140') }
          it { is_expected.to contain_concat__fragment('csf-ip4-tcp-OUTPUT-8140') }
        end
      end
    end
  end
end
