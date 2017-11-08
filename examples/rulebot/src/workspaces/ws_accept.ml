open Wcs

let entities = [
  Ws_common.entity_yes;
  Ws_common.entity_no
]

let intents = []

let question =
  dialog_node "Question"
    ~text: "Do you accept the $kind $n?"
    ()

let yes =
  dialog_node "Yes"
    ~parent: question
    ~text: "The $kind is confirmed."
    ~context: (`Assoc ["accept", `Bool true])
    ~conditions: "@yes"
    ()

let no =
  dialog_node "No"
    ~parent: question
    ~conditions: "@no"
    ~text: "The $kind is rejected."
    ~context: (`Assoc ["accept", `Bool false])
    ()

let ws_accept =
  workspace "rulebot-accept"
    ~description: "Dialog to get confirmation from the user"
    ~entities: entities
    ~intents: intents
    ~dialog_nodes: [ question; yes; no; Ws_common.anything_else; ]
    ()
