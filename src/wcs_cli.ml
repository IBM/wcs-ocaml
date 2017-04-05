open Wcs_t

type command =
  | Cmd_nothing
  | Cmd_list
  | Cmd_create
  | Cmd_update

let wcs_credential : Wcs_t.credential option ref = ref None
let set_wcs_credential f =
  let cred = Json_util.read_json_file Wcs_j.read_credential f in
  wcs_credential := Some cred

(** {6. Main command} *)

let cmd_name = Sys.argv.(0)

let command = ref Cmd_nothing

let unset_error_recovery () =
  Log.error_recovery := false

let set_debug () =
  Log.debug_message := true


let speclist =
  ref [ "-wcs-cred", Arg.String set_wcs_credential,
        "cred.json The file containing the Watson Conversation Service credentials.";
        "-no-error-recovery", Arg.Unit unset_error_recovery,
        " Do not try to recover in case of error.";
        "-debug", Arg.Unit set_debug,
        " Print debug messages.";
      ]

let anon_args = ref (fun s -> ())

(** {6. The [list] command} *)

let list_page_limit = ref None
let set_list_page_limit n =
  list_page_limit := Some n

let list_include_count = ref None
let set_list_include_count b =
  list_include_count := Some b

let list_sort = ref None
let set_list_sort s =
  list_sort := Some (Wcs_j.sort_criteria_of_string (Yojson.Basic.to_string (`String s)))

let list_cursor = ref None
let set_list_cursor s =
  list_cursor := Some (Some s)

let list_speclist =
  [ "-page_limit", Arg.Int set_list_page_limit,
    "n The number of records to return in each page of results.";
    "-include_count", Arg.Bool set_list_include_count,
    "b Whether to include information about the number of records returned.";
    "-sort", Arg.String set_list_sort,
    "The attribute by which returned results will be sorted. To reverse the sort order, prefix the value with a minus sign (-). Supported values are name, modified, and workspace_id.";
    "-cursor", Arg.String set_list_cursor,
    "A token identifying the last value from the previous page of results.";
  ]

let list_anon_args s =
  Log.warning "Wcs_cli" ("ignored argument: " ^ s)

let list wcs_cred =
  let req =
    Wcs_builder.list_workspaces_request
      ?page_limit:!list_page_limit
      ?include_count:!list_include_count
      ?sort:!list_sort
      ?cursor:!list_cursor
      ()
  in
  let rsp = Wcs.list_workspaces wcs_cred req in
  Format.printf "%s@." (Json_util.pretty_list_workspaces_response rsp)

(** {6. The [create] command} *)

let create_ws_fnames = ref []

let create_speclist = []

let create_anon_args s =
  create_ws_fnames := !create_ws_fnames @ [ s ]

let create wcs_cred =
  List.iter
    (fun fname ->
      let ws =
        Json_util.read_json_file Wcs_j.read_workspace fname
      in
      let rsp = Wcs.create_workspace wcs_cred ws in
      let name =
        begin match rsp.crea_rsp_name with
        | Some name -> name
        | None -> "?"
        end
      in
      let ws_id =
        begin match rsp.crea_rsp_workspace_id with
        | Some id -> id
        | None -> "?"
        end
      in
      Format.printf "Workspace %s: %s@." name ws_id)
    !create_ws_fnames


(** {6. The [update] command} *)

let update_ws_fname = ref None

let update_ws_id = ref None
let set_update_ws_id id =
  update_ws_id := Some id

let update_speclist =
  [ "-ws-id", Arg.String set_update_ws_id,
    "file The file containing the workspace identifiers.";
  ]

let update_anon_args s =
  anon_args := (fun s -> Log.warning "Wcs_cli" ("ignored argument: " ^ s));
  update_ws_fname := Some s

let update wcs_cred =
  begin match !update_ws_id, !update_ws_fname with
  | Some id, Some fname ->
      let ws =
        Json_util.read_json_file Wcs_j.read_workspace fname
      in
      Wcs.update_workspace wcs_cred id ws
  | _ ->
      let usage =
        Format.sprintf "%s update: workspace id and workspace file required"
          cmd_name
      in
      Log.error "Wcs_cli" (Some ())
        (Arg.usage_string !speclist usage)
  end

(** Select command *)

let set_command cmd =
  begin match cmd with
  | "list" ->
      command := Cmd_list;
      speclist := Arg.align (list_speclist @ !speclist);
      anon_args := list_anon_args
  | "create" ->
      command := Cmd_create;
      speclist := Arg.align (create_speclist @ !speclist);
      anon_args := create_anon_args
  | "update" ->
      command := Cmd_update;
      speclist := Arg.align (update_speclist @ !speclist);
      anon_args := update_anon_args
  | _ ->
      let msg =
        Format.sprintf "'%s' is not a %s command" cmd cmd_name
      in
      raise (Arg.Bad msg)
  end

let () = anon_args := set_command

let anon_args s = !anon_args s

let usage =
  Sys.argv.(0)^" -wcs-cred credentials.json (list | create | update | rm | try) [options]"

let main () =
  Arg.parse_dynamic speclist anon_args usage;
  let wcs_cred =
    begin match !wcs_credential with
    | Some ws_cred -> ws_cred
    | _ ->
        Arg.usage !speclist ("Option -wcs-cred is required\n"^usage);
        exit 0
    end
  in
  begin match !command with
  | Cmd_nothing -> ()
  | Cmd_list -> list wcs_cred
  | Cmd_create -> create wcs_cred
  | Cmd_update -> update wcs_cred
  end;
  ()

let _ =
  begin try
    main ()
  with Log.Error (module_name, msg) ->
    Format.eprintf "%s@." msg;
    exit 1
  end
