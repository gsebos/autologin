# Debian-Sway based kiosk

This set of instructions aims to create a single application kiosk. In this instance it uses Firefox in Kiosk mode but this can be adapted to any application. Sway can be configured to display the desired application fullscreen and with no border.

## Set up

### Debian Installation

Install Debian in expert mode so that all options are availble during installation. During installation:
- choose guided partition, entire disk (or a different layout for your use case but it should not really matter)
- choose home in the same partition as the root partition for simplicity
- Create a user called `kiosk-user`
- Make sure to **enable auto update for security updates**
- In the software section make sure to **untick any desktop environment and only pick SSH server** so that you get a minimal server installation

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

The script will stop at several steps to allow editing of necessary configuration files. This uses vim, when the screen changes to show the file content, press `i` to enter insert mode, this lets you edit the document. When done, press `esc` then `:wq` to save and quit. On quitting, the script will continue running.

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
You are then prompted to configure a python script. This is not required for anything else than this specific example. This can be used as a template for other python scripts. It automates logging into the web application and is used by the `start-kiosk.sh` script. You will neeed the username and password of the user to log in to EventMap Booker Display App as well as updating the `url` variable to your URL.
Enter insert mode (`i`)
Edit these lines:
```
username = ""   <---- add username between the quotes
password = ""  <----- add password between the quotes
 
gecko_diver_path = "/home/kiosk-user/autologin/geckodriver"

# replace this with your URL: 
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


### Finishing touches 

#### set up CRON

A cron task to run the `start-kiosk.sh` script every day at 7 am (or other suitable time) should be set up to relogin to the app (which seems to auto log out overnight). To do so run
```
crontab -e 
```
and in the file that opens add at the very end add:
```
0 7 * * * /home/kiosk-user/autologin/start-kiosk.sh >> /home/kiosk-user/cron.log

```

#### Getting the correct resolution (optional)

If the resolution does not look right, it needs to be configured. This needs to be done on initial set up while working directly on the machine (i.e. not via SSH).

Find the correct display output name:
```
swaymsg -t get_outputs
```

Open the sway configuration file in vim (or your preferred text editor):

```
vim /home/kiosk-user/.config/sway/config
```

then edit as indicated below, adding the correct display output name resulting from the above command:

```
### Output configuration
#
# Default wallpaper (more resolutions are available in /usr/share/backgrounds/sway/)
#output * bg /home/seb/Pictures/Wallpapers/debian-linux-mountains.jpg fill
#
# Example configuration:
#
#   output HDMI-A-1 resolution 1920x1080 position 1920,0       <------------ edit this line, remove the leading # to uncomment and change HDMI-A-1 to your display output name, optionally adjust the resolution
#
# You can get the names of your outputs by running: swaymsg -t get_outputs

```


## Set up summary and further notes

### What happens on boot:
1. LightDM auto logs in  `kiosk-user`
2. `/home/kiosk-user/.bash_login` contains the command to start sway (`sway`) so sway is started automatically on login
3. sway configuration file contains the `exec` command for the `start-kiosk.sh` scripts which starts firefox in kiosk mode

### start-kiosk.sh

This can be run remotely in case the network drops or for whatever reason firefox needs to be restarted:
In an SSH session, run
```
/home/kiosk-user/autologin/start-kiosk.sh
```

#### If the cached credentials are lost
if the kiosk resets back to a login screen, re-run `./start-kiosk.sh`, this will kill all instances of firefox and run the the auto login python script.

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

## Troubleshooting

If the kiosk is not displaying correctly, you will need to connect to the machine remotely via ssh as `kiosk-user`.

Once connected, cd to the autologin folder
```
cd autologin
```
then run the `start-kiosk.sh` script. This will kill the current firefox process and will then run the `login_to_eventmap.py` (the automated login script):
```
./start-kiosk.sh
```
After a couple of minutes the kiosk should be back to the application screen.

If further intervention and/or troubleshooting is required you may need to work on the PC directly. To do this, you will first need to re-enable inputs (keyboard and mouse).
Edit `~/kiosk-user/.config/sway/config` using vim or another text editor like nano and remove the line below (at the very bottom of the document)
```
input * events disabled
```
Reboot the PC and you can then use a keyboard and mouse. Check the sway keyboard shortcut above as you will need those to open up a terminal in sway. Alternatively, open a TTY by pressing `ctrl`+`alt`+`f2` or `ctrl`+`alt`+`f3`, login and work from the TTY (but you won't be able to launch firefox or other GUI applications from there)

## TODO
- Document cron task and what to do in case of logout/error
- include lightdm config file and install it during the `sway_kiosk.sh` script







