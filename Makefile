all: bb26 ind line_count pick print_context

bb26:
	rustc -O bb26.rs

ind:
	rustc -O ind.rs

line_count line_count.cmi line_count.cmx line_count.o:
	ocamlopt -O2 line_count.ml -o line_count

pick:
	cc -O2 pick.c -o pick

print_context:
	rustc -O print_context.rs

clean:
	rm -f line_count line_count.cmi line_count.cmx line_count.o
	rm -f bb26 ind pick print_context
