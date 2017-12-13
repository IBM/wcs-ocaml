all: client.js

client.byte: client_jsoo.ml
	ocamlfind ocamlc -linkpkg -package lwt_ssl -package wcs-api-jsoo -package js_of_ocaml-lwt -o client.byte client_jsoo.ml

client.js: client.byte
	js_of_ocaml -o client.js +weak.js client.byte

# client.byte: client_jsoo.ml
# 	ocamlfind ocamlc -linkpkg -package wcs-lib -o client.byte client_jsoo.ml

# client.js: client.byte
# 	js_of_ocaml -o client.js client.byte


clean:
	rm -f client client.byte client.js client_jsoo.cm*
