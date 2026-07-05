# XLibre for Arch Linux based Systems

[XLibre](https://grokipedia.com/page/XLibre) is the most actively developed community-maintained implementation of the [X Window System](https://en.wikipedia.org/wiki/X_Window_System) ( **X11** ) [display server](https://en.wikipedia.org/wiki/Windowing_system#Display_server). It has been forked from the [X.Org Server](https://en.wikipedia.org/wiki/X.Org_Server) of the [X.Org Foundation](https://en.wikipedia.org/wiki/X.Org_Foundation) in June 2025 and since then gained adoption in several Linux distributions as well as FreeBSD and GhostBSD.

Most of the following sections were taken from the [Xorg article](https://wiki.archlinux.org/title/Xorg) in the ArchWiki and, where necessary, adapted for XLibre and supplemented with additional information. Many links lead back to information about the X.Org server and X11 in general in the ArchWiki. Due to their common roots, this information largely applies to XLibre as well.

## Installation

XLibre can be [installed](https://wiki.archlinux.org/title/Install) with the x86_64 binaries provided by the XLibre project at [xlibre-arch.github.io](http://xlibre-arch.github.io) and its [mirror on the XLibre website](https://packages.xlibre.net/arch/stable/x86_64) as well as the [xlibre-meta](https://aur.archlinux.org/packages/xlibre-meta) AUR package

### Installing the x86_64 binary packages

#### Adding the Public Package Signing Key to pacman

First, please download the public OpenPGP signing key [`xlibre-archlinux.asc`](xlibre-archlinux.asc) used to sign the packages and add it to the pacman keyring:

```shell
curl -O https://xlibre-arch.github.io/xlibre-archlinux.asc
sudo pacman-key --add xlibre-archlinux.asc
sudo pacman-key --finger B97F7C613F359424
sudo pacman-key --lsign-key B97F7C613F359424
```

You can read more about package signing on the [pacman/Package signing - ArchWiki](https://wiki.archlinux.org/title/Pacman/Package_signing#Adding_unofficial_keys) page.

#### Adding the Repository to Pacman

Once you added the public key, also add an entry for the XLibre repository to the end of the file [`/etc/pacman.conf`](https://man.archlinux.org/man/pacman.conf.5) using [`sudo`](https://wiki.archlinux.org/title/Sudo) and your favorite editor:

```ini
[xlibre]
Server = https://packages.xlibre.net/arch/stable/$arch
```

Run `pacman` to update all package indexes and installed packages:

```shell
sudo pacman -Syyu
```

#### Installing XLibre

Installing XLibre is as easy as installing the `xlibre-meta` package:

```shell
sudo pacman -S xlibre-meta
```

The included packages will replace any of their installed X.Org counterparts. When asked, just answer with `y `. To make use of XLibre, log out of your desktop or X session and log in again.

In case you get kicked out of a running desktop or X session while you're installing XLibre, just re-run `pacman` after you logged in again and let it install the missing packages:

```shell
sudo pacman -S xlibre-meta
```

When done, install [`xorg-xdpyinfo`](https://archlinux.org/packages/extra/x86_64/xorg-xdpyinfo) and filter its output for the `vendor` tags:

```shell
sudo pacman -S xorg-xdpyinfo
xdpyinfo | grep 'vendor'
```

### Additional Packages

Additionally, some packages from the [xorg-apps](https://archlinux.org/groups/x86_64/xorg-apps/) group are necessary for certain configuration tasks. They are pointed out in the relevant sections.

Finally, the [xorg-apps](https://archlinux.org/groups/x86_64/xorg-apps/) and [xorg-fonts](https://archlinux.org/groups/x86_64/xorg-fonts/) groups are also available to complement an XLibre Xserver installation.

### Drivers

See [Graphics processing unit#Installation](https://wiki.archlinux.org/title/Graphics_processing_unit#Installation) to identify your hardware and choose the driver for it.

Hardware-specific [Device Dependent X (DDX)](https://dri.freedesktop.org/wiki/DDX/) drivers are considered legacy: there is a generic [modesetting(4)](https://man.archlinux.org/man/modesetting.4) DDX driver in [xlibre-xserver](https://aur.archlinux.org/packages/xlibre-xserver), which uses [kernel mode setting](https://wiki.archlinux.org/title/Kernel_mode_setting) and works well on modern hardware. The modesetting DDX driver uses [Glamor](https://www.freedesktop.org/wiki/Software/Glamor/) [[1]](https://gitlab.freedesktop.org/xorg/xserver/-/tree/server-21.1-branch/glamor) for 2D acceleration, which requires [OpenGL](https://wiki.archlinux.org/title/OpenGL).

If you want to install another DDX driver, note that XLibre searches for installed DDX drivers automatically:

* If it cannot find the specific driver installed for the hardware (listed in [Graphics processing unit#Installation](https://wiki.archlinux.org/title/Graphics_processing_unit#Installation)), it first searches for *fbdev* ([xlibre-video-fbdev](https://aur.archlinux.org/packages/xlibre-video-fbdev)), which does not include any 2D or 3D acceleration.
* If that is not found, it searches for *vesa* ([xlibre-video-vesa](https://aur.archlinux.org/packages/xlibre-video-vesa)), the generic driver, which handles a large number of chipsets but does not include any 2D or 3D acceleration.
* If *vesa* is not found, XLibre will fall back to [modesetting(4)](https://man.archlinux.org/man/modesetting.4) DDX driver.

## Running

The [Xorg(1)](https://man.archlinux.org/man/Xorg.1) command is usually not run directly. Instead, the X server is started with either a [display manager](https://wiki.archlinux.org/title/Display_manager) or [xinit](https://wiki.archlinux.org/title/Xinit).

> [!TIP]
> You will typically seek to install a [window manager](https://wiki.archlinux.org/title/Window_manager) or a [desktop environment](https://wiki.archlinux.org/title/Desktop_environment) to supplement X.

## Configuration

> [!NOTE]
> Arch supplies default configuration files in `/usr/share/X11/xorg.conf.d/`, and no extra configuration is necessary for most setups.

XLibre uses a configuration file called `xorg.conf` and files ending in the suffix `.conf` for its initial setup: the complete list of the folders where these files are searched can be found in [xorg.conf(5)](https://man.archlinux.org/man/xorg.conf.5), together with a detailed explanation of all the available options.

### Using .conf files

The `/etc/X11/xorg.conf.d/` directory stores host-specific configuration. You are free to add configuration files there, but they must have a `.conf` suffix: the files are read in ASCII order, and by convention their names start with `XX -` (two digits and a hyphen, so that for example 10 is read before 20). These files are parsed by the X server upon startup and are treated like part of the traditional `xorg.conf` configuration file. Note that on conflicting configuration, the file read *last* will be processed. For this reason, the most generic configuration files should be ordered first by name. The configuration entries in the `xorg.conf` file are processed at the end.

For option examples to set, see [Fedora:Input device configuration#xorg.conf.d](https://fedoraproject.org/wiki/Input_device_configuration#xorg.conf.d).

### Using xorg.conf

XLibre can also be configured via `/etc/X11/xorg.conf` or `/etc/xorg.conf`. You can also generate a skeleton for `xorg.conf` with:

```bash
# Xorg :0 -configure
```

This should create a `xorg.conf.new` file in `/root/` that you can copy over to `/etc/X11/xorg.conf`.

> [!TIP]
> If you are already running an X server, use a different display, for example `Xorg :2 -configure` .

Alternatively, your proprietary video card drivers may come with a tool to automatically configure XLibre: see the article of your video driver, [NVIDIA](https://wiki.archlinux.org/title/NVIDIA), for more details.

> [!NOTE]
> Configuration file keywords are case insensitive, and "_" characters are ignored. Most strings (including Option names) are also case insensitive, and insensitive to white space and "_" characters.

## Input devices

For input devices the X server defaults to the libinput driver ( [xlibre-input-libinput](https://aur.archlinux.org/packages/xlibre-input-libinput) ), but [xlibre-input-evdev](https://aur.archlinux.org/packages/xlibre-input-evdev) and related drivers are available as alternative. [[2]](https://archlinux.org/news/xorg-server-1191-is-now-in-extra/)

[Udev](https://wiki.archlinux.org/title/Udev), which is provided as a systemd dependency, will detect hardware and both drivers will act as hotplugging input driver for almost all devices, as defined in the default configuration files `10-quirks.conf` and `40-libinput.conf` in the `/usr/share/X11/xorg.conf.d/` directory.

After starting X server, the log file will show which driver hotplugged for the individual devices (note the most recent log file name may vary):

```bash
$ grep -e "Using input driver " Xorg.0.log
```

If both do not support a particular device, install the needed driver from the list of available [xlibre input drivers](https://aur.archlinux.org/packages?K=xlibre-input). The same applies, if you want to use another driver.

To influence hotplugging, see [#Configuration](#Configuration).

For specific instructions, see also the [libinput](https://wiki.archlinux.org/title/Libinput) article, the following pages below, or [Fedora:Input device configuration](https://fedoraproject.org/wiki/Input_device_configuration) for more examples.

### Input identification

See [Keyboard input#Identifying keycodes in Xorg](https://wiki.archlinux.org/title/Keyboard_input#Identifying_keycodes_in_Xorg).

### Mouse acceleration

See [Mouse acceleration](https://wiki.archlinux.org/title/Mouse_acceleration).

### Extra mouse buttons

See [Mouse buttons](https://wiki.archlinux.org/title/Mouse_buttons).

### Touchpad

See [libinput](https://wiki.archlinux.org/title/Libinput) or [Synaptics](https://wiki.archlinux.org/title/Synaptics).

### Touchscreen

See [Touchscreen](https://wiki.archlinux.org/title/Touchscreen).

### Keyboard settings

See [Keyboard configuration in Xorg](https://wiki.archlinux.org/title/Keyboard_configuration_in_Xorg).

## Monitor settings

### Manual configuration

> [!NOTE]
> * Newer versions of XLibre are auto-configuring, so manual configuration should not be needed.
> * If XLibre is unable to detect any monitor or to avoid auto-configuring, a configuration file can be used. A common case where this is necessary is a headless system, which boots without a monitor and starts XLibre automatically, either from a [virtual console](https://wiki.archlinux.org/title/Automatic_login_to_virtual_console) at, or from a [display manager](https://wiki.archlinux.org/title/Display_manager) .

For a headless configuration, the [xlibre-video-dummy](https://aur.archlinux.org/packages/xlibre-video-dummy) driver is necessary; [install](https://wiki.archlinux.org/title/Install) it and create a configuration file, such as the following:

/etc/X11/xorg.conf.d/10-headless.conf

```ini
/etc/X11/xorg.conf.d/10-headless.conf

Section "Monitor"
        Identifier "dummy_monitor"
        HorizSync 28.0-80.0
        VertRefresh 48.0-75.0
        Modeline "1920x1080" 172.80 1920 2040 2248 2576 1080 1081 1084 1118
EndSection

Section "Device"
        Identifier "dummy_card"
        VideoRam 256000
        Driver "dummy"
EndSection

Section "Screen"
        Identifier "dummy_screen"
        Device "dummy_card"
        Monitor "dummy_monitor"
        SubSection "Display"
        EndSubSection
EndSection
```

### Multiple monitors

See main article [Multihead](https://wiki.archlinux.org/title/Multihead) for general information.

#### More than one graphics card

You must define the correct driver to use and put the bus ID of your graphic cards (in decimal notation).

```ini
Section "Device"
    Identifier             "Screen0"
    Driver                 "intel"
    BusID                  "PCI:0:2:0"
EndSection

Section "Device"
    Identifier             "Screen1"
    Driver                 "nouveau"
    BusID                  "PCI:1:0:0"
EndSection
```

To get your bus IDs (in hexadecimal):

```bash
$ lspci -d ::03xx

00:02.0 VGA compatible controller: Intel Corporation HD Graphics 630 (rev 04)
01:00.0 3D controller: NVIDIA Corporation GP107M [GeForce GTX 1050 Mobile] (rev a1)
```

The bus IDs here are `0:2:0` and `1:0:0`.

### Display size and DPI

By default, XLibre always sets DPI to 96. FIXME A change was made with version 21.1 to provide proper DPI auto-detection, but [reverted](https://gitlab.freedesktop.org/xorg/xserver/-/commit/35af1299e73483eaf93d913a960e1d1738bc7de6).

The DPI of the X server can be set with the `-dpi` command line option.

Having the correct DPI is helpful where fine detail is required (like font rendering). Previously, manufacturers tried to create a standard for 96 DPI (a 10.3" diagonal monitor would be 800x600, a 13.2" monitor 1024x768). These days, screen DPIs vary and may not be equal horizontally and vertically. For example, a 19" widescreen LCD at 1440x900 may have a DPI of 89x87.

To see if your display size and DPI are correct:

```bash
$ xdpyinfo | grep -B2 resolution
```

Check that the dimensions match your display size.

If you have specifications on the physical size of the screen, they can be entered in the XLibre configuration file so that the proper DPI is calculated (adjust identifier to your xrandr output):

```ini
Section "Monitor"
    Identifier             "DVI-D-0"
    DisplaySize             286 179    # In millimeters
EndSection
```

If you only want to enter the specification of your monitor **without** creating a full xorg.conf, create a new configuration file. For example (`/etc/X11/xorg.conf.d/90-monitor.conf`):

```ini
Section "Monitor"
    Identifier             "<default monitor>"
    DisplaySize            286 179    # In millimeters
EndSection
```

> [!NOTE]
> If you are using the proprietary NVIDIA driver, you may have to put `Option "UseEdidDpi" "FALSE"` under `Device` or `Screen` section to make it take effect.

If you do not have specifications for physical screen width and height (most specifications these days only list by diagonal size), you can use the monitor's native resolution (or aspect ratio) and diagonal length to calculate the horizontal and vertical physical dimensions. Using the Pythagorean theorem on a 13.3" diagonal length screen with a 1280x800 native resolution (or 16:10 aspect ratio):

```bash
$ echo 'scale=5;sqrt(1280^2+800^2)' | bc  # 1509.43698
```

This will give the pixel diagonal length, and with this value you can discover the physical horizontal and vertical lengths (and convert them to millimeters):

```bash
$ echo 'scale=5;(13.3/1509)*1280*25.4' | bc  # 286.43072
$ echo 'scale=5;(13.3/1509)*800*25.4'  | bc  # 179.01920
```

> [!NOTE]
> This calculation works for monitors with square pixels; however, there is the rare monitor that may compress aspect ratio (e.g 16:10 aspect resolution to a 16:9 monitor). If this is the case, you should measure your screen size manually.

#### Setting DPI manually

> [!NOTE]
> While you can set any DPI you like and applications using Qt and GTK will scale accordingly, it is recommended to set it to **96** (100%, no scaling), **120** (25% higher), **144** (50% higher), **168** (75% higher), **192** (100% higher) etc., to reduce scaling artifacts to GUIs that use bitmaps. Reducing it below 96 DPI may not reduce the size of the GUIs graphical elements, as typically the lowest DPI the icons are made for is 96.

For RandR compliant drivers (for example the open source ATI driver), you can set it by:

```bash
$ xrandr --dpi 144
```

> [!NOTE]
> Applications that comply with the setting will not change immediately. You have to start them anew.

To make it permanent, see [Autostarting#On Xorg startup](https://wiki.archlinux.org/title/Autostarting#On_Xorg_startup).

##### Proprietary NVIDIA driver

You can manually set the DPI by adding the option under the `Device` or `Screen` section:

```ini
Option              "DPI" "96 x 96"
```

##### Manual DPI Setting Caveat

GTK very often overrides the server's DPI via the optional [X resource](https://wiki.archlinux.org/title/X_resource) `Xft.dpi`. To find out whether this is happening to you, check with:

```bash
$ xrdb -query | grep dpi
```

With GTK library versions since 3.16, when this variable is not otherwise explicitly set, GTK sets it to 96. To have GTK apps obey the server DPI you may need to explicitly set `Xft.dpi` to the same value as the server. The `Xft.dpi` resource is the method by which some desktop environments optionally force DPI to a particular value in personal settings. Among these are [KDE](https://wiki.archlinux.org/title/KDE) and [TDE](https://wiki.archlinux.org/title/TDE).

### Variable refresh rate (VRR)

See [Variable refresh rate](https://wiki.archlinux.org/title/Variable_refresh_rate).

### Display Power Management

[DPMS](https://wiki.archlinux.org/title/DPMS) is a technology that allows power saving behaviour of monitors when the computer is not in use. This will allow you to have your monitors automatically go into standby after a predefined period of time.

## Composite

The Composite extension for X causes an entire sub-tree of the window hierarchy to be rendered to an off-screen buffer. Applications can then take the contents of that buffer and do whatever they like. The off-screen buffer can be automatically merged into the parent window, or merged by external programs called compositing managers. For more information, see [Wikipedia:Compositing window manager](https://en.wikipedia.org/wiki/Compositing_window_manager).

Some window managers (e.g. [Compiz](https://wiki.archlinux.org/title/Compiz), [Enlightenment](https://wiki.archlinux.org/title/Enlightenment), [KWin](https://wiki.archlinux.org/title/KWin), [marco](https://archlinux.org/packages/?name=marco), [metacity](https://archlinux.org/packages/?name=metacity), [muffin](https://archlinux.org/packages/?name=muffin), [mutter](https://archlinux.org/packages/?name=mutter), [Xfwm](https://wiki.archlinux.org/title/Xfwm)) do compositing on their own. For other window managers, a standalone composite manager can be used.

### List of composite managers

* **[Picom](https://wiki.archlinux.org/title/Picom)** — Lightweight compositor with shadowing, advanced blurring and fading. Forked from Compton.  
  [https://github.com/yshui/picom](https://github.com/yshui/picom) || [picom](https://archlinux.org/packages/?name=picom)

* **[Xcompmgr](https://wiki.archlinux.org/title/Xcompmgr)** — Composite window-effects manager.  
  [https://gitlab.freedesktop.org/xorg/app/xcompmgr/](https://gitlab.freedesktop.org/xorg/app/xcompmgr/) || [xcompmgr](https://archlinux.org/packages/?name=xcompmgr)

* **[fastcompmgr](https://wiki.archlinux.org/title/Fastcompmgr)** — A very lightweight compositor for X11 with a focus on latency & performance.  
  [https://github.com/tycho-kirchner/fastcompmgr](https://github.com/tycho-kirchner/fastcompmgr) || [fastcompmgr](https://aur.archlinux.org/packages/fastcompmgr/)AUR

* **[Gamescope](https://wiki.archlinux.org/title/Gamescope)** — The micro-compositor from Valve, with gaming-oriented features such as FSR upscaling. Forked from steamos-compositor.  
  [https://github.com/ValveSoftware/gamescope](https://github.com/ValveSoftware/gamescope) || [gamescope](https://archlinux.org/packages/?name=gamescope)

* **[steamos-compositor-plus](https://wiki.archlinux.org/title/Steamos-compositor-plus)** — Valve's compositor, with some added tweaks and fixes.  
  [https://github.com/chimeraos/steamos-compositor-plus](https://github.com/chimeraos/steamos-compositor-plus) || [steamos-compositor-plus](https://aur.archlinux.org/packages/steamos-compositor-plus/)AUR

## Tips and tricks

### Automation

This section lists utilities for automating keyboard / mouse input and window operations (like moving, resizing or raising).

| Tool | Package | Manual | [Keysym](https://wiki.archlinux.org/title/Keysym) input | Window operations | Note |
| --- | --- | --- | --- | --- | --- |
| xautomation | [xautomation](https://archlinux.org/packages/?name=xautomation) | [xte(1)](https://man.archlinux.org/man/xte.1) | Yes | No | Also contains screen scraping tools. Cannot simulate F13 and more. |
| xdo | [xdo](https://archlinux.org/packages/?name=xdo) | [xdo(1)](https://man.archlinux.org/man/xdo.1) | No | Yes | Small X utility to perform elementary actions on windows. |
| xdotool | [xdotool](https://archlinux.org/packages/?name=xdotool) |[xdotool(1)](https://man.archlinux.org/man/xdotool.1) | Yes | Yes | [Very buggy](https://github.com/jordansissel/xdotool/issues) and not in active development, e.g: has broken CLI parsing. [[3]](https://github.com/jordansissel/xdotool/issues/14#issuecomment-327968132) [[4]](https://github.com/jordansissel/xdotool/issues/71) |
| xvkbd | [xvkbd](https://aur.archlinux.org/packages/xvkbd/) AUR | [xvkbd(1)](http://t-sato.in.coocan.jp/xvkbd/#option) | Yes | No | Virtual keyboard for Xorg, also has the -text option for sending characters. |
| AutoKey | [autokey-qt](https://aur.archlinux.org/packages/autokey-qt/) AUR [autokey-gtk](https://aur.archlinux.org/packages/autokey-gtk/) AUR | [documentation](https://github.com/autokey/autokey#documentation) | Yes | Yes | Higher-level, powerful macro and scripting utility, with both Qt and Gtk front-ends. |

See also [Clipboard#Tools](https://wiki.archlinux.org/title/Clipboard#Tools) and [an overview of X automation tools](https://venam.nixers.net/blog/unix/2019/01/07/win-automation.html).

### Nested X session

 **This article or section is out of date.**

**Reason:** maybe tell about Xephyr before (Discuss in [Talk:Xorg](https://wiki.archlinux.org/title/Talk:Xorg) )

To run a nested session of another desktop environment:

```bash
$ /usr/bin/Xnest :1 -geometry 1024x768+0+0 -ac -name Windowmaker & wmaker -display :1
```

This will launch a Window Maker session in a 1024 by 768 window within your current X session.

This needs the package [xlibre-xserver-xnest](https://aur.archlinux.org/packages/xlibre-xserver-xnest) to be installed.

A more modern way of doing a nested X session is with [Xephyr](https://wiki.archlinux.org/title/Xephyr).

### Starting an application without a window manager

See [xinit#Starting applications without a window manager](https://wiki.archlinux.org/title/Xinit#Starting_applications_without_a_window_manager).

### Starting GUI programs remotely

See main article: [OpenSSH#X11 forwarding](https://wiki.archlinux.org/title/OpenSSH#X11_forwarding).

### On-demand disabling and enabling of input sources

With the help of *xinput* you can temporarily disable or enable input sources. This might be useful, for example, on systems that have more than one mouse, such as the ThinkPads and you would rather use just one to avoid unwanted mouse clicks.

[Install](https://wiki.archlinux.org/title/Install) the [xorg-xinput](https://archlinux.org/packages/?name=xorg-xinput) package.

Find the name or ID of the device you want to disable:

```bash
$ xinput
```

For example in a Lenovo ThinkPad T500, the output looks like this:

```
⎡ Virtual core pointer                          id=2    [master pointer  (3)]
⎜   ↳ Virtual core XTEST pointer                id=4    [slave  pointer  (2)]
⎜   ↳ TPPS/2 IBM TrackPoint                     id=11   [slave  pointer  (2)]
⎜   ↳ SynPS/2 Synaptics TouchPad                id=10   [slave  pointer  (2)]
⎣ Virtual core keyboard                         id=3    [master keyboard (2)]
    ↳ Virtual core XTEST keyboard               id=5    [slave  keyboard (3)]
    ↳ Power Button                              id=6    [slave  keyboard (3)]
    ↳ Video Bus                                 id=7    [slave  keyboard (3)]
    ↳ Sleep Button                              id=8    [slave  keyboard (3)]
    ↳ AT Translated Set 2 keyboard              id=9    [slave  keyboard (3)]
    ↳ ThinkPad Extra Buttons                    id=12   [slave  keyboard (3)]
```

Disable the device with `xinput --disable device`, where *device* is the device ID or name of the device you want to disable. In this example we will disable the Synaptics Touchpad, with the ID 10:

```bash
$ xinput --disable 10
```

To re-enable the device, just issue the opposite command:

```bash
$ xinput --enable 10
```

Alternatively using the device name, the command to disable the touchpad would be:

```bash
$ xinput --disable "SynPS/2 Synaptics TouchPad"
```

### Persistently disable input source

You can disable a particular input source using a configuration snippet:

```ini
/etc/X11/xorg.conf.d/30-disable-device.conf

Section "InputClass"
       Identifier   "disable-device"
       Driver       "driver_name"
       MatchProduct "device_name"
       Option       "Ignore" "True"
EndSection
```

`device` is an arbitrary name, and `driver_name` is the name of the input driver, e.g. `libinput`. `device_name` is what is actually used to match the proper device. For alternate methods of targeting the correct device, such as [libinput](https://wiki.archlinux.org/title/Libinput) 's `MatchIsTouchscreen`, consult your input driver's documentation. Though this example uses libinput, this is a driver-agnostic method which simply prevents the device from being propagated to the driver.

### Killing application with hotkey

Run script on hotkey:

```bash
#!/bin/sh
windowFocus=$(xdotool getwindowfocus)
pid=$(xprop -id "$windowFocus" | grep PID)
kill -9 "$pid"
```

Dependencies: [xorg-xprop](https://archlinux.org/packages/?name=xorg-xprop), [xdotool](https://archlinux.org/packages/?name=xdotool)

See also [#Killing an application visually](#Killing_an_application_visually).

### Block TTY access

To block tty access when in an X session add the following to [xorg.conf](#Configuration):

```ini
Section "ServerFlags"
    Option "DontVTSwitch" "True"
EndSection
```

This can be used to help restrict command line access on a system accessible to non-trusted users.

To block TTY access only while the screen is locked, rather than for the entire X session, see [vtlock](https://aur.archlinux.org/packages/vtlock/) AUR.

### Prevent a user from killing X

To prevent a user from killing X when it is running add the following to [xorg.conf](#Configuration):

```ini
Section "ServerFlags"
    Option "DontZap"      "True"
EndSection
```

> [!NOTE]
> The `Ctrl+Alt+Backspace` shortcut is not directly what triggers killing the X server, but the `Terminate_Server` action from the keyboard map. This is usually not set by default, see [Xorg/Keyboard configuration#Terminating Xorg with Ctrl+Alt+Backspace](https://wiki.archlinux.org/title/Xorg/Keyboard_configuration#Terminating_Xorg_with_Ctrl+Alt+Backspace) .

### Killing an application visually

When an application is misbehaving or stuck, instead of using `kill` or `killall` from a terminal and having to find the process ID or name, [xorg-xkill](https://archlinux.org/packages/?name=xorg-xkill) allows to click on said application to close its connection to the X server. Many existing applications do indeed abort when their connection to the X server is closed, but some can choose to continue.

### Sockets

Xorg supports listening on a TCP socket and an [abstract socket](https://man.archlinux.org/man/unix.7#abstract) that can undermine some [sandboxes](https://wiki.archlinux.org/title/Security#Sandboxing_applications). To close this loophole, Xorg should be launched with the `-nolisten tcp -nolisten local` command line options. For background and troubleshoot information, see [Tianon's write-up](https://github.com/tianon/abstract-sockets).

### Rootless Xorg

XLibre may run with standard user privileges instead of root (so-called "rootless" XLibre). This is a significant security improvement over running as root. Note that some popular [display managers](https://wiki.archlinux.org/title/Display_manager) do not support rootless XLibre (e.g. [LightDM](https://github.com/canonical/lightdm/issues/18) or [XDM](https://wiki.archlinux.org/title/XDM)).

You can verify which user XLibre is running as with `ps -o user= -C Xorg`.

See also [Xorg.wrap(1)](https://man.archlinux.org/man/Xorg.wrap.1), [Systemd/User#Xorg as a systemd user service](https://wiki.archlinux.org/title/Systemd/User#Xorg_as_a_systemd_user_service), [Fedora:Changes/XorgWithoutRootRights](https://fedoraproject.org/wiki/Changes/XorgWithoutRootRights) and [FS#41257](https://bugs.archlinux.org/task/41257).

#### Using xinitrc

To configure rootless XLibre using [xinitrc](https://wiki.archlinux.org/title/Xinitrc):

* Run startx as a subprocess of the login shell; run startx directly and do not use exec startx .
* Ensure that XLibre uses virtual terminal for which permissions were set, i.e. passed by logind in $XDG_VTNR via [.xserverrc](https://wiki.archlinux.org/title/Xinit#xserverrc) .
* If using certain proprietary display drivers, [kernel mode setting](https://wiki.archlinux.org/title/Kernel_mode_setting) [auto-detection](https://gitlab.freedesktop.org/xorg/xserver/-/blob/master/hw/xfree86/xorg-wrapper.c#L222) will fail. In such cases, you must set `needs_root_rights = n` in `/etc/X11/Xwrapper.config`.

Note that executing `startx` directly without `exec` leaves the shell open in the case of a xorg crash. Since some lock screens are executed inside xorg, this can lead to full access to the executing user.

#### Using GDM

[GDM](https://wiki.archlinux.org/title/GDM) will run XLibre without root privileges by default when [kernel mode setting](https://wiki.archlinux.org/title/Kernel_mode_setting) is used.

#### Session log redirection

When XLibre is run in rootless mode, XLibre logs are saved to `~/.local/share/xorg/Xorg.log`. However, the stdout and stderr output from the XLibre session is not redirected to this log. To re-enable redirection, start XLibre with the `-keeptty` flag and redirect the stdout and stderr output to a file:

```bash
startx -- -keeptty >~/.xorg.log 2>&1
```

Alternatively, copy `/etc/X11/xinit/xserverrc` to `~/.xserverrc`, and append `-keeptty`. See [[5]](https://bbs.archlinux.org/viewtopic.php?pid=1446402#p1446402).

### XLibre as Root

As explained above, there are circumstances in which rootless XLibre is defaulted to. If this is the case for your configuration, and you have a need to run XLibre as root, you can configure [Xorg.wrap(1)](https://man.archlinux.org/man/Xorg.wrap.1) to require root:

**Warning** Running XLibre as root poses security issues. See [#Rootless XLibre](#Rootless_XLibre) for further discussion.

```ini
/etc/X11/Xwrapper.config

needs_root_rights = yes
```

### 12to11

12to11 allows you to seamlessly run Wayland-only applications under X11. It's available from the AUR as [12to11-git](https://aur.archlinux.org/packages/12to11-git/) AUR. Run with the EGL renderer for best performance:

```bash
$ RENDERER=egl 12to11
```

## Troubleshooting

### General

If a problem occurs, view the log stored in either `/var/log/` or, for the rootless X default since v1.16, in `~/.local/share/xorg/`. [GDM](https://wiki.archlinux.org/title/GDM) users should check the [systemd journal](https://wiki.archlinux.org/title/Systemd_journal). [[6]](https://bbs.archlinux.org/viewtopic.php?id=184639)

The logfiles are of the form `Xorg.n.log` with `n` being the display number. For a single user machine with default configuration the applicable log is frequently `Xorg.0.log`, but otherwise it may vary. To make sure to pick the right file it may help to look at the timestamp of the X server session start and from which console it was started. For example:

```bash
$ grep -e Log -e tty Xorg.0.log

[    40.623] (==) Log file: "/home/archuser/.local/share/xorg/Xorg.0.log", Time: Thu Aug 28 12:36:44 2014
[    40.704] (--) controlling tty is VT number 1, auto-enabling KeepTty
```

> [!TIP]
> To monitor the log with human-readable timestamps, [tail(1)](https://man.archlinux.org/man/tail.1)'s output can be piped to [ts(1)](https://man.archlinux.org/man/ts.1) (provided by the [moreutils](https://archlinux.org/packages/?name=moreutils) package). This will give correct timestamps only for lines added to the log while the command is running. For example:

```bash
$ tail -f ~/.local/share/xorg/Xorg.0.log | ts
```

* In the logfile then be on the lookout for any lines beginning with `(EE)`, which represent errors, and also `(WW)`, which are warnings that could indicate other issues.
* If there is an *empty* .xinitrc file in your `$HOME`, either delete or edit it in order for X to start properly. If you do not do this X will show a blank screen with what appears to be no errors in your Xorg.0.log. Simply deleting it will get it running with a default X environment.
* If the screen goes black, you may still attempt to switch to a different virtual console (e.g. `Ctrl+Alt+F6`), and blindly log in as root. You can do this by typing `root` (press `Enter` after typing it) and entering the root password (again, press `Enter` after typing it).

You may also attempt to kill the X server with:

```bash
# pkill -x X
```

If this does not work, reboot blindly with:

```bash
# reboot
```

* Check specific pages in [Category:Input devices](https://wiki.archlinux.org/title/Category:Input_devices) if you have issues with keyboard, mouse, touchpad etc.
* Search for common problems in [AMDGPU](https://wiki.archlinux.org/title/AMDGPU), [Intel](https://wiki.archlinux.org/title/Intel) and [NVIDIA](https://wiki.archlinux.org/title/NVIDIA) articles.

### Black screen, No protocol specified, Resource temporarily unavailable for all or some users

X creates configuration and temporary files in current user's home directory. Make sure there is free disk space available on the partition your home directory resides in. Unfortunately, X server does not provide any more obvious information about lack of disk space in this case.

### DRI with Matrox cards stopped working

If you use a Matrox card and DRI stopped working after upgrading to XLibre, try adding the line:

```ini
Option "OldDmaInit" "On"
```

to the `Device` section that references the video card in `xorg.conf`.

### Frame-buffer mode problems

X fails to start with the following log messages:

```
(WW) Falling back to old probe method for fbdev
(II) Loading sub module "fbdevhw"
(II) LoadModule: "fbdevhw"
(II) Loading /usr/lib/xorg/modules/linux//libfbdevhw.so
(II) Module fbdevhw: vendor="X.Org Foundation"
       compiled for 1.6.1, module version=0.0.2
       ABI class: X.Org Video Driver, version 5.0
(II) FBDEV(1): using default device

Fatal server error:
Cannot run in framebuffer mode. Please specify busIDs for all framebuffer devices
```

To correct, [uninstall](https://wiki.archlinux.org/title/Uninstall) the [xlibre-video-fbdev](https://aur.archlinux.org/packages/xlibre-video-fbdev) package.

### Program requests "font '(null)'"

Error message: `unable to load font `(null)'`.

Some programs only work with bitmap fonts. Two major packages with bitmap fonts are available, [xorg-fonts-75dpi](https://archlinux.org/packages/?name=xorg-fonts-75dpi) and [xorg-fonts-100dpi](https://archlinux.org/packages/?name=xorg-fonts-100dpi). You do not need both; one should be enough. To find out which one would be better in your case, try `xdpyinfo` from [xorg-xdpyinfo](https://archlinux.org/packages/?name=xorg-xdpyinfo), like this:

```bash
$ xdpyinfo | grep resolution
```

and use what is closer to the shown value.

If XLibre is set to boot up automatically and for some reason you need to prevent it from starting up before the login/display manager appears (if the system is wrongly configured and XLibre does not recognize your mouse or keyboard input, for instance), you can accomplish this task with two methods.

* Change default target to rescue.target. See [systemd#Change default target to boot into](https://wiki.archlinux.org/title/Systemd#Change_default_target_to_boot_into) .
* If you have not only a faulty system that makes XLibre unusable, but you have also set the GRUB menu wait time to zero, or cannot otherwise use GRUB to prevent XLibre from booting, you can use the Arch Linux live CD. Follow the [installation guide](https://wiki.archlinux.org/title/Installation_guide#Format_the_partitions) about how to mount and chroot into the installed Arch Linux. Alternatively try to switch into another [tty](https://wiki.archlinux.org/title/Tty) with Ctrl+Alt + function key (usually from F1 to F7 depending on which is not used by X), login as root and follow steps below.

Depending on setup, you will need to do one or more of these steps:

* [Disable](https://wiki.archlinux.org/title/Disable) the [display manager](https://wiki.archlinux.org/title/Display_manager) .
* Disable the [automatic start of X](https://wiki.archlinux.org/title/Start_X_at_login) .
* Rename the ~/.xinitrc or comment out the exec line in it.

### X clients started with "su" fail

If you are getting `Client is not authorized to connect to server`, try adding the line:

```
session        optional        pam_xauth.so
```

to `/etc/pam.d/su` and `/etc/pam.d/su-l`. `pam_xauth` will then properly set environment variables and handle `xauth` keys.

### X failed to start: Keyboard initialization failed

If the filesystem (specifically `/tmp` ) is full, `startx` will fail. The log file will contain:

```
(EE) Error compiling keymap (server-0)
(EE) XKB: Could not compile keymap
(EE) XKB: Failed to load keymap. Loading default keymap instead.
(EE) Error compiling keymap (server-0)
(EE) XKB: Could not compile keymap
XKB: Failed to compile keymap
Keyboard initialization failed. This could be a missing or incorrect setup of xkeyboard-config.
Fatal server error:
Failed to activate core devices.
...
```

Make some free space on the relevant filesystem and X will start.

### A green screen whenever trying to watch a video

Your color depth is set wrong. It may need to be 24 instead of 16, for example.

### SocketCreateListener error

If X terminates with error message `SocketCreateListener() failed`, you may need to delete socket files in `/tmp/.X11-unix`. This may happen if you have previously run Xorg as root (e.g. to generate an `xorg.conf`).

### Invalid MIT-MAGIC-COOKIE-1 key when trying to run a program as root

That error means that only the current user has access to the X server. The solution is to give access to root:

```bash
$ xhost +si:localuser:root
```

That line can also be used to give access to X to a different user than root.

## See also

* ["Are We XLibre Yet?"](https://github.com/X11Libre/xserver/wiki/Are-We-XLibre-Yet%3F) - lists of distributions, operating systems, and X11 software in regard to XLibre support.
* [Xplain](https://magcius.github.io/xplain/article/) - In-depth explanation of the X Window System
* [Xorg(1)](https://man.archlinux.org/man/Xorg.1)
* [Prepare for LPIC-1 exam 2 - topic 106.1: X11](https://developer.ibm.com/tutorials/l-lpic1-106-1/) - briefly covers architecture, [#Configuration](#Configuration), [desktop environments](https://wiki.archlinux.org/title/Desktop_environments) , remote usage, [Wayland](https://wiki.archlinux.org/title/Wayland) .
* [xorg.conf(5)](https://man.archlinux.org/man/xorg.conf.5)
* [Gentoo:Xorg/Guide#Configuration](https://wiki.gentoo.org/wiki/Xorg/Guide#Configuration)

---

This page was forked from [Xorg - ArchWiki](https://wiki.archlinux.org/title/Xorg) and is therefore available under [GNU Free Documentation License 1.3 or later](https://www.gnu.org/copyleft/fdl.html).
