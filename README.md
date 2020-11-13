<p align="center"><a href="#budgie-clipboard-manager"><img src="https://raw.githubusercontent.com/prateekmedia/budgie-clipboard-applet/main/clipmgr-darkicon.png" height=80px alt="NSS Logo"/></a></p>
<h1 align="center">Budgie Clipboard Manager</h1>
A clipboard manager applet that can help you to store and manage clipboard content on the Budgie desktop, Written using Vala.  
  
  
**To debug the applet type `budgie-panel --replace &!` on the terminal**  
  
## Dependencies for Building from source

### *For Solus* 

- `sudo eopkg it budgie-desktop-devel meson vala`

### *For Debian/ Ubuntu or its Derivatives* 

- `sudo apt install budgie-core-dev libglib2.0-dev libgtk-3-dev libpeas-dev meson valac`

### *For Arch or its Derivatives*
- `sudo pacman -S budgie-desktop libpeas intltool meson vala`

## Building from source
Download the zip & then run from the repo's folder:

- `mkdir build && cd build`

- `meson --buildtype plain --prefix=/usr --libdir=/usr/lib`

- `sudo ninja install`
