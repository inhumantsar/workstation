$forge_modules = [
	'puppetlabs/vcsrepo',
	'puppetlabs/stdlib',
	'maestrodev/wget',
	]

# RELEASE TO THE FORGE MORE OFTEN
# ...or maybe I should just use github exclusively?
$git_modules = {
	'sudo' => 'https://github.com/saz/puppet-sudo.git',
	'ssh' => 'https://github.com/saz/puppet-ssh.git',
	}

$forge_modules.each |Integer $index, String $value| {
	$module=split($value,'/')
	exec { "installmodule_$value" :
		command => "/usr/bin/puppet module install $value",
		creates => "/etc/puppet/modules/$module[1]",
	}
}

$git_modules.each |String $key, String $value| {
	vcsrepo { "/etc/puppet/modules/$key" :
		ensure => 'latest',
		source => $value,
		provider => 'git',
		force => true,
	}
}
