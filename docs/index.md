# SDK and command line interface for Watson Conversation Service

wcs-ocaml is a source development kit in OCaml and command line interface for
[Watson Conversation Service (WCS)](https://www.ibm.com/watson/services/conversation/). It allows to program chat bots in OCaml.

* `wcs-lib` provides a framework to write WCS programs, called
  workspaces.
* `wcs-api` offers an OCaml binding to the
  [service API](https://www.ibm.com/watson/developercloud/conversation/api/v1/)
  and a generic client application.
* `wcs` is a command line tool that interact with the service.

The documentation of the packages is defined in the interface of the modules
and  available online:
* [`wcs-lib`](wcs-lib)
* [`wcs-api`](wcs-api)

The `wcs` command line tool allows to do operations like listing the workspaces,
uploading or updating workspaces. The full documentation if avaible with the
command `wcs -help` or [online](https://ibm.github.io/wcs-ocaml/wcs.html).

## Quick install with Opam

The easiest way to install wcs-ocaml is through the Opam package manager for OCaml.
Instructions to install Opam on you system can be found on the website:
<http://opam.ocaml.org/doc/Install.html>.

Then you can install wcs-ocaml with the following command:
```
opam install wcs
```

This will install the three main packages:
- `wcs-lib`,
- `wcs-api`, and,
- `wcs`

Alternatively, you can only install the WCS SDK:
```
opam install wcs-lib
```

or the WCS API (which will also install `wcs-lib`):
```
opam install wcs-api
```

