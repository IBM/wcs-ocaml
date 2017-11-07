# SDK and command line interface for Watson Conversation Service

wcs-ocaml is a source development kit in OCaml and command line interface for
[Watson Conversation Service (WCS)](https://www.ibm.com/watson/services/conversation/). It allows to program chat bots in OCaml.

* `wcs-lib` provides a framework to write WCS programs, called
  workspaces.
* `wcs-api` offers an OCaml binding to the
  [service API](https://www.ibm.com/watson/developercloud/conversation/api/v1/)
  and a generic client application.
* `wcs` is a command line tool that interact with the service.

The documentation is available [online](https://ibm.github.io/wcs-ocaml/) or in
the directory (docs)[./docs].

# Install

## Quick install with Opam

You can install wcs-ocaml with the following command:
```
opam install wcs
```

This will install the three main packages:
- wcs-lib,
- wcs-api, and,
- wcs


## Building from source
### Prerequistes

To build from source, you will need to install the dependencies
listed in the `depends` field of the `*.opam` files.

An easy way to get set up on most platforms is to use the OCaml
package manager (https://opam.ocaml.org). Once opam is installed, you
can just add the corresponding libraries:
```
opam install ocamlfind sedlex menhir rml ...
```

### Compiling

To compile, do:

```
make
```

### Compiling with Opam

Opam can also be used to compile and install from the source
directory. For that you first need to pin the source directory.
So, from this directory, do:
```
opam pin add wcs-lib .
opam pin add wcs-api .
opam pin add wcs .
```

Then you can install using the command:
```
opam install wcs
```

If the source files are modified, the packages must be reinstalled
with the command:
```
opam reinstall wcs-lib
```

# Contribute

Contributions and bug reports are welcome!
To contribute please follows the instructions given in the file (CONTRIBUTING.md)[./CONTRIBUTING.md].
