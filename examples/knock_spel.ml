open Wcs_t
module WCS = Wcs_builder
module Spel = Spel_builder

let who_intent =
  WCS.intent "Who"
    ~description: "The user wants to know who is knocking at the door"
    ~examples: [
      "Who's there?";
      "Who is there?";
      "Who are you?";
    ]
    ()

let entity_name =
  WCS.entity "BrokenPencil"
    ~values: ["Broken Pencil", ["Dammaged Pen"; "Fractured Pencil"]]
    ()

let entity_value entity =
  begin match entity.e_def_values with
  | value::_ -> value.e_val_value
  | _ -> "Unknown"
  end

let knock who_intent name_entity answer =
  let knock =
    WCS.dialog_node ("KnockKnock")
      ~conditions_spel: (Spel.bool true)
      ~text: "Knock knock"
      ()
  in
  let whoisthere =
    WCS.dialog_node ("Who")
      ~conditions_spel: (Spel.intent who_intent)
      ~text: (entity_value name_entity)
      ~parent: knock
      ()
  in
  let answer =
    WCS.dialog_node ("Answer")
      ~conditions_spel: (Spel.entity name_entity ())
      ~text: answer
      ~parent: whoisthere
      ~context: (Json.set_skip_user_input `Null true)
      ()
  in
  [knock; whoisthere; answer]

let knockknock =
  WCS.workspace "Knock Knock"
    ~entities: [ entity_name ]
    ~intents: [who_intent]
    ~dialog_nodes: (knock who_intent entity_name "Nevermind it's pointless")
    ()

let () =
  print_endline
    (Wcs_json.pretty_workspace knockknock)
