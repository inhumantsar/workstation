include wget

$pkgs = [
	'vim',
	'vlc',
	'git',
	'rubygem-puppet-lint',
	'keychain',
	]

$rh_pkgs = [
	'redhat-lsb',
	'libXScrnSaver',
	]

$ubuntu_pkgs = [
	'bcmwl-kernel-source', # for mbp
]

$chrome_requires = []


package { $pkgs :
	ensure => 'installed',
}

if $::os['name'] == 'Ubuntu' { 
	package { $ubuntu_pkgs: ensure => 'installed', } 

	$atom_url = 'https://github.com/atom/atom/releases/download/v1.0.10/atom-amd64.deb'
	$atom_provider = 'dpkg'
	$atom_tmp_location = '/tmp/atom-amd64.deb'
}
if $::os['family'] == 'RedHat' { 
	package { $rh_pkgs: ensure => 'installed', } 

	$atom_url = 'https://atom.io/download/rpm'
	$atom_provider = 'rpm'
	$atom_tmp_location = '/tmp/atom.rpm'

	$chrome_requires = [ Package['redhat-lsb'], Package['libXScrnSaver'], ]
}

### atom
wget::fetch { 'atom-pkg' :
	source => $atom_url,
	destination => $atom_tmp_location,
	verbose => false,
}	

package { 'atom' :
	source => $atom_tmp_location,
	provider => $atom_provider,
	ensure => 'installed',
}

# TODO: Atom Git-Plus plugin install

package { 'google-chrome' :
	source => 'https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm',
	provider => 'rpm',
	ensure => 'installed',
	require => $chrome_requires,
}

exec { 'install_pip' :
	command => 'easy_install pip',
	creates => '/usr/bin/pip',
}
