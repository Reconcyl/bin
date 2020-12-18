#!/usr/bin/env python3

# Generate a table of printable ASCII characters.

for i in range(6):
    print(*(chr((i + 2) * 16 + j) for j in range(16)))
