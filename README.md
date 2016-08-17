# My Pascal Oldies
Back in the late 90s it seems like I had a lot of time (and even more patience) at hand, so I was writing programs in the (then popular) Pascal language.
Although looking at the code now is really painful (even for me, the author!), I think you can appreciate the amount of (raw) work I put in some of it.

So, without further ado, I present you some good old Pascal programs from my teenage years.

## Uhm... OK, but how do I run these ~~pieces of #!@%~~ really-really-really nice programs?

###Get the project files
Clone the project repository to a folder on your disk (in my case, C:\my_pascal_oldies):

```
C:\> git clone https://github.com/mmarica/my_pascal_oldies.git
```

###Get DosBox and configure it
You need to install DosBox, but don't worry, it is free!

####For Windows
You can download it from the official site: https://www.dosbox.com. The latest version at this moment is 0.74 (august 2016). Installation is "next-next-next" :)

Make a shortcut to DropBox which will load the custom config already included in the project. For me, the command executed by the shortcut looks like this:

```
"C:\Program Files (x86)\DOSBox-0.74\DOSBox.exe" -conf "C:\my_pascal_oldies\dosbox-0.74-windows.conf"
```

If you are using the same paths as I am, you are good to go.

##### In case you are not good to go

GOOD LUCK making it work!

Just kidding :))

If you just want to use another path for the project, just edit dosbox-0.74-windows.conf from the project folder and change the mount line (replace PATH_TO_PROJECT with the actual path where you cloned the project, DOH!):

```
[autoexec]
# Lines in this section will be run at startup.
# You can put your MOUNT lines here.
mount C: PATH_TO_PROJECT
```

####For Linux
The installation methods differ among distributions. For Ubuntu, for example, it's as easy as running this command:

```
sudo apt-get install dosbox
```

You need to make your own DosBox config starting from the default one created by your DosBox installation and just do to it what I did.

I added commands to run at DropBox startup (replace PATH_TO_PROJECT with the actual path where you cloned the project, DOH!):

```
[autoexec]
# Lines in this section will be run at startup.
# You can put your MOUNT lines here.
mount C: PATH_TO_PROJECT
C:
dir
```

I updated the number of cycles. DosBox comes with a default emulating probably a 286, so the programs would run veeeeeeery slow if I didn't do that. 

```
[cpu]
cycles=fixed 18000
```

The number of cycles I have chosen emulate approximately the speed of the computer that I had in that period.
I owned a Siemens Nixdorf 486SX with a whooping CPU speed of 25Mhz, just like this one: https://www.youtube.com/watch?v=p_4J6XC4Wss. Oh, such times :)

To run DosBox, it should be as simple as running a command like this:

```
dosbox -conf PATH_TO_MY/CUSTOM_COFIG_FILE.conf
```

## In case you forgot how to DOS :)

The following commands are to be used in the command line after DosBox starts, obviously!

To enter a folder:

```
CD FOLDER
```

To exit a folder:

```
CD ..
```

To run a program:

```
PROGRAM.EXE
```

So, in order to run WORMS (my favorite, btw), after opening DosBox, just run these commands:

```
cd WORMS
WORMS.EXE
```

I know, I know, it should have been named SNAKE :)
 
## Source code
Some of the programs do not have the source code anymore. Unfortunately I lost it.
 
For those of them that do have the source code (you will find the .PAS files inside their folder), good news: it is complete and compilable.

If you don't believe me, try it yourself (hint: you need to install Turbo Pascal 7 and mount its folder in DosBox). I used Turbo Pascal 7 for Windows7-8-8.1 (don't be fooled by the "windows" in the name, it really is for DOS).
