open Wcs_lib
open Wcs_t
module Mk = Wcs_builder

let jokes =
  [
    ("BrokenPencil", "Nevermind it's pointless");
    ("Boo", "Boohoohoo");
  ]

let entities name_list =
  [
    Mk.entity "name"
      ~values: (List.map (fun name -> (name,[])) name_list)
      ();
    Mk.entity "whoisthere"
      ~values: [("Who is there?",[])]
      ();
  ]


let mk_knock name answer =
  let knock =
    Mk.dialog_node ("KnockKnock "^name)
      ~conditions: ("@name:"^name)
      ~text: "Knock knock"
      ()
  in

  let whoisthere =
    Mk.dialog_node ("Whoisthere "^name)
      ~conditions: "@whoisthere"
      ~text: name
      ~parent: knock
      ()
  in

  let answer =
    Mk.dialog_node ("Answer "^name)
      ~conditions: ("@name:"^name)
      ~text: answer
      ~parent: whoisthere
      ~context: (Json.set_skip_user_input `Null true)
      ()
  in
  [knock; whoisthere; answer]

let simple_dispatch  =
  Mk.dialog_node "Dispatch"
    ~conditions: "true"
    ~text: "Enter a name"
    ()

let knockknock =
  Mk.workspace "Knock Knock"
    ~entities: (entities (List.map fst jokes))
    ~dialog_nodes:
      ((List.fold_left
          (fun acc x -> acc@mk_knock (fst x) (snd x))
          []
          jokes) @
       [ simple_dispatch ])
    ()

let () =
  print_endline
    (Wcs_json.pretty_workspace knockknock)
