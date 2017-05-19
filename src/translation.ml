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
open Dialog_t

let dialog_node_of_node (n : node) : dialog_node list =
  let root =
    { node_dialog_node = n.n_dialog_node;
      node_type_ = None;
      node_description = n.n_description;
      node_conditions = n.n_conditions;
      node_parent = None;
      node_previous_sibling = None;
      node_output = None;
      node_context = None;
      node_metadata = n.n_metadata;
      node_go_to = n.n_go_to;
      node_child_input_kind = None;
      node_created = n.n_created;
      node_event_name = None;
      node_variable = None; }
  in
  let children =
    begin match n.n_reactions with
    | [] -> []
    | _ -> assert false (* XXX TODO XXX *)
    end
  in
  let children =
    begin match n.n_slots with
    | [] -> children
    | _ -> assert false (* XXX TODO XXX *)
    end
  in
  let root, children =
    begin match n.n_responses with
    | [] -> root, children
    | [ { r_conditions = None;
          r_output = output;
          r_context = context; } ] ->
        let root =
          { root with
            node_output = output;
            node_context = context; }
        in
        root, children
    | _ -> assert false (* XXX TODO XXX *)
    end
  in
  root :: children

let get_root tree =
  List.find
    (fun dn -> dn.node_parent == None && dn.node_previous_sibling == None)
    tree

let dialog_nodes_of_dialog (d: dialog) : dialog_node list =
  let rec compile d =
    begin match d with
    | D (n, children) ->
        let dialog_nodes =
          List.fold_right
            (fun n_child acc ->
               let dn_child_tree = compile n_child in
               let dn_child = get_root dn_child_tree in
               Wcs_builder.add_tree dn_child_tree acc None (Some dn_child))
            children []
        in
        let dn_tree = dialog_node_of_node n in
        let root = get_root dn_tree in
        Wcs_builder.add_tree dn_tree dialog_nodes (Some root) None
    end
  in
  compile d
