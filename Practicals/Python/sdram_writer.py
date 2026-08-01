import sys
import os

from pydub import AudioSegment
from Jtag import *
#-------------------------------------------------------------------------------

if len(sys.argv) < 2:
    print()
    print('Usage: python sdram_writer <input.mp3>')
    print()
    sys.exit(1)
#-------------------------------------------------------------------------------

def convert_mp3(input_file):
    audio = AudioSegment.from_mp3(input_file) \
                        .set_channels(1)      \
                        .set_frame_rate(48828)

    return audio.get_array_of_samples()
#-------------------------------------------------------------------------------

def trim(data):
    start = 0
    while start < len(data) and data[start] == 0:
        start += 1

    end = len(data)
    while end > start and data[end-1] == 0:
        end -= 1

    return data[start:end]
#-------------------------------------------------------------------------------

input_file = sys.argv[1]
samples = trim(convert_mp3(input_file))
samples = [ int(s) for s in samples ]

abs_samples = [ abs(s) for s in samples ]
print(f'Samples        = {len(abs_samples)}')
print(f'Mean amplitude = {sum(abs_samples) / len(abs_samples)}')
print(f'Max  amplitude = {max(abs_samples)}')
#-------------------------------------------------------------------------------

if len(samples) < 2**25:
    samples.extend([0] * (2**25 - len(samples)))

if len(samples) > 2**25:
    samples = samples[0:2**25]

for n in range(len(samples)):
    if samples[n] < 0:
        samples[n] += 0x10000

samples = [ samples[n+1] << 16 | samples[n] for n in range(0, len(samples), 2) ]
#-------------------------------------------------------------------------------

jtag = Jtag()
jtag.open()
jtag.write(samples)

print('Done')
#-------------------------------------------------------------------------------

