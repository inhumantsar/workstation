#!/bin/bash
if [ ! -f /usr/bin/puppet ]; then 
	if [ -f /etc/redhat-release ]; then	
		yum -y install puppet
	fi
	if [ -f /etc/debian_version; then
		wget https://apt.puppetlabs.com/puppetlabs-release-pc1-trusty.deb
		dpkg -i puppetlabs-release-pc1-trusty.deb
		apt-get update
		apt-get -y install puppet
	fi
fi
echo -e '\nConfiguring yum...'
puppet apply yum.pp
echo -e '\nInstalling puppet modules...'
puppet apply modules.pp
echo -e '\nInstalling packages...'
puppet apply packages.pp

# sudo has to come before all users...
echo -e '\nConfiguring sudo...'
puppet apply sudo.pp

# ...because users can have their own sudo configs that
# would get purged by sudo.pp otherwise.
echo -e '\nConfiguring "sam" user...'
puppet apply sam.pp
