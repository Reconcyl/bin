#!/bin/bash

# Takes two arguments:
# - the phrase to search for (should be urlencoded)
# - the page number (starts from 1)

# It queries shadertoy.com for shader posts containing that query
# and prints as many to STDOUT as there are on the current page.

# This is useful as viewing shadertoy search results in a browser
# can be laggy on some machines as many (often GPU-intensive) shaders
# are visible at once.

# Note that more recent updates to the shadertoy website format seem
# to have broken this script, and I will need to redo the scraping logic.

curl "https://www.shadertoy.com/results?query=$1&sort=popular&from=$((12 * ($2 - 1)))&num=12" \
    | grep gShaderIDs | tr '"' '\n' | awk 'NR%2==0{print"https://shadertoy.com/view/"$1}'
