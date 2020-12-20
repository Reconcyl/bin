#!/usr/local/bin/python3

# An implementation of Connect Four on an infinite half-plane.
# Players take turns writing the number of the column from which
# to drop a piece. The number of pieces in a row needed to win
# can be configured using the `CONNECT` environment variable.

import itertools
import colorama
import sys, os

colorama.init()

def clear():
    print("\033[H\033[J", end="")

try:
    CONNECT = int(os.environ["CONNECT"])
except (ValueError, KeyError):
    CONNECT = 4

class Grid:
    def __init__(self):
        self.columns = {}
    def __repr__(self):
        return "\n".join(self.draw(0))
    def column_at(self, col):
        if col not in self.columns:
            self.columns[col] = []
        return self.columns[col]
    def place_at(self, col, color):
        self.column_at(col).append(color)
        return self.check_for_winner(col, color)
    def has_tile_at(self, x, y, color):
        if y < 0:
            return False
        try:
            return self.column_at(x)[y] == color
        except IndexError:
            return False
    def check_for_winner(self, col, color):
        x = col
        y = len(self.columns[col]) - 1

        for dx, dy in [(-1, 1), (1, 1), (1, 0), (0, -1)]:
            line_length = 1
            for _ in range(2):
                current_x, current_y = x, y
                while self.has_tile_at(current_x, current_y, color):
                    current_x += dx
                    current_y += dy
                    line_length += 1
                line_length -= 1
                dx = -dx
                dy = -dy
            if line_length >= CONNECT:
                return True
        return False
    def as_string(self, center_col):
        NEIGHBORHOOD_SIZE = 10
        column_chars = []
        columns = range(center_col - NEIGHBORHOOD_SIZE, center_col + NEIGHBORHOOD_SIZE + 1)
        for col in columns:
            column_data = self.column_at(col)
            column_chars.append(column_data[:])
        max_height = max(map(len, column_chars))
        for chars, col in zip(column_chars, columns):
            for _ in range(max_height - len(chars)):
                chars.append(" ")
            chars.append("=")
            chars.extend(reversed(str(col)))
        max_height = max(map(len, column_chars))
        for chars in column_chars:
            for _ in range(max_height - len(chars)):
                chars.append(" ")
        for layer in zip(*map(reversed, column_chars)):
            yield " ".join(layer)
    def draw(self, center_col):
        print("\n".join(self.as_string(center_col)))

grid = Grid()

def wrap_color(attribute, s):
    return getattr(colorama.Fore, attribute) + s + colorama.Fore.RESET

clear()
print("Connect", CONNECT, "game by Reconcyl")

players = sys.argv[1:] or ["RED", "BLUE"]

history = []

def read_input(color):
    input_string = input(wrap_color(color, "Enter column: "))
    if input_string == "quit":
        sys.exit()
    if input_string == "history":
        print(*history, sep="\n")
        return read_input(color)
    if input_string.startswith("view "):
        try:
            center_col = int(input_string[5:])
        except ValueError:
            return read_input(color)
        clear()
        grid.draw(center_col)
        return read_input(color)
    try:
        result = int(input_string)
    except ValueError:
        return read_input(color)
    else:
        history.append(result)
        return result

for color in itertools.cycle(players):
    col = read_input(color)
    clear()
    win = grid.place_at(col, wrap_color(color, "█"))
    grid.draw(col)
    if win:
        print(wrap_color(color, color.lower()), "wins!")
        break
