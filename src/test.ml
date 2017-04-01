
let wcs_credential : Wcs_t.credential option ref = ref None
let set_wcs_credential f =
  let cred = Json_util.read_json_file Wcs_j.read_credential f in
  wcs_credential := Some cred

let ws_ids : Wcs_t.json option ref = ref None
let set_ws_ids f =
  ws_ids := Some (Yojson.Basic.from_file ~fname:f f)

let ws_main_name = ref ""

let args =
  Arg.align
    [ ("-wcs-cred", Arg.String set_wcs_credential,
       "file The file containing the Watson Conversation Service credentials");
      ("-ws-ids", Arg.String set_ws_ids,
       "file The file containing the workspace identifiers");
   ]

let anon_args s =
  if !ws_main_name = "" then ws_main_name := s
  else raise (Failure "expects one argument")

let usage = Sys.argv.(0)^" [options] -wcs-cred credentials.json -ws-ids workspaces.json main"

let main () =
  Arg.parse args anon_args usage;
  begin match !wcs_credential, !ws_ids with
  | Some ws_cred, Some ws_ids ->
      let ws_main_id =
        ws_ids |>
        Yojson.Basic.Util.member !ws_main_name |>
        Yojson.Basic.Util.to_string
      in
      Wcs_extra.get_value ws_cred ws_main_id ws_ids ""
  | _ ->
      Arg.usage args ("Options -wcs-cred and -ws-ids are required\n"^usage);
      exit 0
  end

let _ =
  main ()
