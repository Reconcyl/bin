#!/usr/bin/awk -f

# An implementation of Minesweeper in awk. This expects
# "keys" to be sent in from STDIN in a literal form.
# It is intended for the user to pipe input into it
# from a program like keybuffer.

BEGIN {
    srand()

    ansi["reset"] = 0
    ansi["dark red"] = "38;5;124"
    ansi["red"] = 91
    ansi["orange"] = "38;5;208"
    ansi["yellow"] = 93
    ansi["green"] = 92
    ansi["light green"] = "38;5;108"
    ansi["dark cyan"] = 36
    ansi["dark blue"] = "38;5;20"
    ansi["blue"] = 94
    ansi["purple"] = 35
    ansi["gray"] = 90

    difficulty[5] = "light green"
    difficulty[10] = "green"
    difficulty[15] = "yellow"
    difficulty[20] = "orange"
    difficulty[25] = "red"
    difficulty[30] = "dark red"

    mine_count[0] = "gray"
    mine_count[1] = "blue"
    mine_count[2] = "green"
    mine_count[3] = "red"
    mine_count[4] = "purple"
    mine_count[5] = "orange"
    mine_count[6] = "dark cyan"
    mine_count[7] = "dark blue"
    mine_count[8] = "dark red"

    pane = 0
    menu_row = 0

    grid_size = 15
    mine_density = 15
    render()
}

# clear the entire screen
function clear() {
    printf "\x1b[2J"
}

# move the cursor to a particular position
function go_to(x, y) {
    printf "\x1b[%d;%dH", y, x
}

# set fg color
function set_color(n) {
    printf "\x1b[%sm", ansi[n]
}

# print a representation based on the UI state
function render(  r, dx, dy, x, y, term_x, term_y, center, tile) {
    clear()
    if (pane == 0) {
        go_to(4, 2)
        printf "M I N E S W E E P E R"
        go_to(4, 3)
        printf "====================="
        go_to(6, 5)
        printf "play"
        go_to(6, 7)
        printf "grid size:     %2d", grid_size
        go_to(6, 9)
        printf "mine density:  "
        set_color(difficulty[mine_density])
        printf "%2d%%", mine_density
        set_color("reset")
        go_to(4, 5 + 2*menu_row)
        printf ">"
        prompt_y = 15
    } else if (pane == 1) {
        r = 10
        # render the grid
        for (dy = -r; dy <= r; dy++) {
            for (dx = -r; dx <= r; dx++) {
                term_y = dy + r + 2
                term_x = (dx + r) * 2 + 4
                x = dx + cursor_x
                y = dy + cursor_y

                center = dx == 0 && dy == 0
                if (center) {
                    go_to(term_x - 1, term_y)
                    printf "["
                } else {
                    go_to(term_x, term_y)
                }

                tile = cover[x, y]
                if (tile == "") {
                    printf " "
                } else if (tile == -3) {
                    set_color("dark red")
                    printf "*"
                    set_color("reset")
                } else if (tile == -2) {
                    set_color("gray")
                    printf "•"
                    set_color("reset")
                } else if (tile == -1) {
                    printf "?"
                } else {
                    set_color(mine_count[tile])
                    printf "%d", tile
                    set_color("reset")
                }

                if (center) {
                    printf "]"
                }
            }
        }
        prompt_y = 15
    }
    go_to(2, prompt_y)
    printf "> "
    fflush "/dev/stdout"
}

# clear the existing grid and fill the new one with mines
function init_grid(  x, y, i) {
    # `mine` contains 1 at coordinates with mines, 0 elsewhere
    delete mine
    # `cover` contains:
    # - -3 at coordinates that are mines and that have been uncovered
    # - -2 at coordinates that have not been uncovered
    # - -1 at coordinates that have been flagged
    # - 0..8 at coordinates that have been uncovered (based on the number of neighbors)
    delete cover
    for (y = 0; y < grid_size; y++) {
        for (x = 0; x < grid_size; x++) {
            mine[x, y] = 0
            cover[x, y] = -2
        }
    }
    
    num_mines = int(grid_size * grid_size * mine_density / 100)
    for (i = 0; i < num_mines; i++) {
        do {
            x = int(rand() * grid_size)
            y = int(rand() * grid_size)
        } while (mine[x, y])
        mine[x, y] = 1
    }
}

# uncover the tile under the cursor
function uncover(x, y,  dx, dy, total) {
    if (game_over) return
    if (cover[x, y] != -2) return
    if (mine[x, y]) {
        for (x = 0; x < grid_size; x++) {
            for (y = 0; y < grid_size; y++) {
                if (mine[x, y]) {
                    cover[x, y] = -3
                }
            }
        }
        game_over = 1
        return
    }

    total = 0
    for (dy = -1; dy <= 1; dy++) {
        for (dx = -1; dx <= 1; dx++) {
            if (mine[x + dx, y + dy]) total++
        }
    }
    cover[x, y] = total
    num_uncovered++

    if (total == 0) {
        for (dy = -1; dy <= 1; dy++) {
            for (dx = -1; dx <= 1; dx++) {
                uncover(x + dx, y + dy)
            }
        }
    }

    if (num_uncovered + num_mines == grid_size * grid_size) {
        game_over = 2
    }
}

# flag the tile under the cursor
function set_flag(x, y) {
    if (cover[x, y] == -1) {
        cover[x, y] = -2
    } else if (cover[x, y] == -2) {
        cover[x, y] = -1
    }
}

# attempt to decrement one of the menu options
function menu_dec() {
    if (menu_row == 1) {
        if (grid_size > 5) {
            grid_size--
        }
    } else if (menu_row == 2) {
        if (mine_density > 5) {
            mine_density -= 5
        }
    }
}

# attempt to increment one of the menu options
function menu_inc() {
    if (menu_row == 1) {
        if (grid_size < 50) grid_size++
    } else if (menu_row == 2) {
        if (mine_density < 30) mine_density += 5
    }
}

# handle the up arrow key being pressed
/up/ {
    if (pane == 0) {
        if (menu_row == 0) menu_row = 3
        menu_row--
    } else if (pane == 1) {
        if (cursor_y > 0) cursor_y--
    }
    render()
}

# handle the down arrow key being pressed
/down/ {
    if (pane == 0) {
        menu_row++
        if (menu_row == 3) menu_row = 0
    } else if (pane == 1) {
        if (cursor_y < grid_size - 1) cursor_y++
    }
    render()
}

# handle the left arrow key being pressed
/left/ {
    if (pane == 0) {
        menu_dec()
    } else if (pane == 1) {
        if (cursor_x > 0) cursor_x--
    }
    render()
}

# handle the right arrow key being pressed
/right/ {
    if (pane == 0) {
        menu_inc()
    } else if (pane == 1) {
        if (cursor_x < grid_size - 1) cursor_x++
    }
    render()
}

# handle the space key being pressed
/ / {
    if (pane == 0) {
        if (menu_row == 0) {
            pane = 1
            init_grid()
            cursor_x = int(grid_size / 2)
            cursor_y = int(grid_size / 2)
            game_over = 0
            num_uncovered = 0
        }
    } else if (pane == 1) {
        uncover(cursor_x, cursor_y)
    }
    render()
}

# handle the Q key being pressed
/q/ {
    if (pane == 0) {
        print
        exit 0
    } else if (pane == 1 && game_over) {
        pane = 0
    }
    render()
}

# handle the tab key being pressed
/tab/ {
    if (pane == 1) {
        set_flag(cursor_x, cursor_y)
    }
    render()
}
