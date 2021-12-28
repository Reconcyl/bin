#!/usr/bin/env python3

import sys, string, secrets

lower = string.ascii_lowercase
upper = string.ascii_uppercase
numer = string.digits
alpha = lower + upper
alp48 = alpha.translate(str.maketrans({l:"" for l in "lIoO"}))

def count(s, n): assert len(s) == n; return s
formats = {}
formats["10"]   = "-", count(numer, 10)
formats["16"]   = "-", count(numer + "abcdef", 16)
formats["64+_"] = "=", count(numer + alpha + "+_", 64)
formats["64@/"] = "=", count(numer + alpha + "@/", 64)
formats["62"]   = "=", count(numer + alpha, 62)
formats["58"]   = "=", count(alp48 + numer, 58)

if len(sys.argv) != 2 or sys.argv[1] not in formats:
    print(f"""usage: {sys.argv[0]} <charset>
available charsets:
10    decimal
16    hex
64+_  base64, special chars '+' '_'
64@/  base64, special chars '@' '/'
62    a-zA-Z0-9
58    a-zA-Z0-9 minus 'l' 'I' 'o' 'O'""")
    sys.exit(1)

preserved, charset = formats[sys.argv[1]]
charset_ = set(charset)
preserved = set(preserved) | {" ", "\n"}

new = []
for char in sys.stdin.read():
    if char in charset_:
        new.append(secrets.choice(charset))
    elif char in preserved:
        new.append(char)
    else:
        print(f"invalid character {char!r}", file=sys.stderr)
        sys.exit(1)
sys.stdout.write("".join(new))
