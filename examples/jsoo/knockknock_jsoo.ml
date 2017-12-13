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

(* This example is a bot that tells a knock knock joke. *)


(** {6 Programming} *)

let knock =
  Wcs.dialog_node "Knock"
    ~conditions: "true"
    ~text: "Knock knock"
    ()

let who_intent =
  Wcs.intent "Who"
    ~examples: [
      "Who's there?";
      "Who is there?";
      "Who are you?";
    ]
    ()

let whoisthere =
  Wcs.dialog_node "WhoIsThere"
    ~conditions_spel: (Spel.intent who_intent)
    ~text: "Broken Pencil"
    ~parent: knock
    ()

let char_entity =
  Wcs.entity "Character"
    ~values: [ "Broken Pencil", ["Damaged Pen"; "Fractured Pencil"] ]
    ()

let answer =
  Wcs.dialog_node "Answer"
    ~conditions_spel: (Spel.entity char_entity ())
    ~text: "Never mind it's pointless"
    ~parent: whoisthere
    ~context: (Context.return (Json.bool true))
    ()

let fallback =
  Wcs.dialog_node "Fallback"
    ~conditions_spel: Spel.anything_else
    ~text: "You should repeat my name!"
    ~previous_sibling: answer
    ~next_step: (whoisthere, Wcs_t.Goto_body)
    ()

let ws_knockknock =
  Wcs.workspace "Knock Knock"
    ~entities: [ char_entity ]
    ~intents: [ who_intent ]
    ~dialog_nodes: [ knock; whoisthere; answer; fallback; ]
    ()

let () = print_endline (Wcs_pretty.workspace ws_knockknock)


(** {6 Deployement and test} *)

open Wcs_api_jsoo

let wcs_cred = Wcs_bot.get_credential None

let create_rsp = Wcs_call.create_workspace wcs_cred ws_knockknock

(* let _ = *)
(*   begin match create_rsp with *)
(*   | { Wcs_t.crea_rsp_workspace_id = Some id } -> *)
(*     Wcs_bot.exec wcs_cred id Json.null "" *)
(*   | _  -> failwith "Deployment error" *)
(*   end *)


(* let main () = *)
(*   let wcs_cred_file = ref None in *)
(*   let ws_id = ref None in *)
(*   let print = ref false in *)
(*   let deploy = ref false in *)
(*   let exec = ref false in *)
(*   let speclist = *)
(*     Arg.align *)
(*       [ "-cred", Arg.String (fun s -> wcs_cred_file := Some s), *)
(*         "cred.json The file containing the Watson Conversation Service credentials."; *)
(*         "-id", Arg.String (fun id -> ws_id := Some id), *)
(*         "id The workspace id used to update in conjunction with -deploy."; *)
(*         "-print", Arg.Set print, *)
(*         " Print the workspace on stdout."; *)
(*         "-deploy", Arg.Set deploy, *)
(*         " Create or update the workspace on Watson Conversation Service."; *)
(*         "-exec", Arg.Set exec, *)
(*         " Execute the chatbot."; *)
(*         "-debug", Arg.Set Log.debug_message, *)
(*         " Print debug messages."; *)
(*       ] *)
(*   in *)
(*   let usage = *)
(*     "Usage: "^Sys.argv.(0)^" [options]" *)
(*   in *)
(*   Arg.parse speclist (fun _ -> ()) usage; *)
(*   let wcs_cred = Wcs_bot.get_credential !wcs_cred_file in *)
(*   begin match !print with *)
(*   | true -> *)
(*       print_endline (Wcs_pretty.workspace ws_knockknock) *)
(*   | false -> *)
(*       () *)
(*   end; *)
(*   begin match !deploy, !ws_id with *)
(*   | true, Some ws_id -> *)
(*       let () = Wcs_call.update_workspace wcs_cred ws_id ws_knockknock in *)
(*       Format.printf "%s: updated@." ws_id *)
(*   | true, None -> *)
(*       begin match Wcs_call.create_workspace wcs_cred ws_knockknock with *)
(*       | { crea_rsp_workspace_id = Some id } -> *)
(*           Format.printf "%s: created@." id; *)
(*           ws_id := Some id; *)
(*       | _ -> assert false *)
(*       end *)
(*   | false, _ -> () *)
(*   end; *)
(*   begin match !exec, !ws_id with *)
(*   | true, Some id -> *)
(*       let _ = Wcs_bot.exec wcs_cred id `Null "" in *)
(*       () *)
(*   | false, _ -> *)
(*       () *)
(*   | true, None -> *)
(*       Arg.usage speclist "no worksapce to execute"; *)
(*       exit 1 *)
(*   end *)

(* let _ = *)
(*   begin try *)
(*     main () *)
(*   with *)
(*   | Log.Error (module_name, msg) when not !Log.debug_message -> *)
(*       Format.eprintf "%s@." msg; *)
(*       exit 1 *)
(*   end *)
