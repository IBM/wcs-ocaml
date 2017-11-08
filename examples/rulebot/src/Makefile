WCSLIB=~/.opam/4.05.0/lib/wcs-lib
WCSAPI=~/.opam/4.05.0/lib/wcs-api

OCAMLBUILD= ocamlbuild \
		-no-links -classic-display \
		-tags annot,debug,bin_annot

RMLBUILD= rmlbuild \
		-lflags "-I","`rmlc -where`","rmllib.cmxa" \
		-no-links -classic-display \
		-tags debug,annot,thread \
		-lflags "-thread"

TARGET=native
MAIN=rulebot
RMAIN=r_rulebot

GENERATED= bmd/io_t.ml \
	   bmd/io_t.mli \
	   bmd/io_j.ml \
	   bmd/io_j.mli \
	   call_t.ml \
	   call_t.mli \
	   call_j.ml \
	   call_j.mli \
	   dialog_interface_t.ml \
	   dialog_interface_t.mli \
	   dialog_interface_j.ml \
	   dialog_interface_j.mli

all: $(RMAIN)

.PHONY: $(MAIN).$(TARGET)

$(MAIN): $(MAIN).$(TARGET)
	cp _build/$< $@

$(MAIN).$(TARGET): $(GENERATED)
	$(OCAMLBUILD) -I api -I bmd -I parser -I workspaces \
		-use-ocamlfind -use-menhir \
		-pkg atdgen -pkg cohttp.lwt \
		-pkg wcs-lib \
		$@

$(RMAIN): $(RMAIN).$(TARGET)
	cp _build/$< $@

$(RMAIN).$(TARGET): $(GENERATED)
	$(RMLBUILD) \
		-rmlc "rmlc -I $(WCSLIB) -I $(WCSAPI)" \
		-I api -I bmd -I parser -I workspaces \
		-use-ocamlfind -use-menhir \
		-pkg atdgen -pkg cohttp.lwt \
		-pkg wcs-lib -pkg wcs-api \
		$@

%_t.ml %_t.mli: %.atd
	atdgen -t $<

%_j.ml %_j.mli: %.atd
	atdgen -j -j-std $<

clean:
	$(OCAMLBUILD) -clean

cleanall: clean
	rm -f $(MAIN) $(RMAIN)
	rm -f *~ */*~ $(GENERATED)
