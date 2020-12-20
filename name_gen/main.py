#!/usr/local/bin/python3

import random

with open("first_names.txt") as f:
    first_names = f.readlines()

with open("last_names.txt") as f:
    last_names = f.readlines()

print(random.choice(first_names).strip(), random.choice(last_names).strip())
