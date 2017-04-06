open Wcs_t
open Json_util

type command =
  | Cmd_nothing
  | Cmd_list
  | Cmd_create
  | Cmd_delete
  | Cmd_get
  | Cmd_update
  | Cmd_try

let cmd_name = Sys.argv.(0)

(** {6. The [list] command} *)

let list_page_limit = ref None
let set_list_page_limit n =
  list_page_limit := Some n

let list_include_count = ref None
let set_list_include_count b =
  list_include_count := Some b

let list_sort = ref None
let set_list_sort s =
  list_sort :=
    Some (Wcs_j.sort_criteria_of_string (Yojson.Basic.to_string (`String s)))

let list_cursor = ref None
let set_list_cursor s =
  list_cursor := Some s

let list_speclist =
  [ "-page_limit", Arg.Int set_list_page_limit,
    "n The number of records to return in each page of results.";
    "-include_count", Arg.Bool set_list_include_count,
    "b Whether to include information about the number of records returned.";
    "-sort", Arg.String set_list_sort,
    "attr The attribute by which returned results will be sorted. To reverse the sort order, prefix the value with a minus sign (-). Supported values are name, modified, and workspace_id.";
    "-cursor", Arg.String set_list_cursor,
    "token A token identifying the last value from the previous page of results.";
  ]

let list_anon_args s =
  Log.warning "Wcs_cli" ("ignored argument: " ^ s)


let list_usage =
  cmd_name^" -wcs-cred credentials.json list [options]"

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

let create_usage =
  cmd_name^" -wcs-cred credentials.json create [options] [workspace.json ...]"

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


(** {6. The [delete] command} *)

let delete_ws_ids = ref []

let delete_speclist =
  [ ]

let delete_anon_args s =
  delete_ws_ids := !delete_ws_ids @ [ s ]

let delete_usage =
  cmd_name^" -wcs-cred credentials.json delete [options] [workspace_id ...]"

let delete wcs_cred =
  List.iter
    (fun id ->
      Wcs.delete_workspace wcs_cred id;
      Format.printf "Workspace %s deleted@." id)
    !delete_ws_ids


(** {6. The [get] command} *)

let get_export = ref None
let set_get_export b =
  get_export := Some b

let get_ws_ids = ref []

let get_speclist =
  [ "-export", Arg.Bool set_get_export,
    "b Whether to include all element content in the returned data. The default value is false.";]

let get_anon_args s =
  get_ws_ids := !get_ws_ids @ [ s ]

let get_usage =
  cmd_name^" -wcs-cred credentials.json get [options] [workspace_id ...]"

let get wcs_cred =
  let workspaces =
    List.fold_left
      (fun acc id ->
        let req =
          Wcs_builder.get_workspace_request ?export:!get_export id
        in
        let ws = Wcs.get_workspace wcs_cred req in
        (json_of_workspace ws) :: acc)
      [] !get_ws_ids
  in
  begin match workspaces with
  | [ ws ] ->
      Format.printf "%s"
        (Yojson.Basic.pretty_to_string ws)
  | workspaces ->
      Format.printf "%s"
        (Yojson.Basic.pretty_to_string (`List (List.rev workspaces)))
  end


(** {6. The [update] command} *)

let update_ws_fname = ref None

let update_ws_id = ref None
let set_update_ws_id id =
  update_ws_id := Some id

let update_speclist =
  [ "-ws-id", Arg.String set_update_ws_id,
    "file The file containing the workspace identifiers.";
  ]

let update_anon_args =
  let first = ref true in
  begin fun s ->
    if !first then begin
      update_ws_fname := Some s;
      first := false
    end else begin
      Log.warning "Wcs_cli" ("ignored argument: " ^ s)
    end
  end

let update_usage =
  cmd_name^" -wcs-cred credentials.json get [options] -ws-id workspace_id workspace.json"

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
        (Arg.usage_string update_speclist usage)
  end


(** {6. The [try] command} *)

let try_context = ref `Null
let set_try_context fname =
  let ctx = assert false (* XXX TODO XXX *) in
  try_context := ctx

let try_text = ref ""
let set_try_text txt =
  try_text := ""

let try_node = ref None
let set_try_node b =
  try_node := Some b;
  assert false (* XXX TODO XXX *)

let try_ws_id = ref None

let try_speclist =
  [ "-context", Arg.Bool set_try_context,
    "ctx.json The initial context.";
    "-text", Arg.Bool set_try_text,
    "txt The initial user input.";
    "-node", Arg.Bool set_try_node,
    "node_id The node where to start the conversation.";
  ]

let try_anon_args =
  let first = ref true in
  begin fun s ->
    if !first then begin
      try_ws_id := Some s;
      first := false
    end else begin
      Log.warning "Wcs_cli" ("ignored argument: " ^ s)
    end
  end

let try_usage =
  cmd_name^" -wcs-cred credentials.json try [options] workspace_id"

let try_ wcs_cred =
  let ws_main_id =
    begin match !try_ws_id with
    | Some id -> id
    | None ->
        let usage =
          Format.sprintf "%s try: workspace id required"
            cmd_name
        in
        Log.error "Wcs_cli" None
          (Arg.usage_string update_speclist usage)
    end
  in
  ignore (Wcs_extra.get_value wcs_cred ws_main_id !try_context !try_text)


(** Select command *)

let wcs_credential : Wcs_t.credential option ref = ref None
let set_wcs_credential f =
  let cred = Json_util.read_json_file Wcs_j.read_credential f in
  wcs_credential := Some cred

let command = ref Cmd_nothing

let unset_error_recovery () =
  Log.error_recovery := false

let set_debug () =
  Log.debug_message := true


let speclist =
  [ "-wcs-cred", Arg.String set_wcs_credential,
    "cred.json The file containing the Watson Conversation Service credentials.";
    "-no-error-recovery", Arg.Unit unset_error_recovery,
    " Do not try to recover in case of error.";
    "-debug", Arg.Unit set_debug,
    " Print debug messages.";
  ]

let anon_args cmd =
  begin match cmd with
  | "list" ->
      command := Cmd_list;
      Arg.parse_argv Sys.argv
        (Arg.align (list_speclist @ speclist))
        list_anon_args
        list_usage
  | "create" ->
      command := Cmd_create;
      Arg.parse_argv Sys.argv
        (Arg.align (create_speclist @ speclist))
        create_anon_args
        create_usage
  | "delete" ->
      command := Cmd_delete;
      Arg.parse_argv Sys.argv
        (Arg.align (delete_speclist @ speclist))
        delete_anon_args
        delete_usage
  | "get" ->
      command := Cmd_get;
      Arg.parse_argv Sys.argv
        (get_speclist @ speclist)
        get_anon_args
        get_usage
  | "update" ->
      command := Cmd_update;
      Arg.parse_argv Sys.argv
        (Arg.align (update_speclist @ speclist))
        update_anon_args
        update_usage
  | "try" ->
      command := Cmd_try;
      Arg.parse_argv Sys.argv
        (try_speclist @ speclist)
        try_anon_args
        try_usage
  | _ ->
      let msg =
        Format.sprintf "'%s' is not a %s command" cmd cmd_name
      in
      raise (Arg.Bad msg)
  end

let usage =
  cmd_name^" -wcs-cred credentials.json (list | create | delete | get | update | try) [options]"

let main () =
  Arg.parse_argv Sys.argv speclist anon_args usage;
  let wcs_cred =
    begin match !wcs_credential with
    | Some ws_cred -> ws_cred
    | _ ->
        Arg.usage speclist ("Option -wcs-cred is required\n"^usage);
        exit 0
    end
  in
  begin match !command with
  | Cmd_nothing -> ()
  | Cmd_list -> list wcs_cred
  | Cmd_create -> create wcs_cred
  | Cmd_delete -> delete wcs_cred
  | Cmd_get -> get wcs_cred
  | Cmd_update -> update wcs_cred
  | Cmd_try -> try_ wcs_cred
  end;
  ()

let _ =
  begin try
    main ()
  with
  | Arg.Bad msg
  | Arg.Help msg ->
      Format.eprintf "%s@." msg;
      exit 0
  | Log.Error (module_name, msg) when not !Log.debug_message ->
      Format.eprintf "%s@." msg;
      exit 1
  end
