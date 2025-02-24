#!/usr/bin/env bash

echo -e "Kiosk set up:\n

\n 
PLEASE ENSURE THAT YOU ARE RUNNING WITH SUDO PRIVILEDGES"

echo -e "\n\n"

read -p "confirm your unix username?: " myusername

echo -e "you typed: \n $myusername \n\n" 

read -p "is this correct?[yes/N]" confirm

if [ ! $confirm == "yes" ]
then
echo "restart the script and re-enter your username"
exit
fi

homedir=/home/$myusername

apt  install vim sudo sway xorg xwayland python3.11-venv firefox-esr

# usermod -aG sudo $myusername

read -p "press enter to add sway to .profile"

vim $homedir/.profile

mkdir -p $homedir/.config/sway

cd $homedir

cd autologin

tar xvfz geckodriver-v0.35.0-linux64.tar.gz


cp config $homedir/.config/sway

python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install selenium

deactivate

cd $homedir/.config/sway

echo -e "\n\n"
read -p "press enter to configure display"
vim config


chown -Rv 1000:1000 $homedir

read -p "Press enter to configure the autologin python script"
