open Wcs_lib
open Wcs_t
module Mk = Wcs_builder

let jokes =
  [
    ("BrokenPencil", "Nevermind it's pointless");
    ("Boo", "Boohoohoo")
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
      ~conditions: "conversation_start"
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
      ()
  in
  [knock; whoisthere; answer]

let knockknock =
  Mk.workspace "Knock Knock"
    ~entities: (entities (List.map fst jokes))
    ~dialog_nodes: (List.fold_left (fun acc x -> acc@mk_knock (fst x) (snd x)) [] jokes)
    ()

let () =
  print_endline
    (Wcs_json.pretty_workspace knockknock)