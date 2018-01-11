Facter.add('csf_installed') do
  setcode do
    if File.exist? '/etc/csf/csf.conf'
      'true'
    else
      'false'
    end
  end
end
