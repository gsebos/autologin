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

apt vim install sudo sway xorg xwayland python3.11-venv

usermod -aG sudo $myusername

read -p "press enter to add sway to .profile"

vim $homedir/.profile

mkdir -p $homedir/.config/sway

cd $homedir
git clone https://github.com/gsebos/autologin.git

cd autologin
cp config $homedir/.config/sway

python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install selenium

deactivate

cd $homedir/.config/sway

echo -e "\n\n"
echo "output id is $(swaymsg -t get_outputs)"
read -p "press enter to configure display"
vim config


chown -Rv 1000:1000 $homedir
