# Budgie Clipboard Manager
This is an clipboard manager applet made to store and manage clipboard content in Budgie desktop. Written in Vala.

# Dependencies for Building from source

## In solus 

- `sudo eopkg it budgie-desktop-devel accountsservice-devel alsa-lib-devel gnome-bluetooth-devel gtk-doc gnome-settings-daemon-devel ibus-devel libgnome-desktop-devel libgnome-menus-devel libnotify-devel libpeas-devel libwnck-devel mutter-devel pulseaudio-devel sassc upower-devel vala -c system.devel`

## In Debian/ Ubuntu 

- `sudo apt install budgie-core-dev libglib2.0-dev libgtk-3-dev libpeas-dev meson valac`

# Building from source
Run from the repo's folder:

- `mkdir build && cd build`

- `meson --buildtype plain --prefix=/usr --libdir=/usr/lib`

- `ninja`

- `sudo ninja install`

