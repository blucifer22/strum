# STRUM - Systematic Tonal Reference Unrhythmic Modulator
## By: (Marc Chmielewski)·(James Arnold)

![STUM Demo GIF](https://media.giphy.com/media/iYIrWwT71Fpmjf1OOe/giphy.gif)

## Overview

Short Version: A 100% HDL-implemented (zero lines of assembly!!!) guitar-hero-esque rhythm game where notes scroll down the screen and players must hit the correct key at the right time. 

Long Version: STRUM is a Verilog Guitar Hero game but with none of your favorite songs!

Including hits like:

* 

*

*

*

And even:


*

Yeah it’s just random notes that are pretty terrible sounding, but it works!
Tracks streaks, notifies player of mistakes, and runs without a single line of code
If you’re ever bored and want to cause a little hearing loss, try STRUM!

Demo video (with slightly less-aggressive audio) linked [here](https://youtu.be/EzCkyvfQ79g)!

## Setup
Currently, STRUM is compatible with the NEXYS A7 FPGA from XILINX. Vivado configuration files for this target are included in this repository.

***IMPORTANT:*** Make sure to update the path in VGAController.v to point to the location of the `.mem` files in your filesystem. Follow the overall formatting of the included path and you should be on the right track.

Generate a bitstream, upload to your target, plug in a USB keyboard and VGA monitor and you're off to the races!!

## Gameplay
Click `A` for red notes, `S` for yellow notes, `D` for green notes, and `F` for blue notes.

If you time it right, that is, you hit the key near the brown bar at the bottom of the screen, the seven-segement will increment displaying your streak.
If you miss you'll hear an ear-piercing screech at 2000 Hz and your streak will be reset to zero.

Continue until you get bored and decide to partake in a more interesting form of entertainment...

## Current Feature Set:
Key features include:
* Ability to track notes played/missed
* High score
* Ability to generate random levels (with dissonant scripted audio! :))

## Long-Term Roadmap:
* Multiplayer support (sharing a keyboard? Guitarist and vocalist?)
* Using the mic to support “vocals” (Doesn’t have to be particularly fancy, just detect when you’re making noise)
* Multiple game modes? (timed, infinite, fibonacci?)

## Computational Elements
The Duke 350 ISA was extended to include:
* A random number generator
  * Implemented with a linear-feedback shift register (LFSR)
* Close Enough (`ce $rd`) an instruction that determines if two values are within a certain threshold (so that the player can strike a key when the note is within x number of pixels of correct location)

## I/O Devices
* Keyboard input over PS/2
* Video display via VGA (shows the player which notes are coming and when to click)
* Audio output over a standard 1/8 inch jack
* Score output on seven-segment display

## Contribution Guidelines
* Not many, just send PRs :)
  * Anything pertinent to the roadmap or compatibility with other targets would be appreciated.
