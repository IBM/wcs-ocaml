open Wcs_t
open Spel_t
open Spel_util
module Mk = Wcs_builder
module Mk_spel = Spel_builder

let add_value entity value =
  { entity with e_def_values = value::entity.e_def_values }


let jokes = [
  ("Broken Pencil", "Nevermind it's pointless");
  ("Boo", "Boohoohoo");
]


let names_entity =
  Mk.entity "name"
    ~values: []
    ()

let whoisthere_entity =
  Mk.entity "whoisthere"
    ~values: [("Who is there?",[])]
    ()

let mk_knock names_entity (name, answer) =
  let value = Mk.value name () in
  let names_entity = add_value names_entity value in
  let knock =
    Mk.dialog_node ("KnockKnock "^name)
      ~conditions_spel: (Mk_spel.of_entity_def
                           names_entity
                           ~value:value
                           ())
      ~text: "Knock knock"
      ()
  in
  let whoisthere =
    Mk.dialog_node ("Whoisthere "^name)
      ~conditions_spel: (Mk_spel.of_entity_def
                           whoisthere_entity
                           ())
      ~text: name
      ~parent: knock
      ()
  in
  let answer =
    Mk.dialog_node ("Answer "^name)
      ~conditions_spel: (Mk_spel.of_entity_def
                           names_entity
                           ~value:value
                           ())
      ~text: answer
      ~parent: whoisthere
      ~context: (Json.set_skip_user_input `Null true)
      ()
  in
  (names_entity, [knock; whoisthere; answer])

let simple_dispatch  =
  Mk.dialog_node "Dispatch"
    ~conditions_spel: (Mk_spel.of_bool true)
    ~text: "Enter a name"
    ()

let knockknock =
  let names_entity, nodes =
    List.fold_left
      (fun (names_entity, acc) joke ->
         let names_entity, nodes = mk_knock names_entity joke in
         (names_entity, acc@nodes))
      (names_entity, []) jokes
  in
  Mk.workspace "Knock Knock"
    ~entities: [ names_entity; whoisthere_entity; ]
    ~dialog_nodes: (nodes @ [ simple_dispatch ])
    ()

let () =
  print_endline
    (Wcs_json.pretty_workspace knockknock)
