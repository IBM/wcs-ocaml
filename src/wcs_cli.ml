type command =
  | Cmd_nothing
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
        "cred.json The file containing the Watson Conversation Service credentials";
        "-no-error-recovery", Arg.Unit unset_error_recovery,
        " Do not try to recover in case of error";
        "-debug", Arg.Unit set_debug,
        " Print dubg messages";
      ]

let anon_args = ref (fun s -> ())

(** {6. The [update] command} *)

let update_ws_fname = ref None

let update_ws_id = ref None
let set_update_ws_id id =
  update_ws_id := Some id

let update_speclist =
  Arg.align
    [ "-ws-id", Arg.String set_update_ws_id,
      "file The file containing the workspace identifiers";
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
  Sys.argv.(0)^" -wcs-cred credentials.json (create|update|rm|try) [options]"

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
  | Cmd_update -> update wcs_cred
  end;
  ()

let _ =
  main ()
