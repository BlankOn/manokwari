# Hacking Manokwari
## Use local system
Instead of installing the "system" directory in the system, it is a good idea to hack your own "system", ie. just do the hacking inside
system/ directory instead of /usr/share/manokwari/system, so no sudo required.

Do this by giving --enable-devel

This way, Manokwari will find system directory from your current directory source tree.

## Speed up hack-compile-run time
Because the nature of Manokwari as desktop shell, it's cumbersome to logout and login again to run Manokwari.
There's a few tricks to make sure you won't waste your time waiting Manokwari to run.

### Use virtual machine
After a complete installation of the desktop, you can do this:
- mount (eg. using sshfs) your current source directory in your virtual machine. Make sure you have the EXACT full path to the system directory.
  Meaning that if your source code in your development machine is in /home/you/src/manokwari, then in your virtual machine, you must
  /home/you/src/manokwari as well. Otherwise the system/ will not be found.
- Then you can just run manokwari from src/ directly inside your virtual machine
- If you're able to access your virtual machine using ssh, you can have 2 tab setups in your console, one inside your own computer,
  and the other is on your virtual machine. You compile in one tab, and switch to another to run. Win.

### Run in nested X server
If you want to touch only the HTML side, you can just use a nested X server, eg. Xephyr.
This may give some warnings as Manokwari will fail to register itself as desktop or panel component in GNOME session.
This is because your desktop in your main X server already register for those capabilities.

You can do the following:
- export DISPLAY to whatever your nested X server display number is
- Run manokwari as usual

### Run without GNOME session
With this you will lose GNOME session capabilities, eg. you can't logout, shutdown, testing different screen sizes, etc.
But you can quickly run Manokwari in this way.

- Stop all desktop managers (gdm, lightdm, etc)
- Run X manually
- Run Manokwari inside the X you just started


