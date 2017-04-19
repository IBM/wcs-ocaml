# This file is part of the Watson Conversation Service OCaml API project.
#
# Copyright 2016-2017 IBM Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


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

.PHONY: $(MAIN).$(TARGET) wcslib.cmxa

$(MAIN): $(MAIN).$(TARGET)
	cp _build/$< $@

$(MAIN).$(TARGET): $(GENERATED)
	$(OCAMLBUILD) \
		-use-ocamlfind \
		-pkg atdgen -pkg cohttp.lwt $@

wcslib.cmxa: $(GENERATED)
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
