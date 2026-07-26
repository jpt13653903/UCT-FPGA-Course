# Practical &ndash; Waveform Generation

Prerequisite: Day 5 lectures

This practical implements the FMCW waveform required by the sonar.

![Local Block Diagram](WaveformGeneration/SonarFirmware.svg)

--------------------------------------------------------------------------------

## Ramp Generation

Extend the NCO from the digital downconversion of the previous practical to
include a ramp generator.  Use the following parameters:

- 3.6 kHz bandwidth (i.e. 10 kHz start and 13.6 kHz stop frequencies)
- Sweep for about 100 ms (the final processing will only use about 84 ms of
  this, resulting in 3 kHz sonar bandwidth)
- Don't sweep up and down, sweep up and step down.

--------------------------------------------------------------------------------

## Logging

Use the same logging infrastructure from the previous practical.
Log a set number of sweeps (16 would be a good number).

You should not log the invalid samples.  In other words, don't log while the
transient is still travelling to the target and back.  Only log the last
32 samples (about 84 ms) of each sweep.

--------------------------------------------------------------------------------

## Control

Place all the required parameters under register control, with the above as
default.  The log should be software triggered so that the PC can ask for a
burst (of sweeps), and then download the result afterwards.

--------------------------------------------------------------------------------

## Microphone

Once you have everything working, solder in a microphone and make sure it's
working.  Set the digital processing chain to use the microphone as input.

--------------------------------------------------------------------------------

