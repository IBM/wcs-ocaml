open Wcs_aux
open Wcs
open Cnl_util

let intents = []
let entities = [
 sys_number
]

let select_example =
  dialog_node "Select example"
    ~conditions: "@sys-number"
    ~next_step_id: ("expr1", Goto_condition)
    ()

let expr1 =
  dialog_node "expr1"
    ~parent: select_example
    ~conditions: "@sys-number == 1"
    ~text: "Here is the expression 1."
    ~context: (Context.set_rule `Null "rule" Cnl_samples.rule1)
    ()

let expr2 =
  dialog_node "expr2"
    ~parent: select_example
    ~conditions: "@sys-number == 2"
    ~text: "Here is the expression 2."
    ~context: (Context.set_rule `Null "rule" Cnl_samples.rule2)
    ()

let expr_unknown =
  dialog_node "expr unknown"
    ~parent: select_example
    ~text: "Sorry there is no example @sys-number."
    ()

let anything_else =
  dialog_node "Anything else"
    ~conditions: "anything_else"
    ~text: "Tell me which example you would like."
    ()

let ws_select_example =
  workspace "rulebot-select-example"
    ~description: "Dialog to select an example expression"
    ~entities: entities
    ~intents: intents
    ~dialog_nodes: [ select_example;
                     expr1;
                     expr2;
                     expr_unknown;
                     anything_else; ]
    ()
