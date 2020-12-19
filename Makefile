all: bb26 pick print_context

bb26:
	rustc bb26.rs

pick:
	cc -O2 pick.c

print_context:
	rustc print_context.rs

clean:
	rm -f bb26 pick print_context
