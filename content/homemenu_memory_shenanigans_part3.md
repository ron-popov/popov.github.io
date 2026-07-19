+++
title = "Homemenu Memory Shenanigans - Part 3 - Finalle!"
date = 2026-07-19
draft = false
+++

# Where we left off
[If you missed the first part](https://ronpopov.me/homemenu-memory-shenanigans-part1/)
[If you missed the second part](https://ronpopov.me/homemenu-memory-shenanigans-part2/)

tl;dr
1. I wanted to know how much memory the real homemenu is requesting **on real hardware**
2. I patched the relevant svcControlMemory call to crash instead, which would dump the stack and register values - that contain the args passed to svcControlMemory, including size and etc...
3. The real homemenu is requesting ~13MB of linear heap, i can't even allocate 4MB

# External Guidance
I asked about my issue in a couple of forums, and @neobrain (one of the authors of mikage), suggested something interesting.

At this point in time i wasn't sure if my issue was the **program state**, or the **program settings**, i will explain.

When i say program state, i mean that i might have to setup the 3ds state in a different way to be able to allocate the linear heap. Maybe call some other IPC call, change the order of the IPC calls that i am performing, or something of that sort.

Or it could be an issue with the **program settings**, aka, the headers of the homemenu that i am building. So @neobrain suggested i do an experiment to check if the issue is with the program itself, or maybe the headers.

To explain that, we need to talk a bit about exheaders!


### ExHeaders
Most 3ds titles are packaged into CXI files, also known as NCCH files.
Those files contains multiple important pieces, but we will focus on 2 of them.

The first of which is the `code.bin` file, this is the executable itself. It's a file that contains the compiled instructions without any wrapper format (ELF or PE) at all, simply compiled instructions.

The second interesting piece are the ExHeaders, these headers are signed by nintendo, and contain everything the 3ds system needs to know about the title to execute it. It contains a wide range of details such as:
* Section Sizes - the size of the TEXT section, BSS section and etc...
* IPC & Syscall Access - to which services can i perform IPC calls? which syscalls can i call?
* FCRAM Memory Region - in which region we would allocate your requested memory? This is the field i changed in the first part
* A lot more random stuff - TitleId, Title Dependencies, FS Access...

# The Experiment
Let's build a code.bin file that 1 thing exactly, allocate a linear heap using svcControlMemory. Then run that code using the real homemenu exheaders, and using pomelo exheaders. That should tell us if the issue is in the code or in the exheaders.

{% alert(type="note", icon="note", title="Side Note") %}
I am using Luma3ds "game patching" for replacing the real homemenu `code.bin` and `exheader.bin` files with pomelo ones.
Luma3ds does something *interesting* when replacing the original `code.bin` and `exheader.bin` files with the custom ones, and it is patching them in some cases. For examples when loading the homemenu `code.bin` file (doesn't matter if the original or a patched one), it patches out some of the security checks that the homemenu performs, such as region checks, or DS flashcart whitelists.
You can see the patching that luma3ds performs in [patcher.c](https://github.com/LumaTeam/Luma3DS/blob/master/sysmodules/loader/source/patcher.c), specifically in the function `patchCode`.

Since the code.bin i am building doesn't have the original region check logic, or the DS flashcart whitelist, the loader fails to patch the `code.bin` file and crashes the system as a result. This is something i also encountered when building pomelo, and i fixed it in pomelo by injecting fake code that looks like the logic that luma3ds is trying to patch but is never actually executed, just so luma3ds would think that it was able to patch the homemenu.

Since i wanted to keep this payload as simple as possible, in this case i rebuild luma3ds without the security checks, just for running the test payload.
{% end %}

## Code snippet
I ran the following code that does 3 things:
* Call `svcControlMemory` and tells it to allocate a 4MB linear heap
* Copy the return code to R12
* Crash the system using `svcBreak`, so we could read the return code

```asm
.arm
.global _start

.equ MEMOP_ALLOC_LINEAR, 0x10003   @ MEMOP_LINEAR (0x10000) | MEMOP_ALLOC (3)
.equ MEMPERM_RW,         0x3       @ MEMPERM_READ (1) | MEMPERM_WRITE (2)
.equ ALLOC_SIZE,         0x400000  @ 4 MB

_start:
    ldr r0, =MEMOP_ALLOC_LINEAR @ op
    mov r1, #0                  @ addr0
    mov r2, #0                  @ addr1
    ldr r3, =ALLOC_SIZE         @ size
    ldr r4, =MEMPERM_RW         @ perm
    svc 0x01                    @ svcControlMemory
    mov r12, r0                 @ stash result code where the crash screen shows it

    mov r0, #0                  @ breakReason = BREAKREASON_PANIC
    svc 0x3C                    @ svcBreak
```

## Results
I ran the code using the original homemenu exheaders, and using pomelo exheaders, and here is what i got

### Original Homemenu ExHeaders
![Original Homemenu ExHeaders](https://ronpopov.me/images/homemenu_memory_shenanigans/screenshot_19-Jul-2026_17-01-58.png)

### Pomelo ExHeaders
![Pomelo ExHeaders](https://ronpopov.me/images/homemenu_memory_shenanigans/screenshot_19-Jul-2026_17-01-52.png)

## AHA!
We got our answer! **The issue is in the ExHeaders!**

You can see in the crash dump of the original homemenu exheaders that the `svcControlMemory` call succeeded, indicated by the value 0 in R12. And you can see that when i used pomelo ExHeaders, the value in R12 was `0xD86007F3`, which means the `svcControlMemory` FAILED when using pomelo ExHeaders files.

# What Now?
This really narrows down the root cause of our issue. Now i know i just need to make the ExHeaders of pomelo closer to the real ones and finally the heap allocation should work.

I am using [makerom](https://github.com/3DSGuy/Project_CTR/tree/e8f5f529c54ff9b22a2491a480ffa69206bf7b19/makerom) to build the exheaders of pomelo, a `template.rsf` file is used to tell makerom which values to put in the pomelo exheaders.

A couple of claude prompts later, **I finally found the culprit!**
The culprit was the `KernelVersion` value, which indicates for which kernel version that title was built and tested against.

I Honestly have no idea why that caused, specifically the allocation of linear heaps to fail...
I put it wayyyyy too many hours into debugging this, that at this point i'm kinda just happy it works and i can move on to other bugs i need to fix in pomelo :)