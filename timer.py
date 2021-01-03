# Records the time at which each line is read from STDIN and dumps all
# times to STDOUT at the end as JSON. For example, if the user presses
# return to the beat of a song, its BPM can be computed like this:
#
#     python3 timer.py | jq '(length - 1) / (last - first) * 60'

import sys
import time

start = time.time()
timings = []

def print_time():
    t = time.time() - start
    timings.append(t)
    print("{:.3f}".format(t).rjust(9), end=" > ", file=sys.stderr, flush=True)

print_time()
for line in sys.stdin:
    print_time()

print(file=sys.stderr)
import json
json.dump(timings, sys.stdout, separators=",:")
print()
