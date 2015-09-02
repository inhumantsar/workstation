$user = 'sam'

user { $user :
	ensure => present,
}

# running masterless means that we need to declare this else 
# we'll wipe out the main sudo configs
class { 'sudo':
      purge               => false,
      config_file_replace => false,
}

sudo::conf { $user :
      priority => 10,
      content => "$user ALL=(ALL) ALL",
}

file { [ "/home/$user", "/home/$user/Source", ] :
	ensure => directory,
}

vcsrepo { "/home/$user/Source/bashextras" :
	ensure => 'present',
	provider => 'git',
	source => 'https://github.com/inhumantsar/bashextras.git',
}

file_line { "config-bashextras-$user" :
	path => "/home/$user/.bashrc",
	line => 'source ~/Source/bashextras/bashextras',
	match => 'source ~/Source/bashextras.*',
	multiple => true,
	require => Vcsrepo["/home/$user/Source/bashextras"],
}
