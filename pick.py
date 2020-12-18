#!/usr/local/bin/python3

# Randomly print one of the arguments passed.

import random, sys

args = sys.argv[1:]

if args:
    print(random.choice(args))
else:
    print("expected arguments", file=sys.stderr)
