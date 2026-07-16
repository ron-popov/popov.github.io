+++
title = "Homemenu Memory Shenanigans - Part 2"
date = 2026-07-16
draft = false
+++

# Where we left off
[If you missed the first part](https://ronpopov.me/homemenu-memory-shenanigans-part1/)

tl;dr
1. Some games are crashing as soon as they are launched, because they don't have enough RAM
2. I need to allocate my heaps in a different region of memory, dedicated for system apps, instead of the APPLICATION memory region
3. Pomelo fails to allocate a linear heap in the new memory region and crashes on boot :(

# What is the linear heap?
Linear is a heap that is used for GFX operations, such as storing textures and 3d models. The only thing that is special about it is that it's a single consecutive section in memory, unlike a regular heap allocation. In regular heaps the memory might be spread out across multiple sections in the physical memory.

# 3ds Error Codes
Using the same technique that i used to pinpoint the exact svcBreak call that crashes the system, i can use it to also leak the returnCode from the `svcControlMemory` (syscall that is used to allocate memory on the 3ds console). Now the code looks like this
```c
// Allocate the linear heap
rc = svcControlMemory(
	&__ctru_linear_heap, 
	0x0, 0x0, 
	__ctru_linear_heap_size, 
	MEMOP_ALLOC_LINEAR, 
	MEMPERM_READ | MEMPERM_WRITE
);

if (R_FAILED(rc)) {
	asm volatile("mov r11, %0" : : "r"(rc));
	asm volatile("mov r12, %0" : : "r"(0xEEEE0003));
	svcBreak(USERBREAK_PANIC);
}
```
![Crash Dump](https://ronpopov.me/images/homemenu_memory_shenanigans/screenshot_16-Jul-2026_15-17-46.png)

You can see in R11 that the error code `svcControlMemory` returns is `0xD86007F3`!
Something you should know about 3ds status code is that they are actually built from 4 different values that can be used to debug the crash:
* Description
* Module
* Summary
* Level

After decoding the error code using [3dbrew docs](https://www.3dbrew.org/wiki/Error_codes), i got the following values and their meaning
```
Description : 0x3f3 (1011) - Out of memory
Module : 0x1 (1) - Kernel
Summary : 0x3 (3) - Out of resource
Level : 0x1b (27) - Permanent
```

**Out of memory? That's weird...**
I am requesting the same amount of memory that the real homemenu is requesting. I got that number by running the real homemenu in mikage and searching for the `svcControlMemory` the real homemenu is calling. Operation `0x3` is MEMOP_ALLOC, and operation `0x10003` is MEMOP_ALLOC_LINEAR.

```
# Regular heap allocation - Around 3MB
SVCControlMemory: addr0=0x08000000, addr1=0x00000000, size=0x304000, op=0x3, perm=0x3

# Linear heap allocation - Around 11MB
SVCControlMemory: addr0=0x00000000, addr1=0x00000000, size=0xb64000, op=0x10003, perm=0x3
```

Claude suggested the reason the linear heap allocation fails is because a linear heap requires a continuous section of memory, let's see how much memory i have available and if that makes sense
Well, i have quite a lot of memory...
Overall the system has around 255mb of ram, with 248mb available, however we are more interested specifically in the SYSTEM memory region, as only there we can allocate memory.
This region has around 100mb of ram, with 95mb of ram available for allocation, so how could that be???

# How much memory does the real homemenu allocate?
When running the real homemenu in mikage it told me that the real homemenu is requesting around 11mb of linear heap memory, however when i request 11mb of linear heap memory using pomelo on real hardware, it crashes.
I assume there's some diff between the way the homemenu does that on a real console and in mikage, and it's not farfetched that the console allocated more / less memory, based on the 3ds model (some models have more RAM than others).
I tried to reverse engineer the real homemenu and attempt to find how much linear heap it requests and i couldn't find anything, so i really wanted to get this value somehow from the real hardware.

Now, getting those numbers is a bit hard, we want to capture the homemenu performing a syscall (which is handled by the kernel). Even tho there are debuggers for physical consoles, i'm not really sure how i could go for debugging the homemenu or the kernel itself.

I didn't really want to invest in using, or maybe even building something like this for a super specific use case (getting the amount of ram that the real homemenu is requesting). So i decided to do something super hacky, that worked!

I dumped the `code.bin` file from the stock homemenu to disassemble it and get its logic, as i said i found the linear heap `svcControlMemory` call, but i couldn't find what is the value that is being passed to it, it seems like it is never initialized.
So i decided to do the following, **i patched the function call to `svcControlMemory` with `int 0x3C`, or in human language - `svcBreak`**.
That means that instead of calling `svcControlMemory`, the console will crash, and show me the registers and stack state when the call to `svcControlMemory` was supposed to take place, from which i could extract the different variables that are passed to it, including how much memory is requested.

```
...
00146dac 00 20 a0 e3     mov        r2,#0x0
00146db0 08 00 8d e2     add        currentSize,sp,#0x8
00146db4 24 fb ff eb     bl         ctr::svcControlMemory <-- replace this opcode with "int 0x3C"
00146db8 02 11 10 e2     ands       svcResult,currentSize,#0x80000000
00146dbc 00 f0 20 e3     nop
...
```

So i patched the homemenu code.bin file, and used Luma3ds game patching to tell my console to use the patched code.bin file instead of the original homemenu, booted it up, aaaannnnnnddddddd
**I got this beautiful crash screen :)**

![Crash Dump](https://ronpopov.me/images/homemenu_memory_shenanigans/screenshot_16-Jul-2026_16-28-13.png)

From here i could extract the total size that is requested for the linear heap from R4 - 0x00D00000, which is 13MB???
How does that make sense??? That's more than what we request in mikage, and i can't even get 4MB allocated, oof :(

I then also patched the instruction after the call to `svcControlMemory` to make sure the call succeeded, and it did.

# Temp Summary
So what did we have here?
* The real homemenu is allocating 11MB when running in mikage
* It allocates 13MB when running on real hardware
* I can't allocate 4MB in the same memory region :(

More in the next one!