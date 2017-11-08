open Wcs_aux
open Wcs
open Cnl_util
open Wcs_j

let intents = [ Ws_common.intent_help ]
let entities bmd = Bmd_to_wcs_entities.entities_of_bmd bmd

let when_node =
  let instr = "@entity", Some "the @entity" in
  dialog_node "When Clause"
    ~description: "Specify a when clause"
    ~conditions: "@entity"
    ~text: "Ok, @entity."
    ~context: (Context.set_evnt_desc `Null "evnt_desc" instr)
    ()

let prompt =
  dialog_node "Prompt"
    ~conditions: "conversation_start"
    ~text: "Which input event should trigger the rule?"
    ()

let help es =
  dialog_node "Help"
    ~conditions: "#mk_help && intents[0].confidence > 0.9"
    ~text: ("The available entities are: " ^ Ws_common.mkEnglishList "and" es)
    ~next_step: (prompt, Goto_body)
    ()

let do_not_understand =
  dialog_node "Do not understand"
    ~next_step_id: ("Help", Goto_body)
    ~text: ("I did not understand what entity you meant.")
    ()

let ws_when bmd =
  let es = Bmd_to_wcs_entities.bmd_getentity_values bmd "entity" in
  workspace "rulebot-when"
    ~description: "Dialog to build the when part of a rule"
    ~entities: (entities bmd)
    ~intents: intents
    ~dialog_nodes: [ when_node;
                     prompt;
                     help es;
                     do_not_understand; ]
    ()
