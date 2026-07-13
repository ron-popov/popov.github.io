+++
title = "Introducing Pomelo"
date = 2026-07-09
+++

# Pomelo - An Alternative 3DS Homemenu!

Hi Everyone, I am happy to share a project i was working on for the last couple of months called "**Pomelo**", which is an **open-source alternative for the stock 3ds homemenu!**

## Why?
When i got my first 3ds console, a couple of months ago, i wanted to customize the homemenu UI of my console. 
I was quite surprised to see that the only customization mechanism was themes, and there was no alternative for the stock nintendo homemenu.

Being in time of life where i had quite a lot of spare time, writing a homemenu for a console i know nothing about sounded like quite a cool project, that really fell in love with over time.
I started learning about 3ds hacking and very quickly learned of a very supportive community that has TON of knowledge about anything 3ds related. Which made the entire experience a lot more fun :)

My goal with this project is to build an open source alternative to the stock nintendo homemenu, that would allow the community to customize and easily redesign.
Currently Pomelo has a very limited set of features and changing the design requires writing C code :(
I am hoping to implement a themes mechanism in the future, similar to the one nintendo has, but more flexible.

## Features
The homemenu is a very integral part of the 3ds console, doing really, a TON of stuff behind the scenes. I don't think Pomelo would be ever be able to have the full set of features that the stock homemenu has, however i do think that it is very close to having the important features, that will allow most users to use Pomelo as a daily driver.

Currently Pomelo is still in development, the features i was focusing on are:
* Game Enumeration - Get a list of all the installed title
* Game Metadata - Show the name and icon of all the installed games
* Game Launching - Launch one of the games that are installed on your console. This feature is pretty buggy, a lot of games crash very quickly or even don't boot at all.

## Design
As you can see in the screenshots below, i am still playing around with the design until i find something i like. 
Currently, my vibe is something retro, right now i'm trying to make it look like a NDS.

## Plans for the future
First of all i want to focus on improving the Game Launching part, i understand this is one of the most important features of the 3ds homemenu.
I want to get Pomelo to a state where users can actually use this as their daily driver. And then start with all the random QoL improvements.


## Installation
Pomelo is using Luma3ds "Game Patching" to replace the stock nintendo homemenu, note that "Game Patching" is optional feature, that has to be enabled. Currently i only tested it on my console which is a New 3DS US.
Currently the project is still in **very early development**, the source code is available for those who wish to run it on their own consoles.

For more details on installation, see the [Github Repo](https://github.com/ron-popov/3ds-Pomelo)

## Feedback
I would love to hear your feedback and thoughts on this project, however, please note that this is a side project of mine and i am working on it in my spare time, so please be patient <3

## Testing
Pomelo is using Luma3ds Game Patching to load itself, instead of the stock homemenu, incase something goes wrong, simply remove the Pomelo `code.bin` and `exheader.bin` files from the SDCard and the stock homemenu should boot as normal.
However POMELO HAS NOT BEEN THOROUGHLY TESTED, **USE AT YOUR OWN RISK**.

## Screenshots!
Pomelo running on real New 3DS hardware:

![Pomelo running on a New 3DS console, showing the game grid](https://ron-popov.github.io/popov.github.io/images/introducing_pomelo/screenshot_09-Jul-2026_14-11-00.png)

Pomelo running in Mikage emulator:

![Pomelo running in the Mikage emulator, showing the game grid](https://ron-popov.github.io/popov.github.io/images/introducing_pomelo/screenshot_12-Jun-2026_13-55-28.png)

![Pomelo running in the Mikage emulator, NDS style](https://ron-popov.github.io/popov.github.io/images/introducing_pomelo/screenshot_09-Jul-2026_19-20-03.png)

![Pomelo running in the Mikage emulator, NDS style](https://ron-popov.github.io/popov.github.io/images/introducing_pomelo/screenshot_10-Jul-2026_14-23-26.png)

