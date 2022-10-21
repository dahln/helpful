# Raspberry Pi - Slow Mouse Speed Fix

I am a huge fan of Raspberry Pi's.  I have a standing request when anybody asks me what I want for a gift.... birthday, Christmas, etc: "Sure...let me think, oh! I need another Raspberry Pi".  I think my wife actually likes it because she knows I always get excited about another one, and they are easy to find, and affordable.

Normally when I setup a Raspberry Pi, I go for the "non-gui" approach. I prefer setting it up and then logging in over SSH. In some cases, I have opted for the full GUI. Raspberry Pi OS has a low mouse speed by default - something about how a Pi has limited hardware capabilities and a mouse might cause a strain. My latest Pi is a beast, the Pi 4 with 8gb of RAM. I wanted a real, usable mouse.

Here is how I fixed the slow mouse speed

 - Open this file:
```
sudo nano /boot/cmdline.txt
```

 - At the end of the single line, add a space and then "usbhid.mousepoll=0"
 - This will set the mouse speed to the speed the device/mouse is requesting
 - Save the file. My reference is Ctrl+O (to write out) and then Ctrl+X (to exit)
 - Reboot:
 
```
sudo reboot
```

Done. The mouse should be a usable speed.



PS:

If you don't want to use the speed requested by the device, here are a series of other option speeds:

```
usbhid.mousepoll=1 -> 1000Hz
usbhid.mousepoll=2 -> 500Hz
usbhid.mousepoll=4 -> 250Hz
usbhid.mousepoll=8 -> 125Hz
usbhid.mousepoll=10 -> 100Hz (Default)
```
