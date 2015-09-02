class { 'sudo' : }

# allows a user's ssh-agent keys to be passed 
# along to root for sudo commands
sudo::conf { 'sudo-ssh-agent' :
	priority => '10',
	content => 'Defaults>root    env_keep+=SSH_AUTH_SOCK'
}
