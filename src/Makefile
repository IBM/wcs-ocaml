OCAMLBUILD= ocamlbuild \
		-no-links -classic-display \
		-tags annot,debug,bin_annot

TARGET=native
MAIN=wcs_cli

GENERATED= wcs_t.ml \
	   wcs_t.mli \
	   wcs_j.ml \
	   wcs_j.mli

all: $(MAIN)

.PHONY: $(MAIN).$(TARGET)

$(MAIN): $(MAIN).$(TARGET)
	cp _build/$< $@

$(MAIN).$(TARGET): $(GENERATED)
	$(OCAMLBUILD) \
		-use-ocamlfind \
		-pkg atdgen -pkg cohttp.lwt $@

%_t.ml %_t.mli: %.atd
	atdgen -t $<

%_j.ml %_j.mli: %.atd
	atdgen -j -j-std $<

clean:
	$(OCAMLBUILD) -clean

cleanall: clean
	rm -f $(MAIN)
	rm -f *~ */*~ $(GENERATED)
