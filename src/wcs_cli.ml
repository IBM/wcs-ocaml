let wcs_credential : Wcs_t.credential option ref = ref None
let set_wcs_credential f =
  let cred = Json_util.read_json_file Wcs_j.read_credential f in
  wcs_credential := Some cred

let args =
  Arg.align
    [ ("-wcs-cred", Arg.String set_wcs_credential,
       "cred.json The file containing the Watson Conversation Service credentials");
    ]

let anon_args s =
  Log.warning "Wcs_cli" ("ignored argument: " ^ s)

let usage =
  Sys.argv.(0)^" -wcs-cred credentials.json [options]"

let main () =
  Arg.parse args anon_args usage;
  let ws_cred =
    begin match !wcs_credential with
    | Some ws_cred -> ws_cred
    | _ ->
        Arg.usage args ("Option -wcs-cred is required\n"^usage);
        exit 0
    end
  in
  ()

let _ =
  main ()
