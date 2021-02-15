#!/usr/bin/env python3

# Delegates to a C compiler and prints the arguments that were passed.
# This is useful to pass as a custom cc for compilers in high-level
# languages that target C.

from colorama import Fore
import shlex, sys, subprocess

args = sys.argv[:]
args[0] = "cc"

print("\x1b[33mcalling\x1b[39m:", shlex.join(args), file=sys.stderr)
subprocess.run(args)
