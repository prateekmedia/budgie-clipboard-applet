<h1 align="center">Budgie Clipboard Manager</h1>  
<h2 align="center">Under Development</h2>
A clipboard manager applet that can help you to store and manage clipboard content on the Budgie desktop, Written using Vala.

# Dependencies for Building from source

### *For Solus* 

- `sudo eopkg it vala budgie-desktop-devel meson`

### *For Debian/ Ubuntu or its Derivatives* 

- `sudo apt install budgie-core-dev libglib2.0-dev libgtk-3-dev libpeas-dev meson valac`

### *For Arch or its Derivatives*
- `sudo pacman -S budgie-desktop json-glib libgee libpeas intltool meson ninja vala`

# Building from source
Run from the repo's folder:

- `mkdir build && cd build`

- `meson --buildtype plain --prefix=/usr --libdir=/usr/lib`

- `ninja`

- `sudo ninja install`

