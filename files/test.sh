#!/bin/bash

a=3
case "$a" in 
	'1')
	composerInstall () {
		echo 'composer install v1'
	}
	;;
	'2')
	composerInstall () {
		echo 'COMPOSER INSTALL V2'
	}
	;;
esac

echo "$(composerInstall)"
