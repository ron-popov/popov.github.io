+++
title = "Homemenu Memory Shenanigans"
date = 2026-12-30
+++

# 3DS System Memory Shenanigans
## Why?
While building Pomelo (which you can read more about in my previous blog), i noticed that some games would crash very quickly after booting - usually the more serious ones such as the mario and legend of zelda series. I assumed that i didn't initialize / handle something correctly, that caused some games to crash.

One such game was "Super Mario 3D World", so i decided to take this one as an example, and assumed that getting it to boot, should fix the same issues that a lot of games had.

## How?
I dumped the game from my console, and put it into ghidra to try and understand why the game was crashing. I would also mention that i got a pretty detailed stack dump from my 3ds console, including the state of all the registers, and the stack.

I loaded the game binary into ghidra, and used the modern marvel of Artificial Intelligence to my help. I connected claude code to the ghidra MCP server, gave it the crash dump, and very quickly it gave me the answer i was looking for.
The reason "Super Mario 3D World" was crashing, when the game boots, it checks how much RAM is has available for use, and if it doesn't have enough, it crashes :(

But in that case, how does the game boot at all? After all pomelo uses much less memory than the stock homemenu, so what is the issue?
And that's when i learned about 3ds FCRAM memory regions.

## FCRAM Memory Regions
As you can see in this super useful [diagram](https://raw.githubusercontent.com/wwylele/misc-3ds-diagram/master/memory.svg), the 3ds FCRAM is where the heaps of all the different processes in the 3ds are allocated. 
The FCRAM is split into 3 sections:
* APPLICATION - For Games and Applications running on the 3ds system, such as "Mario Kart 7", "Super Mario 3D World" and etc...
* BASE - Used by some of the sysmodules, and also the kernel itself.
* SYSTEM - Used by the NS module, some system applets (system apps such as camera or settings menu), and most importantly **the homemenu is using this section**

## AHA!
The memory region that the title is using, is defined by the title itself. Titles will usually use the APPLICATION system region, and since titles are signed by Nintendo, this is not something that the author of the app can change.
However on modded consoles, we can practically do whatever we want.

In the case of pomelo, it is using the APPLICATION memory region, as you can see defined in the `template.rsf` file that is used the build the CXI section
```yaml
MemoryType: Application
```

AHA! Now everything makes sense! Becuase Pomelo is using the `APPLICATION` system region, it's using some of the memory that is reserved for actual 3ds games, and when "Super Mario 3D World" is booting, it doesn't have the amount of memory that it expected.
So the fix should be as simple as changing that to `SYSTEM`, right? Sadly, it's not that simple..

## Linear Heap Allocations
Re-building Pomelo and running it on my modded console, i immediatly got a crash :(

The crash was in the function `__system_allocateHeaps`, which is a funtcion that runs at a very early stage of the title boot, even before the `main` function is executed.
Now, it kinda makes sense that by playing with the memory region in which the heap is allocated, we broke something related to heap allocations. Let's dig into this function and understand which specific section is crashing!

![Our First Crash Dump](https://ron-popov.github.io/popov.github.io/images/homemenu_memory_shenanigans/screenshot_12-Jul-2026_23-56-14.png)