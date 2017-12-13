open Wcs_lib
open Wcs_api_jsoo
open Wcs_t

let wcs_cred =
  { cred_url = "https://gateway.watsonplatform.net/conversation/api";
    cred_password = "obhtfR3GTKkg";
    cred_username = "bafe8241-9886-4d0a-b1e3-e2d10d8c8981"; }


let _ =
  let id = "1938f25a-2786-496d-8910-d3b8f89cdf5c" in
  (* Wcs_bot.exec wcs_cred id Json.null "" *)
  let ws = Wcs_call.get_workspace wcs_cred (Wcs.get_workspace_request id) in
  begin match ws.ws_name with
  | None -> print_endline "no name"
  | Some x -> print_endline x
  end;
  ()

let x = print_endline "from ocaml"
