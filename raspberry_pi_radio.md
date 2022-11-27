# Raspberry Pi FM Transmitter

I wanted to transmit Christmas/Grinch music with the Christmas decorations in my yard. I had a spare Raspberry Pi and thought I could use it as a transmitter.

## 2022 Christmas Update:
I've unable to get this process to work with my Pi 4. When I go back to the Pi 3 that I used previous years, it worked fine.

## Setup Process:

This repo provided my starting point: https://github.com/ChristopheJacquet/PiFmRds. I forked the repo, it can be found at: https://github.com/dahln/PiFmRds

An antenna wire should be connected to pin 7

I followed the instructions in the repo Readme and I made a few minor adjustments:
 - I setup a raspberry pi with a fresh copy of Rasperry Pi OS. Lite version is my preferred)
 - Run the following commands, all from the "pi" user home directory:

```
sudo apt update
```
```
sudo apt upgrade -y
```
```
sudo apt install git -y
```
```
sudo apt install libsndfile1-dev -y
```
```
sudo apt install sox oggfwd -y
```
```
sudo apt install libsox-fmt-mp3 -y
```
```
git clone https://github.com/dahln/PiFmRds.git
```
```
cd PiFmRds/src
```
```
make clean
```
```
make
```

Now that all that is installed, setup, and built - lets start it up:

Running sudo ./pi_fm-rds works great, but doesn't do much. The program accepts several parameters that lets you customize the transmission. Pass in a file, set the frequency, etc.

I had several "Grinch" songs in MP3 format. pi_fm_rds accepts a .wav file. But I didn't want to have to convert my files to .wav's. The "sox" program we installed will convert an mp3 to a wav file. Using SCP, I copied the MP3 files from my laptop to the Pi. I copied them to "/home/pi/Music"

After some trial and error, this is the command I settled on:

 sox -t mp3 /home/pi/Music/*.mp3 -t wav - | sudo ./PiFmRds/src/pi_fm_rds -freq 107.3 -ps GRINCH -rt 'GRINCH' -pi GRCH -audio -

What does this do? Well lets walk through it:
 - sox converts all the mp3 files in the music folder from mp3 to wav
 - Instead of saving the converted file, the output is piped into pi_fm_rds
 - pi_fm_rds accepts the piped input
 - pi_fm_rds sets frequency of 107.3
 - ps, rt, and pi are all identifies for radios that can display text

One last thing. I found that when the songs ended (I had 4 songs in the music folder), pi_fm_rds would shut down. I wanted the program to loop... over and over and over for the whole month of December. So I wrapped the whole command in the a while loop.... lol.

Here you go:
```
while true; do sox -t mp3 /home/pi/Music/*.mp3 -t wav - | sudo ./PiFmRds/src/pi_fm_rds -freq 107.3 -ps GRINCH -rt 'GRINCH' -pi GRCH -audio -; done &
```


After running the command:
 - press enter a few times
 - Do not just "close" the console/terminal. Type "exit" and you can close the terminal
