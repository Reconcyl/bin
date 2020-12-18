#!/usr/local/bin/python3

# Generate and print a random password of a specified length
# using a secure RNG.

import string
import sys
import secrets

characters = string.ascii_letters + string.digits
try:
    length = int(sys.argv[1])
except (ValueError, IndexError):
    length = 43 # fewest to ensure 256 bits of entropy

print("Generated password: ", end="", file=sys.stderr, flush=True)
print("".join(secrets.choice(characters) for _ in range(length)))
