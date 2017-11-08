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
    ~context: (Context.set_expr `Null "expr" Cnl_samples.expr1)
    ()

let expr2 =
  dialog_node "expr2"
    ~parent: select_example
    ~conditions: "@sys-number == 2"
    ~text: "Here is the expression 2."
    ~context: (Context.set_expr `Null "expr" Cnl_samples.expr2)
    ()

let expr_unknown =
  dialog_node "expr unknown"
    ~parent: select_example
    ~text: "Sorry there is no example @sys-number."
    ()

let anything_else =
  dialog_node "Anything else"
    ~text: "Tell me which expression you would like."
    ~conditions: "anything_else"
    ()

let ws_select_expr =
  workspace "rulebot-select-expr"
    ~description: "Dialog to select an expression"
    ~entities: entities
    ~intents: intents
    ~dialog_nodes: [ select_example;
                     expr1;
                     expr2;
                     expr_unknown;
                     anything_else ]
    ()
