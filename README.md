# STRUM - Systematic Tonal Reference Unrhythmic Modulator
## By: (Marc Chmielewski)·(James Arnold)

## Overview
A guitar-hero-esque rhythm game where notes scroll down the screen and players must hit the correct key at the right time.  

## MVP and Extensions
Key features include:
* Ability to track notes played/missed
* High score
* Ability to generate random levels (with dissonant scripted audio! :) )

## Extensions include:
* Multiplayer support (sharing a keyboard? Guitarist and vocalist?)
* Using the mic to support “vocals” (Doesn’t have to be particularly fancy, just detect when you’re making noise)
* Multiple game modes? (timed, infinite, fibonacci?)

## Computational Elements
The Duke 350 ISA will need to be extended to include:
* A random number generator
  * Thinking about a ring-oscillator to do this; also considering this option.
* Branch prediction of some variety
  * Helps dramatically with the efficiency of looping code
* An instruction that determines if two values are within a certain threshold (so that the player can strike a key when the note is within x number of pixels of correct location)

## I/O Devices
* Keyboard input
  * Maybe utilize mic to see if the player makes a noise at the right time (extension)
* Displaying via VGA (showing the player which notes are coming, scores, etc)
* Outputting audio to earbuds
* Built-in LEDs (one color for each note, full light show if you finish a song, red lights for missing notes)
