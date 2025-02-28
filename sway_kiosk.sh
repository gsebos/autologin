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

apt  install vim sudo sway xorg xwayland python3.11-venv firefox-esr tmux lightdm

# usermod -aG sudo $myusername

mkdir -p $homedir/.config/sway

cd $homedir

echo "MOZ_DISABLE_RDD_SANDBOX=1" >> .bash_login
echo "MOZ_ENABLE_WAYLAND=1" >> .bash_login

echo "sway" >> .bash_login

cd autologin

chmod +x start-kiosk.sh

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

echo -e "\n\n"
echo "Press enter to configure the autologin python script"
read -p "You will need the username and password and the URL if it has changed"

vim $homedir/autologin/login_to_eventmap.py

echo -e "\n\n"
read -p "enable autologin in lightdm uncomment under [Seat:*]"
vim /etc/lightdm/lightdm.conf

groupadd -r autologin
gpasswd -a $myusername autologin

echo -e "\n\n"
read -p "Now configure the URL home page for firefox and login to eventmap"
firefox

echo "input * events disabled" >> $homedir/.config/sway/config

echo "setup completed"
