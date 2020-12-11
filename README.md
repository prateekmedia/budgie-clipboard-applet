<p align="center"><a href="#budgie-clipboard-manager"><img src="https://raw.githubusercontent.com/prateekmedia/budgie-clipboard-applet/main/icons/clipmgr.png" height=80px alt="Clipboard manager Logo"/></a></p>
<h1 align="center">Budgie Clipboard Manager</h1>
<p align="center"><b>v0.9.8</b></p>

A clipboard manager applet that can help you to store and manage clipboard content. Made with ♥️ for budgie desktop.

<p align="center"><img src="https://user-images.githubusercontent.com/41370460/101914592-7ec29700-3bea-11eb-8cd5-d1ede0a2c366.png" alt="Clipboard manager Logo"/></p>

## FEATURES
- [x] Automatically save copied / selected text to Clipboard Manager
- [x] Save up to 100 Clips
- [x] Private mode option that let's you copy/select anything without saving it to Clipboard manager
- [x] Remove icon next to every clip, that let's you remove any clip you  want
- [x] Search as you type to find the clip that you want
- [x] Clear all option
- [x] Automatically save clips to a file so that they are not lost after restart
- [x] Tooltip in every copied item that let's you distinguish it from others
- [x] Notification support for copied items from applet
- [x] Multiple options to configure applet using Budgie desktop Settings
- [x] Option to restore defaults if you have messed up some of the settings

## CONTRIBUTION
-  Pull requests are welcome whether it be translations, adding any useful feature / solving any bugs
-  You can use `Issues` tab for reporting issues
  
## Dependencies for Building from source

**For Solus**
```
$ sudo eopkg it budgie-desktop-devel vala -c system.devel
```

**For Debian/ Ubuntu based Distro**
```
$ sudo apt install budgie-core-dev meson valac
```
**For Arch based Distro**
```
$ sudo pacman -S budgie-desktop
```


## Building from source / Updating the applet
Download the [zip](https://github.com/prateekmedia/budgie-clipboard-applet/releases/latest) & then run from the extracted repo's folder:

```
$ mkdir build; cd build
```

```
$ meson --buildtype plain --prefix=/usr --libdir=/usr/lib
```

```
$ sudo ninja install
```

<h2>For reinstalling / Uninstalling</h2>
If you want to reinstall the applet, then run this from the extracted repo's folder:

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
