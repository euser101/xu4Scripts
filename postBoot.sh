#!/bin/bash

# Simple script to run at post boot to quickly and safely configure the System

prompt() {
  read -p $1 -n 1 -r
	if [[ $REPLY =~ ^[Yy]$ ]]
	then
	    $2
	fi
}

regenSSH() {
  echo "Regenerating SSH-Keys"
  sudo rm -v /etc/ssh/ssh_host_* && sudo dpkg-reconfigure openssh-server
  echo "Restarting SSH Service"
  sudo service ssh restart
  sudo systemctl status sshd
}

cleanupSystem() {
  echo "Cleaning up system"
  sudo apt autoremove
  sudo apt clean
  history -d
}

configureSSH() {
   echo "Note: SSH is now enabled on boot"
   sudo systemctl enable ssh.service
   
   regenSSH
}

prompt "Do you want to enable SSH on boot?" configureSSH
prompt "Would you like to change the odroid user password?" "passwd odroid"
prompt "Would you like to change the root password?" "su && passwd"
cleanupSystem
