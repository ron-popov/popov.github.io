+++
title = "Homemenu Memory Shenanigans - Part 3 - Finalle!"
date = 2026-07-20
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
