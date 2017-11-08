open Wcs_aux
open Wcs
open Cnl_builder
open Cnl_util

let intents = []
let entities =
  Ws_common.entity_yes ::
  Ws_common.entity_no ::
  []

(* let create_rule = *)
(*   let instr = mk_actns_desc_undefined () in *)
(*   dialog_node "Create Rule" *)
(*     ~description: "The top of the create/rule flow" *)
(*     ~text: "Let's build the then part." *)
(*     ~context: (Context.set_actns_desc `Null "actns_desc" instr) *)
(*     () *)

let prompt =
  dialog_node "prompt"
    ~text: "Any other action?"
    ()

let add_element =
  dialog_node "Add element"
    ~conditions: "@yes"
    ~parent: prompt
    ~context: (Context.set_bool
                 (Context.set_skip_user_input `Null true)
                 "actns_closed" false)
    ()

let do_not_add_element =
  dialog_node "Do not add element"
    ~conditions: "@no"
    ~parent: prompt
    ~context: (Context.set_bool `Null "actns_closed" true)
    ()

let handler =
  dialog_node "Do not understand"
    ~parent: prompt
    ~text: "I don't understand."
    ~next_step: (prompt, Goto_body)
    ()


let ws_then =
  workspace "rulebot-then"
    ~description: "Dialog to build the action part of a rule"
    ~entities: entities
    ~intents: intents
    ~dialog_nodes: [ prompt;
                     add_element;
                     do_not_add_element;
                     handler;
                     Ws_common.anything_else ]
    ()
