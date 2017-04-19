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

open Wcs_t

let omap f o =
  begin match o with
  | None -> None
  | Some x -> Some (f x)
  end

let example
    example
    ?created
    ()
    : intent_example
    =
  { ex_text = example;
    ex_created = created; }

let intent
    intent
    ?description
    ?(examples=[])
    ?created
    ()
    : intent_def =
  { i_def_intent = intent;
    i_def_description = description;
    i_def_examples = List.map (fun s -> example s ()) examples;
    i_def_created = created; }

let value
    value
    ?metadata
    ?(synonyms=[])
    ?created
    ()
    : entity_value =
  { e_value = value;
    e_metadata = metadata;
    e_synonyms = synonyms;
    e_created = created; }

let entity
    entity
    ?metadata
    ?source
    ?open_list
    ?(values=[])
    ?created
    ()
    : entity_def =
  { e_def_entity = entity;
    e_def_description = metadata;
    e_def_source = source;
    e_def_open_list = open_list;
    e_def_values = List.map (fun (v, syn) -> value v ~synonyms:syn ()) values;
    e_def_created = created;  }

type selector =
  | User_input
  | Condition
  | Body

let string_of_selector selector =
  begin match selector with
  | User_input -> "user_input"
  | Condition -> "condition"
  | Body -> "body"
  end

let go_to
    node
    ?(return=false)
    ~selector
    ()
    : go_to =
  { goto_return = return;
    goto_selector = string_of_selector selector;
    goto_dialog_node = node.node_dialog_node; }

let mk_go_to = go_to (* alias to avoid hiding *)

let go_to_id
    node_id
    ?(return=false)
    ~selector
    ()
    : go_to =
  { goto_return = return;
    goto_selector = string_of_selector selector;
    goto_dialog_node = node_id; }

let mk_go_to_id = go_to_id (* alias to avoid hiding *)

let output (* XX TODO : handle multiple outputs *)
    text
    : output_def =
  (`Assoc [ "text", `String text ])

let mk_output = output (* alias to avoid hiding *)

let dialog_node
    dialog_node
    ?description
    ?(conditions="true")
    ?parent
    ?previous_sibling
    ?text
    ?output
    ?context
    ?metadata
    ?go_to
    ?go_to_id
    ?created
    ()
    : dialog_node =
  let parent_id =
    omap (fun node -> node.node_dialog_node) parent
  in
  let previous_sibling_id =
    omap (fun node -> node.node_dialog_node) previous_sibling
  in
  let output =
    begin match text, output with
    | None, None -> None
    | Some text, None -> Some (mk_output text)
    | None, Some output -> Some output
    | Some _, Some _ ->
        raise (Failure "dialog_node: ~text and ~output cannot be present simlutanously")
    end
  in
  let go_to =
    begin match go_to, go_to_id with
    | None, None -> None
    | Some (node, selector), None -> Some (mk_go_to node ~selector ())
    | None, Some (node_id, selector) -> Some (mk_go_to_id node_id ~selector ())
    | Some _, Some _ ->
        raise (Failure "dialog_node: ~go_to and ~go_to_id cannot be present simlutanously")
    end
  in
  { node_dialog_node = dialog_node;
    node_description = description;
    node_conditions = Some conditions;
    node_parent = parent_id;
    node_previous_sibling = previous_sibling_id;
    node_output = output;
    node_context = context;
    node_metadata = metadata;
    node_go_to = go_to;
    node_created = created;
    node_child_input_kind = None; }

let setNodeParent parent (x:Wcs_t.dialog_node) =
   {x with node_parent = omap (fun (node:Wcs_t.dialog_node) -> node.node_dialog_node) parent}

let setNodeParentIfNone parent (x:Wcs_t.dialog_node) =
  match x.node_parent with
    | Some _ -> x
    | None -> {x with node_parent = omap (fun (node:Wcs_t.dialog_node) -> node.node_dialog_node) parent}

let updateNodeName (f:string->string) (x:Wcs_t.dialog_node) =
  {x with node_dialog_node = f (x.node_dialog_node)}

let getNodeName (x:Wcs_t.dialog_node) =
  x.node_dialog_node

let fix_links nodes =
  let parent_child_tbl = Hashtbl.create 7 in
  let node_tbl = Hashtbl.create 7 in
  List.map
    (fun node ->
      let node =
        begin match node.node_parent, node.node_previous_sibling with
        | Some _, Some _ -> node
        | Some _, None
        | None, None ->
            begin try
              let previous_sibling =
                Hashtbl.find parent_child_tbl node.node_parent
              in
              { node with
                node_previous_sibling = Some previous_sibling.node_dialog_node }
            with Not_found ->
              node
            end
        | None, Some previous_sibling_name ->
            begin try
              let previous_sibling =
                Hashtbl.find node_tbl previous_sibling_name
              in
              { node with
                node_parent = previous_sibling.node_parent }
            with Not_found ->
              assert false;
              node
            end
        end
      in
      Hashtbl.add parent_child_tbl node.node_parent node;
      Hashtbl.add node_tbl node.node_dialog_node node;
      node)
    nodes


let workspace
    name
    ?description
    ?language
    ?metadata
    ?(counterexamples=[])
    ?(dialog_nodes=[])
    ?(entities=[])
    ?(intents=[])
    ?created
    ?modified
    ?created_by
    ?modified_by
    ?workspace_id
    ()
    : workspace =
  let counterexamples =
    List.map (fun s -> example s ()) counterexamples
  in
  { ws_name = Some name;
    ws_description = description;
    ws_language = language;
    ws_metadata = metadata;
    ws_counterexamples = counterexamples;
    ws_dialog_nodes = fix_links dialog_nodes;
    ws_entities = entities;
    ws_intents = intents;
    ws_created = created;
    ws_modified = modified;
    ws_created_by = created_by;
    ws_modified_by = modified_by;
    ws_workspace_id = workspace_id; }

let sys_number : entity_def =
 entity "sys-number"
    ~source: "system.entities"
    ()
