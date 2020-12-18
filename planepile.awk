#!/usr/bin/awk -f

# A simple multiplayer board game in awk. This expects
# "keys" to be sent in from STDIN in a literal form.
# It is intended for the user to pipe input into it
# from a program like keybuffer.

# Mechanically, the game is similar to Connect Four:
# players take turns building up a structure by adding
# tiles of their respective colors, aiming to align
# a sufficient number of their own tiles along a
# vertical, horizontal, or diagonal row. The main
# differences are:
# - More than two players are supported.
# - The number of tiles needed in a row to win can be
#   configured before playing.
# - The grid extends infinitely in all four directions.
# - Players can "drop" a tile from any direction, as
#   long as it lands on part of the existing structure.

# initialize various constants
BEGIN {
    srand()

    win_len = 5

    n_color = 9

    color[0] = "red"
    color[1] = "orange"
    color[2] = "yellow"
    color[3] = "green"
    color[4] = "cyan"
    color[5] = "blue"
    color[6] = "magenta"
    color[7] = "purple"
    color[8] = rand() < 0.5 ? "gray" : "grey"

    ansi["reset"] = 0
    ansi[0] = 91
    ansi[1] = "38;5;202"
    ansi[2] = 93
    ansi[3] = 92
    ansi[4] = 96
    ansi[5] = 94
    ansi[6] = 95
    ansi[7] = "38;5;53"
    ansi[8] = 90

    active[0] = 1
    active[5] = 1

    pane = 0
    menu_a = 0
    menu_b = 0
    menu_col = 0

    render()
}

# clear the screen
function clear() {
    printf "\x1b[2J"
}

# clear to the end of the line
function clear_to_end() {
    printf "\x1b[J"
}

# move the cursor up
function go_up() {
    printf "\x1b[A"
}

# move to a particular position
function go_to(x, y) {
    printf "\x1b[%d;%dH", y, x
}

# set fg color
function set_color(n) {
    printf "\x1b[%sm", ansi[n]
}

# count how many elements of `active` are true
function n_active() {
    res = 0
    for (i = 0; i < n_color; i++) if (active[i]) res++
    return res
}

# search through `active` starting from `n`
# until we find a true one, and set that to
# the variable `turn`.
function find_active(n) {
    do {
        n++
        if (n == n_color) {
            n = 0
        }
    } while (!active[n])
    turn = n
}

# set an element of the grid and adjust
# the bounds variables if necessary
function set_in_grid(x, y, data) {
    if (x >= grid_max_x) grid_max_x = x
    if (x <= grid_min_x) grid_min_x = x
    if (y >= grid_max_y) grid_max_y = y
    if (y <= grid_min_y) grid_min_y = y
    grid[x, y] = data
}

# set the `valid_dirs` array to contain information
# about whether pieces can be dropped from a particular
# direction to the cursor
function find_valid_dirs() {
    valid_dirs[0] = !!grid[cursor_x + 1, cursor_y]
    valid_dirs[1] = !!grid[cursor_x - 1, cursor_y]
    valid_dirs[2] = !!grid[cursor_x, cursor_y + 1]
    valid_dirs[3] = !!grid[cursor_x, cursor_y - 1]
    for (x = cursor_x; x >= grid_min_x; x--) {
        if (grid[x, cursor_y]) {
            valid_dirs[0] = 0
            break
        }
    }
    for (x = cursor_x; x <= grid_max_x; x++) {
        if (grid[x, cursor_y]) {
            valid_dirs[1] = 0
            break
        }
    }
    for (y = cursor_y; y >= grid_min_y; y--) {
        if (grid[cursor_x, y]) {
            valid_dirs[2] = 0
            break
        }
    }
    for (y = cursor_y; y <= grid_max_y; y++) {
        if (grid[cursor_x, y]) {
            valid_dirs[3] = 0
            break
        }
    }
}

# attempt to drop a piece at the cursor location
function play() {
    if (winner != "") {
        pane = 0
        menu_b = 0
        return
    }
    if (valid_dirs[0] || valid_dirs[1] \
    ||  valid_dirs[2] || valid_dirs[3]) {
        set_in_grid(cursor_x, cursor_y, turn + 1)
        if (win()) {
            winner = turn
        } else {
            find_active(turn)
        }
    }
}

# check if the most recent play resulted in a win
function win() {
    i = 0
    for (dy = -1; dy <= 1; dy++) {
        for (dx = -1; dx <= 1; dx++) {
            if (dx == 0 && dy == 0) continue
            x = cursor_x
            y = cursor_y
            n = 0
            do {
                x += dx
                y += dy
                n++
            } while (grid[x, y] == grid[cursor_x, cursor_y])
            win_dirs[i++] = n
        }
    }
    if (win_dirs[0] + win_dirs[7] > win_len) return 1
    if (win_dirs[1] + win_dirs[6] > win_len) return 1
    if (win_dirs[2] + win_dirs[5] > win_len) return 1
    if (win_dirs[3] + win_dirs[4] > win_len) return 1
    return 0
}

# print a message based on the UI state
function render() {
    did_render = 1
    clear()
    if (pane == 0) {
        # print col a
        go_to(4, 2)
        printf "P L A N E P I L E"
        go_to(4, 3)
        printf "================="
        go_to(6, 5)
        if (n_active() < 2) set_color(8)
        printf "play"
        set_color("reset")
        go_to(6, 7)
        printf "connect: %d", win_len

        # print divider
        for (i = 0; i < n_color + 2; i++) {
            go_to(24, i + 2)
            printf "|"
        }

        # print col b
        go_to(28, 2)
        printf "Players:"
        for (i = 0; i < n_color; i++) {
            if (active[i]) {
                go_to(29, i + 4)
                printf "+ "
            } else {
                go_to(31, i + 4)
            }
            set_color(i)
            printf "%s", color[i]
            set_color("clear")
        }

        # print indicator
        if (menu_col == 0) {
            go_to(4, 5 + 2*menu_a)
            printf ">"
        } else if (menu_col == 1) {
            go_to(27, menu_b + 4)
            printf ">"
        }
        prompt_y = n_color + 5
    } else if (pane == 1) {
        r = 10
        # render the normal grid
        for (dy = -r; dy <= r; dy++) {
            for (dx = -r; dx <= r; dx++) {
                center = dx == 0 && dy == 0 && winner == ""
                term_y = dy + r + 2
                term_x = (dx + r) * 2 + 4
                x = dx + cursor_x
                y = dy + cursor_y
                item = grid[dx + cursor_x, dy + cursor_y]
                if (center) {
                    go_to(term_x - 1, term_y)
                    set_color(turn)
                    printf "["
                    set_color("reset")
                } else {
                    go_to(term_x, term_y)
                }
                if (item == -1) {
                    printf "@"
                } else if (item == 0) {
                    set_color(8)
                    printf "•"
                    set_color("reset")
                } else {
                    set_color(item - 1)
                    printf "@"
                    set_color("reset")
                }
                if (center) {
                    set_color(turn)
                    printf "]"
                    set_color("reset")
                }
            }
        }
        if (winner == "") {
            # which directions can we place blocks from?
            find_valid_dirs()
            if (valid_dirs[0]) {
                go_to(2, r + 2)
                printf ">"
            }
            if (valid_dirs[1]) {
                go_to(r * 4 + 6, r + 2)
                printf "<"
            }
            if (valid_dirs[2]) {
                go_to(r * 2 + 4, 1)
                printf "v"
            }
            if (valid_dirs[3]) {
                go_to(r * 2 + 4, r * 2 + 4)
                printf "^"
            }
        } else {
            go_to(r * 2 - 5, r * 2 + 5)
            set_color(winner)
            printf "%s", color[winner]
            set_color("reset")
            printf " wins"
        }
        prompt_y = r * 2 + 4
    }
    go_to(2, prompt_y)
    printf "> "
    fflush "/dev/stdout"
}

{ did_render = 0 }

/up/ {
    if (pane == 0) {
        if (menu_col == 0) {
            menu_a = !menu_a
        } else if (menu_col == 1) {
            if (menu_b == 0) menu_b = n_color
            menu_b--
        }
    } else if (pane == 1) {
        cursor_y -= 1
    }
    render()
}

/down/ {
    if (pane == 0) {
        if (menu_col == 0) {
            menu_a = !menu_a
        } else if (menu_col == 1) {
            menu_b++
            if (menu_b == n_color) menu_b = 0
        }
    } else if (pane == 1) {
        cursor_y += 1
    }
    render()
}

/left/ {
    if (pane == 0) {
        menu_col = !menu_col
    } else if (pane == 1) {
        cursor_x -= 1
    }
    render()
}

/right/ {
    if (pane == 0) {
        menu_col = !menu_col
    } else if (pane == 1) {
        cursor_x += 1
    }
    render()
}

/[+=]/ {
    if (pane == 0) {
        if (menu_col == 0) {
            if (menu_a == 1 && win_len < 9) win_len++
        } else if (menu_col == 1) {
            active[menu_b] = 1
        }
    }
    render()
}

/\-/ {
    if (pane == 0) {
        if (menu_col == 0) {
            if (menu_a == 1 && win_len > 2) win_len--
        } else if (menu_col == 1) {
            active[menu_b] = 0
        }
    }
    render()
}

/ / {
    if (pane == 0) {
        if (menu_col == 0) {
            if (menu_a == 0 && n_active() >= 2) {
                pane = 1
                delete grid
                grid_max_x = 0
                grid_min_x = 0
                grid_max_y = 0
                grid_min_y = 0
                set_in_grid(0, 0, -1)
                cursor_x = 0
                cursor_y = 0
                winner = ""
                find_active(-1)
            }
        } else if (menu_col == 1) {
            active[menu_b] = !active[menu_b]
        }
    } else if (pane == 1) {
        play()
    }
    render()
}

/0/ {
    if (pane == 1) {
        cursor_x = 0
        cursor_y = 0
    }
    render()
}

/q/ {
    if (pane == 0) {
        print
        exit 0
    }
}

!did_render {
    go_to(2, prompt_y)
    clear_to_end()
    printf "> "
}
