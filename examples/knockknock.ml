(*
 *  This file is part of the Watson Conversation Service OCaml API project.
 *
 * Copyright 2016-2017 IBM Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *)


(* Compilation command:
   `ocamlfind ocamlc -o knockknock -linkpkg -package wcs-api-unix knockknock.ml` *)

open Wcs_lib
open Wcs_api_unix

(* In order to illustrate the use of wcs-ocaml, we are going to
   program a bot that tells a knock knock joke. *)

(* Let's start with a dialog node that says `"Knock knock"`: *)

let knock =
  Wcs.dialog_node "Knock"
    ~conditions: "true"
    ~text: "Knock knock"
    ()

(* The function
  [`Wcs.dialog_node`](https://ibm.github.io/wcs-ocaml/wcs-lib/Wcs/index.html#val-dialog_node)
  creates a value of type
  [`Wcs_t.dialog_node`](https://ibm.github.io/wcs-ocaml/wcs-lib/Wcs_t/index.html#type-dialog_node)
  that corresponds to a JSON object of type
  [`DialogNode`](https://www.ibm.com/watson/developercloud/conversation/api/v1/)
  in WCS.  *)

(* The user is expected to ask _who is there?_. To capture this intent
   without looking for an exact match, we can define a WCS intent using
   multiple examples to train the NLU: *)

let who_intent =
  Wcs.intent "Who"
    ~examples: [
      "Who's there?";
      "Who is there?";
      "Who are you?";
    ]
    ()

(* We can now define the next step of the dialog, answering the
   question _who is there?: *)

let whoisthere =
  Wcs.dialog_node "WhoIsThere"
    ~conditions_spel: (Spel.intent who_intent)
    ~text: "Broken Pencil"
    ~parent: knock
    ()

(* The condition is not a string but an expression written using the
   embedding of the Spel expression language (used by WCS) in
   OCaml. *)

(* We now expect the user to repeat the name of the character
   mentioned by the bot.  To test that the user input matches the same
   character, we define an entity `char_entity` containing the name
   and a list of synonyms.  *)

let char_entity =
  Wcs.entity "Character"
    ~values: [ "Broken Pencil", ["Damaged Pen"; "Fractured Pencil"] ]
    ()

(* The bot terminates the joke if the input given by the user matches the
   name of the character. Setting a `return` field in the context triggers
   the termination of the bot. *)

let answer =
  Wcs.dialog_node "Answer"
    ~conditions_spel: (Spel.entity char_entity ())
    ~text: "Never mind it's pointless"
    ~parent: whoisthere
    ~context: (Context.return (Json.bool true))
    ()



(* If the user doesn't gives the name of the character, the bot can help
   with a generic answer using a fallback node: *)

let fallback =
  Wcs.dialog_node "Fallback"
    ~conditions_spel: Spel.anything_else
    ~text: "You should repeat my name!"
    ~previous_sibling: answer
    ~next_step: (whoisthere, Wcs_t.Goto_body)
    ()

(* We can now build the entire workspace containing all the dialog
   nodes, entities, and intents: *)

let ws_knockknock =
  Wcs.workspace "Knock Knock"
    ~entities: [ char_entity ]
    ~intents: [ who_intent ]
    ~dialog_nodes: [ knock; whoisthere; answer; fallback; ]
    ()

(* It is possible to print this workspace: *)

let () = print_endline (Wcs_pretty.workspace ws_knockknock)

(*It is also possible to directly deploy the workspace on WCS. The
  deployment requires the service credentials: *)

let wcs_cred = Wcs_bot.get_credential None

(* The function
   [Wcs_bot_unix.get_credential](https://ibm.github.io/wcs-ocaml/wcs-api/Wcs_bot_unix/index.html#val-get_credential)
   retrieves the path stored in the environment variable `WCS_CRED` to
   find a file containing the service credentials in the following
   format:

   {
     "url": "https://gateway.watsonplatform.net/conversation/api",
     "password": "PASSWORD",
     "username": "USERNAME"
   }
*)


(* We can now deploy the workspace on WCS: *)

let create_rsp = Wcs_call.create_workspace wcs_cred ws_knockknock

(* Finally, we can try the bot with the function
   [Wcs_bot_unix.exec](https://ibm.github.io/wcs-ocaml/wcs-api/Wcs_bot_unix/index.html#val-exec)
   providing the credentials and the workspace identifier that has just
   been created: *)

let _ =
  begin match create_rsp with
  | { Wcs_t.crea_rsp_workspace_id = Some id } ->
    Wcs_bot.exec wcs_cred id Json.null ""
  | _  -> failwith "Deployment error"
  end

