all: bb26 line_count pick print_context

bb26:
	rustc bb26.rs

line_count line_count.cmi line_count.cmx line_count.o:
	ocamlopt line_count.ml -o line_count

pick:
	cc -O2 pick.c

print_context:
	rustc print_context.rs

clean:
	rm -f line_count line_count.cmi line_count.cmx line_count.o
	rm -f bb26 pick print_context
