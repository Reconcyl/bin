all: bb26 ind line_count pick print_context rmfile vlc_keys.min.js

bb26: bb26.rs
	rustc -O $<

ind: ind.rs
	rustc -O $<

line_count: line_count.ml
	ocamlopt -O2 $< -o $@

pick: pick.c
	cc -O2 $< -o $@

print_context: print_context.rs
	rustc -O $<

rmfile: rmfile.rs
	rustc -O $<

# a suitable format for a bookmarklet
vlc_keys.min.js: vlc_keys.js
	echo "javascript:$$(terser $< -cm)" >$@

clean:
	rm -f line_count line_count.cmi line_count.cmx line_count.o
	rm -f bb26 ind pick print_context rmfile vlc_keys.min.js
