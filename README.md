# Debian-Sway based kiosk

This set of instructions aims to create a single application kiosk. In this instance it uses Firefox in Kiosk mode but this can be adapted to any application. Sway can be configured to display the desired application fullscreen and with no border.

## Set up

### Debian Installation

Install Debian in expert mode so that all options are availble during installation. During installation:
- choose guided partition, entire disk (or a different layout for your use case but it should not really matter)
- choose home in the same partition as the root partition for simplicity
- Create a user called `kiosk-user`
- Make sure to **enable auto update for security updates**
- In the software section make sure to **untick any desktop envorionment and only pick SSH server** so that you get a minimal server installation

### First steps and cloning the repository

On reboot after installation, login as root.

1. Run update and upgrade:
```
apt update && apt upgrade
```
2. Install git
```
apt install git
```
3. cd to the kiosk-user home
```
cd /home/kiosk-user
```
4. Clone this repository in the kiosk-user home folder
```
git clone https://github.com/gsebos/autologin
```  
5. cd into the resulting folder
```
cd autologin
```
6. Make the sway_kiosk.sh script executable
```
chmod +x sway_kiosk.sh
```
7. run sway_kiosk.sh 
```
./sway_kiosk.sh
```

### sway_kiosk.sh

This script installs [sway](https://swaywm.org/) (a window manager and wayland coompositor), Firefox ESR and some dependencies for this set up.

On running the script, this will prompt you for the username. Enter kiosk-user (if you are following this to the letter, otherwise if you have name your user differently during the OS install, use that)

The script will stop at several steps to allow editing of necessary configuration files. This uses vim, press `i` to enter insert mode, this lets you edit the document. When done, press `esc` then `:wq` to save and quit. On quitting, the script will continue running.

The following configuration will come up during the script
1. Display configuration
This will open sway configuration file`/home/kiosk-user/.config/sway/config`. If your display is connected via Display Port, the display name will likely be `DP-1`, for HDMI, this will be `HDMI-A-1`. If you don't know the display name yet, just quit for now (`esc` then `:q`), you will be able to come back to that later. The line to change in the config file is:
Enter insert mode (`i`)

```
### Output configuration
#
# Default wallpaper (more resolutions are available in /usr/share/backgrounds/sway/)
#output * bg /home/seb/Pictures/Wallpapers/debian-linux-mountains.jpg fill
#
# Example configuration:
#
#   output HDMI-A-1 resolution 1920x1080 position 1920,0       <------------ edit this line, remove the leading # to uncomment and change HDMI-A-1 to your display name, optionally adjust the resolution
#
# You can get the names of your outputs by running: swaymsg -t get_outputs

```
then save and quit hit `esc` then type `:wq`

2. Python Script
You are then prompted to configure a python script. This is not required for anything else than this specific example for which it is optional. This can be used as a template for other python scripts. It automates logging into the web application which can be helpful if the web cached and cookies get reset, then the script can be run remotely via SSH. If using the script, you will neeed the username and password of the user to log in to EventMap Booker Display App.
Enter insert mode (`i`)
Edit these lines:
```
username = ""   <---- add username between the quotes
password = ""  <----- add password between the quotes
 
gecko_diver_path = "/home/kiosk-user/autologin/geckodriver"
url = "https://roomdisplay.is.ed.ac.uk/Display?rooms=2104,2105,1846,2106,2107,2108,2109,2021,1849&branding=ev&type=lobbyCalendar&reEntry=1&confAuth=pin&calendarType=bookin"
```

NB: the pyhon dependencies and virtual environment are installed and created when sway_kiosk.sh is run.

3. Auto Login

The next prompt for configuration is auto login. The Script installs [LightDM]([url](https://wiki.archlinux.org/title/LightDM)), a display manager (a GUI for user log in in Linux based suystems) that will handle auto login. The configuration file that is open is `/etc/lightdm/lightdm.conf`

Enter insert mode (`i`)
Edit this line (remove the leading `#` to uncomment and add the appropriate username):
```
autologin-user=kiosk-user
autologin-user-timeout=0
```
then save and quit hit `esc` then type `:wq`

If all went well, you should see the message "set up completed" and no error codes.


### configure firefox

Reboot the system, if you do not get straight to a firfox page, reboot again. Press `windows button` + `q` this will close the kiosk window. There should be another firefox window behind it. In Firefox set a custom URL for Homepage and new windows to the desired web app. Navigate to the URL and make sure that you log in so that the credentials are saved and cookies keeps the session open between restarts. 

Reboot once more, this time this should go straight to the firefox kiosk and to the web app of choice.


## Set up summary and further notes

### What happens on boot:
1. LightDM auto logs in  `kiosk-user`
2. `/home/kiosk-user/.bash_login` contains the command to start sway (`sway`) so sway is started automatically on login
3. sway configuration file contains the `exec` command for the `start-kiosk.sh` scripts which starts firefox in kiosk mode

### start-kiosk.sh

This can be run remotely in case the network drops or for whatever reason firefox needs to be restarted. You need to export the `DISPLAY` environment variable in order to launch firefox (or the `start-kiosk.sh` script) remotely from an SSH session:
In an SSH session, run
```
export DISPLAY=:0
/home/kiosk-user/autologin/start-kiosk.sh
```

#### If the cached credentials are lost
if the kiosk resets back to a login screen, the python script at `/home/kiosk-user/login_to_eventmap.py` can be used. Ensure that the username and password variables have been updated. Alternatively, plug in peripherals to the PC and relogin in firefox directly, you'll need to re-enable inputs if you have disabled them (see below).


### disabling all inputs
Sway can be configured to disable all inputs so that keyboard and mouse plugged into the kiosk PC will not work at all (preventing tempering with the PC). This is achieved by running the following command:
```
echo "input * events disabled" >> /home/kiosk-user/.config/sway/config
```

WARNING: the PC will then only be controllable from a remote SSH session or by starting it in rescue mode. Inputs can be activated again by editing the  `/home/kiosk-user/.config/sway/config` config file and removing this line:
`input * events disabled`

If using vim, place the cursor on this line and type `dd` in normal mode (press `esc` before to ensure that you are in normal mode). Then save and quit (`esc` then type `:wq`)

## Sway shortcuts

`window key` + `q` : Close the active window

`window key` + `Enter`: opens a terminal


## TODO
- add script `login_to_eventmap.sh` with full environment path to run the python script using the virtual environment.
- include lightdm config file and install it during the `sway_kiosk.sh` script







