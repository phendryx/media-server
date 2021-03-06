#!/bin/bash

if [ ! -e ./puppetlabs-release-precise.deb ]; then
    wget http://apt.puppetlabs.com/puppetlabs-release-precise.deb
fi
dpkg -i ./puppetlabs-release-precise.deb

 if [ ! -e ./plex-archive-keyring_2.0.0_all.deb ]; then
     wget http://plexapp.com/repo/pool/main/p/plex-archive-keyring/plex-archive-keyring_2.0.0_all.deb
 fi
dpkg -i plex-archive-keyring_2.0.0_all.deb

apt-get update
apt-get install -y puppet git-core aptitiude
cat > /etc/puppet/hiera.yaml << EOF
:hierarchy:
    - common
:backends:
    - yaml
:yaml:
    :datadir: '/etc/puppet/hieradata'
EOF
mkdir /etc/puppet/hieradata
cp common.yaml /etc/puppet/hieradata/

cd /etc/puppet/modules
git clone git://github.com/example42/puppet-vim.git vim
git clone git://github.com/phendryx/puppet-nginx.git nginx
git clone git://github.com/puppetlabs/puppetlabs-stdlib.git stdlib
git clone git://github.com/onyxpoint/pupmod-concat.git concat
git clone https://github.com/josephmc5/puppet-python.git python
git clone https://github.com/josephmc5/puppet-git.git git
git clone git://github.com/evolvingweb/puppet-apt.git apt
git clone https://github.com/rodjek/puppet-logrotate logrotate
git clone git://github.com/josephmc5/puppet-dropbox.git dropbox
git clone git://github.com/plathrop/puppet-module-supervisor.git supervisor
git clone git://github.com/phendryx/puppetlabs-java.git java

git clone git://github.com/phendryx/puppet-maraschino.git maraschino
git clone git://github.com/phendryx/puppet-plex-server.git plex-server
git clone git://github.com/phendryx/puppet-subsonic.git subsonic
git clone git://github.com/phendryx/puppet-sabnzbd.git sabnzbd
git clone git://github.com/phendryx/puppet-headphones.git headphones
git clone git://github.com/phendryx/puppet-couchpotatoserver.git couchpotatoserver
git clone git://github.com/phendryx/puppet-sickbeard.git sickbeard
git clone git://github.com/phendryx/puppet-minisub.git minisub

cat > /etc/puppet/manifests/site.pp << EOF
node default {
    \$app_dir = hiera('app_dir')             
    file { "\$app_dir":
        ensure => directory,
        owner => "root",
        group => "root",
        mode => '0777',
    }
    \$services_user = hiera('services_user')             
    user { "\$services_user":
        allowdupe => false,
        ensure => 'present',
    }
    class { 'dropbox': }
    class { 'nginx': }
    \$external_dns = hiera('external_dns', "localhost")             
    nginx::resource::vhost { "\$external_dns":
       ensure   => present,
       www_root => '/var/www',
    }   
    class { 'python::virtualenv': }
    class { 'sickbeard': }
    class { 'sabnzbd': }
    class { 'couchpotatoserver': }
    class { 'headphones': }
    class { 'maraschino': }
    class { 'subsonic': }
    class { 'minisub': }
    class { 'plex-server': }
}
EOF

puppet apply /etc/puppet/manifests/site.pp
