+++
title = "WIP: Homemenu Memory Shenanigans - Part 2"
date = 2026-07-15
draft = true
+++

# Where we left off
[If you missed the first part](https://ronpopov.me/homemenu-memory-shenanigans-part1/)

tl;dr
1. Some games are crashing as soon as they are launched, because they don't have enough RAM
2. I need to allocate my heaps in a differnt region of memory, dedicated for system apps, instead of the APPS memory region
3. Pomelo fails to alloate a linear heap in the new memory region and crashes on boot.

# What is the linear heap?
Linear is a heap that is used for GFX operations, such as storing textures and 3d models. The only thing that is special about is it that it's a single consecutive section in memory, unlike a regular heap allocation. In regular heaps the memory might be spread out across multiple sections in the physical memory.

# 3ds Error Codes
As i said, 

# How much memory i have?