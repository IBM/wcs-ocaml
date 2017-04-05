# wcs-ocaml
OCaml SDK and command line interface for the Watson Conversation Service

## Building
### Prerequistes

To build from source, you will need:
- OCaml 4.04 or later (http://ocaml.org/) along with the following libraries:
  - ocamlfind, a library manager (http://projects.camlcity.org/projects/findlib.html)
  - ocamlbuild, a build system (https://github.com/ocaml/ocamlbuild)
  - atdgen, a json parser generator (https://github.com/mjambon/atdgen)
  - cohttp, HTTPS client (https://github.com/mirage/ocaml-cohttp)

An easy way to get set up on most platforms is to use the OCaml
package manager (https://opam.ocaml.org). Once opam is installed, you
can just add the corresponding libraries:
```
opam install ocamlfind
opam install ocamlbuild
opam install atdgen
opam install lwt ssl cohttp
```

### Compiling

To compile, do:

```
make
```

## Command line interface

The compilation produces a command line interface for Watson
Conversation Service in:

```
bin/wcs-cli
```

The command line interface support the following commands:
  * `list` - List the workspaces associated with a Conversation service instance.
  * `create` - Create workspaces on the Conversation service instance.
  * `delete` - Delete workspaces from the Conversation service instance.
  * `get` - Get information about workspaces, optionally including all workspace contents.
  * `update` - Update an existing workspace with new or modified data.
  * `try` - Generic bot running in the terminal.
