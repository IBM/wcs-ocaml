OCAMLBUILD= ocamlbuild \
		-no-links -classic-display \
		-tags annot,debug,bin_annot

TARGET=native
MAIN=test

GENERATED= api/wcs_t.ml \
	   api/wcs_t.mli \
	   api/wcs_j.ml \
	   api/wcs_j.mli

all: $(MAIN)

.PHONY: $(MAIN).$(TARGET)

$(MAIN): $(MAIN).$(TARGET)
	cp _build/$< $@

$(MAIN).$(TARGET): $(GENERATED)
	$(OCAMLBUILD) -I api -I bmd -I parser -I workspaces \
		-use-ocamlfind -use-menhir \
		-pkg atdgen -pkg cohttp.lwt -pkg ppx_deriving_yojson $@

%_t.ml %_t.mli: %.atd
	atdgen -t $<

%_j.ml %_j.mli: %.atd
	atdgen -j -j-std $<

clean:
	$(OCAMLBUILD) -clean

cleanall: clean
	rm -f $(MAIN)
	rm -f *~ */*~ $(GENERATED)
