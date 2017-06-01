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


(** Wcs data structure constructors. *)

open Wcs_t

val list_workspaces_request :
  ?page_limit:int ->
  ?include_count:bool ->
  ?sort:sort_workspace_criteria ->
  ?cursor:string ->
  unit ->
  list_workspaces_request

val get_workspace_request :
  ?export:bool ->
  string ->
  get_workspace_request

val example :
  string ->
  ?created:string ->
  unit ->
  intent_example

val intent :
  string ->
  ?description:string ->
  ?examples:string list ->
  ?created:string ->
  unit ->
  intent_def

val value :
  string ->
  ?metadata:json ->
  ?synonyms:string list ->
  ?created:string ->
  unit ->
  entity_value

val entity :
  string ->
  ?metadata:string ->
  ?source:string ->
  ?open_list:bool ->
  ?values:(string * string list) list ->
  ?created:string ->
  unit ->
  entity_def

val go_to :
  dialog_node ->
  ?return:bool ->
  selector:selector ->
  unit ->
  go_to

val go_to_id :
  string ->
  ?return:bool ->
  selector:selector ->
  unit ->
  go_to

val output : string -> output_def

val dialog_node :
  string ->
  ?description:string ->
  ?type_: dialog_node_type ->
  ?conditions:string ->
  ?parent:dialog_node ->
  ?previous_sibling:dialog_node ->
  ?text:string ->
  ?output:output_def ->
  ?context:json ->
  ?metadata:json ->
  ?go_to:dialog_node * selector ->
  ?go_to_id:string * selector ->
  ?created:string ->
  ?event_name: dialog_node_event_name ->
  ?variable: string ->
  unit ->
  dialog_node

val response_condition :
  parent:dialog_node ->
  ?description:string ->
  ?conditions:string ->
  ?previous_sibling:dialog_node ->
  ?text:string ->
  ?output:output_def ->
  ?context:json ->
  ?metadata:json ->
  ?created:string ->
  unit -> dialog_node

val workspace :
  string ->
  ?description:string ->
  ?language:string ->
  ?metadata:json ->
  ?counterexamples:string list ->
  ?dialog_nodes:dialog_node list ->
  ?entities:entity_def list ->
  ?intents:intent_def list ->
  ?created:string ->
  ?modified:string ->
  ?created_by:string ->
  ?modified_by:string ->
  ?workspace_id:string ->
  unit ->
  workspace

val sys_number : entity_def


(** {6 Tree modification} *)

val add_tree:
      dialog_node list ->
      dialog_node list ->
      dialog_node option ->
      dialog_node option ->
      dialog_node list
(** [add_tree tree subtree parent previous_sibling] add the tree
    [subtree] in the dialog [tree]. The root of [subtree] is attached
    at the position defined with [parent] and [previous_sibling]. If
    there was already a node at this postion, it becomes the last
    sibling of the root of [subtree].
*)

(** {Tree access} *)

val get_root : dialog_node list -> dialog_node option
(** [get_root tree] return the root of the dialog tree [tree]. It
    returns [None] if the tree is empty.
*)
