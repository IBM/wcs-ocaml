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

# Example

In order to illustrate the use of wcs-ocaml, we are going to program a
bot that tells a knock knock joke.

Let's start to create a dialog node that says `"Knock knock"`:

```ocaml
let knock =
  Wcs.dialog_node "Knock"
    ~conditions: "true"
    ~text: "Knock knock"
	()
```

The function
[`Wcs.dialog_node`](https://ibm.github.io/wcs-ocaml/wcs-lib/Wcs/index.html#val-dialog_node)
creates a value of type
[`Wcs_t.dialog_node`](https://ibm.github.io/wcs-ocaml/wcs-lib/Wcs_t/index.html#type-dialog_node)
that corresponds to a JSON object of type
[`DialogNode`](https://www.ibm.com/watson/developercloud/conversation/api/v1/)
in WCS.

The user is expected to ask _who is there?_. To capture this intent
but not match exactly on this input, we can define a WCS intent with some examples to train the Natural Language Understanding component of WCS:

```ocaml
let who_intent =
  Wcs.intent "Who"
    ~examples: [
      "Who's there?";
      "Who is there?";
      "Who are you?";
    ]
    ()
```

So, we can know define the next node in the conversation that is going
to respond to the _who is there?_ question:

```ocaml
let whoisthere =
  Wcs.dialog_node "WhoIsThere"
    ~conditions_spel: (Spel.intent who_intent)
    ~text: "Broken Pencil"
    ~parent: knock
    ()
```

We can notice that here the condition is not given as a string but as
an expression written using the embedding of the Spel expression
language (used by WCS) inside OCaml.

In the rest of the conversation the user is expected to repeat the
name of the character given by the bot. To be sure that the user
repeat the name, we are going to define an entity `char_entity`
containing the name or some synonyms:

```ocaml
let char_entity =
  Wcs.entity "Characters"
    ~values: [ "Broken Pencil", ["Dammaged Pen"; "Fractured Pencil"] ]
    ()
```

If the input given by the user contains the name of the character, then
the bot terminates the joke:

```ocaml
let answer =
  Wcs.dialog_node "Answer"
    ~conditions_spel: (Spel.entity char_entity ())
    ~text: "Nevermind it's pointless"
    ~parent: whoisthere
    ~context: (Context.return (Json.bool true))
    ()
```

Setting a `return` field in the context will case the termination of
the bot. If the user doesn't gives the name of the character, we want
to tell the user what to do. So we add a fallback node:

```ocaml
let fallback =
  Wcs.dialog_node "Fallback"
    ~conditions_spel: Spel.anything_else
    ~text: "You should repreat my name!"
    ~previous_sibling: answer
    ~next_step: (whoisthere, Wcs_aux.Goto_body)
    ()
```

We can now build the entire workspace containing all the dialog nodes,
entities, and intents:

```ocaml
let ws_knockknock =
  Wcs.workspace "Knock Knock"
    ~entities: [ char_entity ]
    ~intents: [ who_intent ]
    ~dialog_nodes: [ knock; whoisthere; answer; fallback; ]
    ()
```

It is possible to print this workspace:

```ocaml
let () = print_endline (Wcs_pretty.workspace ws_knockknock)
```

But it is also possible to deploy the workspace on WCS directly from
OCaml. For that, the library needs the service credentials:

```ocaml
let wcs_cred = Wcs_bot.get_credential None
```

The call to this function [`Wcs_bot.get_credential`](XXX TODO XXX) is
going lookup in the environment variable `$WCS_CRED` to find a path to
a file name containing the service credentials in the following format:

```js
{
  "url": "https://gateway.watsonplatform.net/conversation/api",
  "password": "PASSWORD",
  "username": "USERNAME"
}
```

Now, with the service credentials, we can deploy the workspace on WCS:

```ocaml
let create_rsp = Wcs_api.create_workspace wcs_cred ws_knockknock
```

Finally, we can try the bot with the function [`Wcs_bot.exec`](XXX TODO XXX)
 and providing the workspace identifier that has just been created:

```ocaml
let _ =
  begin match create_rsp with
  | { Wcs_t.crea_rsp_workspace_id = Some id } ->
    Wcs_bot.exec wcs_cred id Json.null ""
  | _  -> failwith "Deployment error"
  end
```

To be compiled, this program needs to be linked to the `wcs-lib` and
`wcs-api` libraries. Using `ocamlfind`, it can be done as follows:

```
ocamlfind ocamlc -linkpkg -package wcs-lib -package wcs-api knockknock.ml
```
