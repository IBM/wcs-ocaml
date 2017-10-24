# SDK and command line interface for Watson Conversation Service

wcs-ocaml is a source development kit in OCaml and command line interface for
[Watson Conversation Service (WCS)](https://www.ibm.com/watson/services/conversation/). It allows to program chat bots in OCaml.

* `wcs-lib` provides a framework to write WCS programs, called
  workspaces.
* `wcs-api` offers an OCaml binding to the
  [service API](https://www.ibm.com/watson/developercloud/conversation/api/v1/)
  and a generic client application.
* `wcs` is a command line tool that interact with the service.

## Quick install with Opam

The easiest way to install wcs-ocaml is through the Opam package manager for OCaml.
Instructions to install Opam on you system can be found on the website:
http://opam.ocaml.org/doc/Install.html

Then you can install wcs-ocaml with the following command:
```
opam install wcs
```

This will install the three main packages:
- wcs-lib,
- wcs-api, and,
- wcs

Alternatively, you can only install the WCS API:
```
opam install wcs-api
```

or the Ocaml SDK (which will also install the api):
```
opam install wcs-lib
```

## Building from source
### Prerequistes

To build from source, you will need:
- OCaml 4.04 or later (http://ocaml.org/) along with the following libraries:
  - ocamlfind, a library manager (http://projects.camlcity.org/projects/findlib.html)
  - jbuilder, a build system (https://github.com/janestreet/jbuilder)
  - atdgen, a json parser generator (https://github.com/mjambon/atdgen)
  - cohttp, HTTPS client (https://github.com/mirage/ocaml-cohttp)
  - sedlex, a lexer that supports Unicode (https://github.com/alainfrisch/sedlex)
  - menhir, a parser generator (http://gallium.inria.fr/~fpottier/menhir/)

An easy way to get set up on most platforms is to use the OCaml
package manager (https://opam.ocaml.org). Once opam is installed, you
can just add the corresponding libraries:
```
opam install ocamlfind jbuilder atdgen
opam install lwt_ssl cohttp-lwt-unix
opam install sedlex menhir
```

### Compiling

To compile, do:

```
make
```

## Watson Conversation Service OCaml API

The interface to use Watson Conversation Service is defined in the
module `Wcs` (https://github.com/IBM/wcs-ocaml/blob/master/wcs-api/wcs.mli)
