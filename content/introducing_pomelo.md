+++
title = "Introducing Pomelo"
date = 2026-07-09
+++

# Pomelo - An Alternative 3DS Homemenu!

Hi Everyone, I am happy to share a project i was working on for the last couple of months called "**Pomelo**", which is an **open-source alternative for the stock 3ds homemenu!**

## Why?
When i got my first 3ds console, a couple of months ago, i wanted to customize the homemenu UI of my console, and was quite surprised to see that the only customization mechanism was themes, and there was no alternative for the stock nintendo homemenu.
I started learning about 3ds hacking and very quickly learned of a very supportive and powerful community that has TON of knowledge regarding how the console works.

My goal with this project is to build an open source alternative to the stock nintendo homemenu, that would allow the community to customize and easily redesign.
Currently Pomelo has a very limited set of features and no flexibility regarding the design of the homemenu itself.
I am hoping to implement a themes mechanism, similar to the one nintendo has, but more flexible.

## Features
Currently Pomelo is still in early development, with a lot of missing features and bugs. The features i focused on in the meantime are:
* Game Enumeration - Get a list of all the installed title
* Game Metadata - Show the name and icon of all the installed games
* Game Launching - Launch one of the games that are installed on your console. This feature is pretty buggy, a lot of games crash very quickly or even don't boot at all.

## Design
As you can see in the screenshots below, i am still playing around with the design until i find something i like. 
Currently, my vibe is something retro, right now i'm trying to make it look like a NDS.

## Installation
Pomelo is using Luma3ds to load itself instead of the stock nintendo homemenu, specifically it uses the "Game Patching" optional feature. Currently i only tested it on my console which is a New 3DS US.
Currently the project is still in **very early development**, the source code is available for those who wish to run it on their own consoles.

For more details on installation, see the [github repo](https://github.com/ron-popov/3ds-Pomelo)

## Feedback
I would love to hear your feedback and thoughts on this project, however, this is a side project of mine and i am working on it in my spare time, so please be patient <3

## Screenshots
Pomelo running on real New 3DS hardware:

![Pomelo running on a New 3DS console, showing the game grid](https://ron-popov.github.io/popov.github.io/images/introducing_pomelo/screenshot_09-Jul-2026_14-11-00.png)

Pomelo running in Mikage emulator:

![Pomelo running in the Mikage emulator, showing the game grid](https://ron-popov.github.io/popov.github.io/images/introducing_pomelo/screenshot_12-Jun-2026_13-55-28.png)
