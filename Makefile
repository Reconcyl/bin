all: bb26 ind line_count pick print_context rmfile

bb26: bb26.rs
	rustc -O bb26.rs

ind: ind.rs
	rustc -O ind.rs

line_count line_count.cmi line_count.cmx line_count.o: line_count.ml
	ocamlopt -O2 line_count.ml -o line_count

pick: pick.c
	cc -O2 pick.c -o pick

print_context: print_context.rs
	rustc -O print_context.rs

rmfile: rmfile.rs
	rustc -O rmfile.rs

clean:
	rm -f line_count line_count.cmi line_count.cmx line_count.o
	rm -f bb26 ind pick print_context rmfile
