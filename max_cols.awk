#!/usr/bin/awk -f

# Identify the index of the longest line in the provided file.

BEGIN { m=0; l=-1 }
{ if (length($0)>m) {m=length($0); l=NR} }
END { print"The longest line is "l" with "m" cols" }
