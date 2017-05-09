
example.native: example.ml
	ocamlfind ocamlopt -opaque -linkpkg -package cohttp.lwt -package atdgen -I ../src/_build ../src/_build/wcslib.cmxa -o $@ $<

update:
	cp ~/conversation/wcs-ocaml/src/_build/* lib/

clean:
	rm -f example.cm* example.o example.native
cleanall: clean
	rm -f *~
