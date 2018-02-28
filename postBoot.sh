#!/bin/bash

# Simple script to run at post boot to quickly and safely configure the System

prompt() {
  read -p "$1" -n 1 -r
	if [[ $REPLY =~ ^[Yy]$ ]]
	then
	    $2
	fi
	echo
}

regenSSH() {
  echo "Regenerating SSH-Keys"
  sudo rm -v /etc/ssh/ssh_host_* && sudo dpkg-reconfigure openssh-server
  echo "Restarting SSH Service"
  service ssh restart
  systemctl status sshd
}

cleanupSystem() {
  history -cw
  echo "Cleaning up system"
  apt autoremove
  apt clean
  
  prompt "Finished. Do you want to reboot now?" reboot
}

configureSSH() {
   echo "Note: SSH is now enabled on boot"
   systemctl enable ssh.service
   
   regenSSH
}

if [[ $EUID -ne 0 ]] ; then
  echo "You must be root" 2>&1
  exit 1
else
  prompt "Do you want to enable SSH on boot?" configureSSH
fi

prompt "Would you like to change the odroid user password?" "passwd odroid"
prompt "Would you like to change the root password?" "sudo sudo passwd"
cleanupSystem
