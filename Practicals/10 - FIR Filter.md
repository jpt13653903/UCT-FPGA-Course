# Practical &ndash; FIR Filter

Prerequisite: Day 5 lectures

This practical implements the finite impulse response filter.

![Full Block Diagram](FIR_Filter/SonarFirmware.svg)

This removes the high frequency component from the mixing process.

--------------------------------------------------------------------------------

## Filter Parameters

- 2048-point FIR filter that decimates by 256
  (i.e. one sample output for every 256&nbsp;samples input)
- Use a cut-off frequency of 300&nbsp;Hz and a
  [Hann window](https://en.wikipedia.org/wiki/Window\_function\#Hann\_window)<br/>
  $w(n) = \sin^2\left(\frac{\pi n}{N-1}\right)$

--------------------------------------------------------------------------------

## Design Workflow

- Design the FIR filter in Matlab / Python / Whatever and test using integer values
- Check for overflows, rounding problems, etc.
- Design what bit-widths to use, given the native RAM and DSP elements of the FPGA in question
- Use Matlab / Python / Whatever to generate the FIR filter constants and MIF file
- Verify through simulation
- Implement and integrate the FIR filter into the design, and test the system as a whole

![Simulation](FIR_Filter/Simulation.svg)

--------------------------------------------------------------------------------

## Sonar

Once the FIR filter is working, you should have a working sonar.
The intended sequence of events are:

1. The PC triggers a burst
2. The FPGA performs a log of $N$ sweeps, then lets the PC know it's done
3. The PC downloads the log
4. The PC then performs further processing (e.g. the range-FFT) and plots the result
5. Repeat from step 1

--------------------------------------------------------------------------------

