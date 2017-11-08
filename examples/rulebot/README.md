# rulebot
Dialog interface for events rules

# Building
## Prerequistes

To build from source, you will need:
- OCaml 4.04 or later (http://ocaml.org/) along with the following libraries:
  - ocamlfind, a library manager (http://projects.camlcity.org/projects/findlib.html)
  - ocamlbuild, a build system (https://github.com/ocaml/ocamlbuild)
  - atdgen, a json parser generator (https://github.com/mjambon/atdgen)

An easy way to get set up on most platforms is to use the OCaml
package manager (https://opam.ocaml.org). Once opam is installed, you
can just add the corresponding libraries:
```
opam install ocamlfind
opam install ocamlbuild
opam install atdgen ppx_deriving_yojson
opam install menhir
opam install lwt ssl cohttp
```

## Compiling

To compile, do:

```
make -C src
```

This should create an executable called `src/rulebot`.

# Running

To run a conversation flow, you should do:

```
src/rulebot -wcs-cred wcs_credential.json -wcs rule
```

where `wcs_credential.json` is a file containing your Watson Conversation credentials as follows:
```
{
  "url": "https://gateway.watsonplatform.net/conversation/api",
  "password": "...",
  "username": "..."
}
```

This command automatically deploys the workspaces on Watson Conversation.

You can specify which workspaces to use with the option `-ws-config ws-config.json`. The format of the file `ws-config.json` is specified in `src/dialog_interface.atd`.

You can delete the workspaces from Watson Conversation with the following command:
```
src/rulebot -wcs-cred wcs_credential.json -ws-config ws-config.json -ws-delete
```
