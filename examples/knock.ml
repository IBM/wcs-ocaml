open Wcs_t
module Mk = Wcs

let add_value entity value =
  { entity with e_def_values = value::entity.e_def_values }

let spel_string_of_entity entity =
  "@" ^ entity.e_def_entity

let spel_string_of_entity_value entity value =
  "@" ^ entity.e_def_entity ^ ":(" ^ value.e_val_value ^ ")"


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
      ~conditions: (spel_string_of_entity_value names_entity value)
      ~text: "Knock knock"
      ()
  in
  let whoisthere =
    Mk.dialog_node ("Whoisthere "^name)
      ~conditions: (spel_string_of_entity whoisthere_entity)
      ~text: name
      ~parent: knock
      ()
  in
  let answer =
    Mk.dialog_node ("Answer "^name)
      ~conditions: (spel_string_of_entity_value names_entity value)
      ~text: answer
      ~parent: whoisthere
      ~context: (Json.set_skip_user_input `Null true)
      ()
  in
  (names_entity, [knock; whoisthere; answer])

let simple_dispatch  =
  Mk.dialog_node "Dispatch"
    ~conditions: "true"
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

let main () =
  let wcs_cred_file = ref None in
  let ws_id = ref None in
  let print = ref false in
  let deploy = ref false in
  let exec = ref false in
  let speclist =
    Arg.align
      [ "-cred", Arg.String (fun s -> wcs_cred_file := Some s),
        "cred.json The file containing the Watson Conversation Service credentials.";
        "-id", Arg.String (fun id -> ws_id := Some id),
        "id The workspace id used to update in conjunction with -deploy.";
        "-print", Arg.Set print,
        " Print the workspace on stdout.";
        "-deploy", Arg.Set deploy,
        " Create or update the workspace on Watson Conversation Service.";
        "-exec", Arg.Set exec,
        " Execute the chatbot."
      ]
  in
  let usage =
    "Usage: "^Sys.argv.(0)^" [options]"
  in
  Arg.parse speclist (fun _ -> ()) usage;
  let wcs_cred = Wcs_bot.get_credential !wcs_cred_file in
  begin match !print with
  | true ->
      print_endline (Wcs_json.pretty_workspace knockknock)
  | false ->
      ()
  end;
  begin match !deploy, !ws_id with
  | true, Some ws_id ->
      let () = Wcs_api.update_workspace wcs_cred ws_id knockknock in
      Format.printf "%s: updated@." ws_id
  | true, None ->
      begin match Wcs_api.create_workspace wcs_cred knockknock with
      | { crea_rsp_workspace_id = Some id } ->
          Format.printf "%s: created@." id;
          ws_id := Some id;
      | _ -> assert false
      end
  | false, _ -> ()
  end;
  begin match !exec, !ws_id with
  | true, Some id ->
      let _ = Wcs_bot.exec wcs_cred id `Null "" in
      ()
  | false, _ ->
      ()
  | true, None ->
      Arg.usage speclist "no worksapce to execute";
      exit 1
  end

let _ =
  begin try
    main ()
  with
  | Log.Error (module_name, msg) when not !Log.debug_message ->
      Format.eprintf "%s@." msg;
      exit 1
  end
