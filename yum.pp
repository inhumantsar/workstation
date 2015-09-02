######################
# Fix for FC22. They deprecated yum but Puppet 
# isn't ready for that.
if $::os['name'] == 'Fedora' {
	if $::os['release']['major'] == '22' {
		file { '/usr/bin/yum' :
			ensure => 'link',
			target => '/usr/bin/yum-deprecated',
			replace => true,
		}
	}
}
