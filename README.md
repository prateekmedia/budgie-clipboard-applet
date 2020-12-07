<p align="center"><a href="#budgie-clipboard-manager"><img src="https://raw.githubusercontent.com/prateekmedia/budgie-clipboard-applet/main/clipmgr-darkicon.png" height=80px alt="NSS Logo"/></a></p>
<h1 align="center">Budgie Clipboard Manager</h1>
<p align="center"><b>v0.9.5</b></p>
A clipboard manager applet that can help you to store and manage clipboard content on the Budgie desktop, Written using Vala
<br>

## FEATURES
- [x] Automatically save copied / selected content from Clipboard
- [x] Empty Clipboard option
- [x] Private mode option that let's you copy/select anything without saving it to Clipboard manager
- [x] Edit mode option that let's you remove any content from Clipboard manager
- [x] Save up to 100 Clips
- [x] Scrollable Clipboard, so that multiple clips doesn't occupy whole screen.
- [x] Search as you type to find the clip that you want
- [x] Minimal Interface
- [x] Option to restore defaults if you have messed up some of the settings.

## CONTRIBUTION
-  Pull requests are welcome that solve [TODO](#todo) or add any useful feature / solves any bug
-  You can use `Issues` tab for reporting issues
  
## Dependencies for Building from source

### *For Solus* 

```
$ sudo eopkg it budgie-desktop-devel vala -c system.devel
```

### *For Debian/ Ubuntu based Distro* 

```
$ sudo apt install budgie-core-dev meson valac
```

### *For Arch based Distro*
```
$ sudo pacman -S budgie-desktop
```

## Building from source / Updating the applet
Download the zip & then run from the extracted repo's folder:

```
$ mkdir build; cd build
```

```
$ meson --buildtype plain --prefix=/usr --libdir=/usr/lib
```

```
$ sudo ninja install
```

## For reinstalling
If you want to reinstall the applet, then run from the extracted repo's folder:

```
$ sudo ninja -C build install
```
Likewise the applet can be **uninstalled** by using 
```
$ sudo ninja -C build uninstall
```

### Debug the applet
```
$ budgie-panel --replace &!
```

## TODO
- [ ] Solve [Issues](https://github.com/prateekmedia/budgie-clipboard-applet/issues)
