<p align="center"><a href="#budgie-clipboard-manager"><img src="https://raw.githubusercontent.com/prateekmedia/budgie-clipboard-applet/main/clipmgr-darkicon.png" height=80px alt="NSS Logo"/></a></p>
<h1 align="center">Budgie Clipboard Manager</h1>
<p align="center"><b>Version - 0.8.5</b></p>
A clipboard manager applet that can help you to store and manage clipboard content on the Budgie desktop, Written using Vala.  

**To debug the applet use below command**   
```
$ budgie-panel --replace &!
```

## FEATURES
- [x] Automatically save copied / selected content from clipboard
- [x] Empty clipboard option
- [x] Private mode option that let's you copy/select anything without saving it to clipboard
- [x] Edit mode option that let's you remove any content from Clipboard manager(in Beta)
- [x] Save up to 100 Clips
- [x] Pager Navigation available, so that if clipboard fills out then it will not take the whole screen
- [x] Search bar that lets you search across all of your clips
- [x] Option to enable Minimal Interface for minimalist users

## CONTRIBUTION
-  Pull requests are welcome that solve [TODO](#todo) or add any useful feature / solves any bug
  
## Dependencies for Building from source

### *For Solus* 

```
$ sudo eopkg it budgie-desktop-devel vala -c system.devel
```

### *For Debian/ Ubuntu or its Derivatives* 

```
$ sudo apt install budgie-core-dev libglib2.0-dev libgtk-3-dev libpeas-dev meson valac
```

### *For Arch or its Derivatives*
```
$ sudo pacman -S budgie-desktop libpeas intltool meson vala
```

## Building from source
Download the zip & then run from the repo's folder:

```
$ rm -rf build; mkdir build && cd build
```

```
$ meson --buildtype plain --prefix=/usr --libdir=/usr/lib
```

```
$ sudo ninja install
```

## TODO
- [ ] Save history to schemas every time a thing is copied to clipboard
- [ ] Solve [Issues](https://github.com/prateekmedia/budgie-clipboard-applet/issues)
