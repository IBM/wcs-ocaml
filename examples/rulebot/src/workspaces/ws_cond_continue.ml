open Wcs
open Wcs_aux
open Cnl_t
open Cnl_builder
open Cnl_util

let intents = []

let entities =
  Ws_common.entity_yes ::
  Ws_common.entity_no ::
  Ws_common.bom_sample_entities

let create_condition =
  dialog_node "Create Rule"
    ~description: "The ask for additional conditions"
    ~text: "Any other conditions?"
    ()

let present_condition =
  dialog_node "There is a condition"
    ~parent: create_condition
    ~conditions: "@yes"
    ~text: "Ok, there is an additional condition for this rule"
    ~context: (Context.set_bool
                 (Context.set_skip_user_input `Null true)
                 "more_cond" true)
    ()

let empty_condition =
  dialog_node "There is no condition"
    ~parent: create_condition
    ~conditions: "@no"
    ~text: "Ok no more condition"
    ~context: (Context.set_bool `Null "more_cond" false)
    ()

let response_handler =
  dialog_node "Do not understand"
    ~parent: create_condition
    ~conditions: "@no"
    ~text: "Sorry, I don't understand"
    ~next_step: (create_condition, Goto_body)
    ()

let ws_cond_continue =
  workspace "rulebot-cond-continue"
    ~description: "Dialog to add conditions to a rule condition"
    ~entities: entities
    ~intents: intents
    ~dialog_nodes: [ create_condition;
                     present_condition;
                     empty_condition;
                     response_handler;
                     Ws_common.anything_else; ]
    ()
