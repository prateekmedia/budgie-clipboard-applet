<p align="center"><a href="#budgie-clipboard-manager"><img src="https://raw.githubusercontent.com/prateekmedia/budgie-clipboard-applet/main/icons/clipmgr.png" height=80px alt="Clipboard manager Logo"/></a></p>
<h1 align="center">Budgie Clipboard Manager</h1>
<p align="center"><b>v0.9.75</b></p>

A clipboard manager applet that can help you to store and manage clipboard content. Made with ♥️ for budgie desktop.


## FEATURES
- [x] Automatically save copied / selected text to Clipboard Manager
- [x] Clear all option
- [x] Private mode option that let's you copy/select anything without saving it to Clipboard manager
- [x] Remove icon next to every clip, that let's you remove any clip you  want
- [x] Save up to 100 Clips
- [x] Search as you type to find the clip that you want
- [x] Automatically save clips to schemas so that they are not lost after restart
- [x] Tooltip in every copied item that let's you distinguish it from others
- [x] Notification support for copied items from applet
- [x] Option to restore defaults if you have messed up some of the settings

## CONTRIBUTION
-  Pull requests are welcome that solve [TODO](#todo) or add any useful feature / solves any bug
-  You can use `Issues` tab for reporting issues
  
## Dependencies for Building from source

<details><summary><b>For Solus</b></summary>

```
$ sudo eopkg it budgie-desktop-devel vala -c system.devel
```
</details>
<details><summary><b>For Debian/ Ubuntu based Distro</b></summary>

```
$ sudo apt install budgie-core-dev meson valac
```
</details>
<details><summary><b>For Arch based Distro</b></summary>

```
$ sudo pacman -S budgie-desktop
```
</details>


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

<details><summary><h2>For reinstalling / Uninstalling</h2></summary>
If you want to reinstall the applet, then run from the extracted repo's folder:

```
$ sudo ninja -C build install
```
Likewise the applet can be **uninstalled** by using 
```
$ sudo ninja -C build uninstall
```
</details>

### Debug the applet
```
$ budgie-panel --replace &!
```

## TODO
- [ ] Study [davidmhewitt / clipped](https://github.com/davidmhewitt/clipped) for features/solving issues
- [ ] Solve [Issues](https://github.com/prateekmedia/budgie-clipboard-applet/issues)
