#!/bin/bash

DISTRIB_CODENAME=$(lsb_release --codename --short)
DEB="puppetlabs-release-${DISTRIB_CODENAME}.deb"
DEB_PROVIDES="/etc/apt/sources.list.d/puppetlabs.list" # Assume that this file's existence means we have the Puppet Labs repo added

if [ ! -e $DEB_PROVIDES ]
then
    apt-get install --yes lsb-release
    # Print statement useful for debugging, but automated runs of this will interpret any output as an error
    # print "Could not find $DEB_PROVIDES - fetching and installing $DEB"
    wget -q http://apt.puppetlabs.com/$DEB
    dpkg -i $DEB

    apt-get update
    apt-get install byobu
    apt-get install vim
    apt-get install --yes puppet
    gem install hiera-eyaml
    echo '_byobu_sourced=1 . /usr/bin/byobu-launch' >> /home/vagrant/.profile
fi
