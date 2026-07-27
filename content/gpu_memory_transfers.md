+++
title = "GPU Memory Access Bugs"
date = 2026-07-27
draft = false
+++

{% alert(type="note", title="Disclaimer") %}
This blog contains a lot of content, and i don't feel like splitting it into multiple parts, it might be a bit long, there will be a TL;DR at the end
{% end %}

# What's now?
If you have been following my previous blogs, you will know i am building pomelo, an open source alternative to the stock homemenu.
And since the homemenu, is a **pretty** critical part of the 3ds console, it's kinda harsh.

In the previous 3 blogs, i was talking about a low level issue. When a 3ds process starts, it requests from the kernel a memory region it can use as heap, and one it can use as linear heap (heap for storing textures). For regular apps, libctru (open source 3ds SDK) just takes care of it, but when you are building a homemenu, it's not that simple...

After i fixed the linear heap allocation, i started having other issues, in mikage everything was working just fine.
However on real hardware, the rendering failed and after some basic debugging, it's seems like the rendering process simply hangs :(


# 3ds GPU Rendering Process
Before we talk about what is the issue that i experienced with pomelo, we need to learn a bit about the 3ds rendering process.

The 3ds has the PICA200 GPU that we will be talking about today. And the GSP module that acts as a driver for communicating with the GPU.
We also have `citro3d`, which is a usermode sdk, meaning the it's part of the app that wants to render stuff, that we will be using.

Assuming we have already initialized everything required for rendering, let's look at what happens every frame we render :)

## Frame Init
We start by zeroing out the `gpuCmdBuffer`, as we don't want any garbage or leftovers in that buffer.

One of the most important parts of the rendering process is the `gpuCmdBuffer`, it contains all the render instructions for the GPU, including textures to render, text, vectors (lines, rectangles) and etc...
The `gpuCmdBuffer` is initialized by citro3d, and allocated in the linear heap of pomele, you should already know what is a linear heap from the previous blog :)

## Adding Textures and Vectors
Now is the time for us to get creative :)

Pomelo now can draw the background, draw the game icons, add the game name and publisher to the frame, basically all the interesting stuff.
All these actions are transformed into commands that are added to the command buffer. They are not actually rendered, only stored in a temporary buffer, waiting to be flushed to the GPU.

## Frame End
Now is the Interesting part...

After pomelo added all the textures and everything it wants to render, we have a gpuCmdBuffer that is filled with instruction for the GPU to process and make the magic happen.

Now there are 3 different calls to the GSP module to do in order to render the frame:

### MemoryFill
This tells the GPU to clean the VRAM memory. It is used to clear the previous frame before starting to render new stuff on top of it.

### ProcessCommandList
This command tells the GSP module to render the beautiful gpuCmdBuffer that we have built.

We give the GSP module the Virtual Address of the gpuCmdBuffer and it's size. The GSP module translates this virtual address into a physical address, the GPU can actually use and access. Unlike other common operating systems, on the 3ds translating the virtual address to a physical address is fairly easy, in most cases it's simply a hardcoded offset between the two addresses.

Then the GSP module is giving the GPU the physical address of the gpuCmdBuffer and it's size, and the GPU does it's magic.

SPOILER ALERT : This is the call that caused the hang, i will soon explain how i discoverd this.

### DisplayTransfer
This calls tells the GSP module to tell the GPU to start rendering all the processing it just did.

## Waiting for a return signal
We will know that the GPU finished what the GSP module asked for, by receiving signals from the GPU that indicate it's status.
Each such call has a signal of it's own that indicates the action finished:
* PSC0 - Indicates the MemoryFill finished
* P3D - Indicates the ProcessCommandList finished
* PPF - Indicates the DisplayTransfer finished

Once we have received all 3 signals we can be sure that the GPU did it's job and the image should now show up on the console :)

## Diagram!

![GPU Write Diagram](https://ronpopov.me/images/gpu_processing_diag.png)

# TL;DR
