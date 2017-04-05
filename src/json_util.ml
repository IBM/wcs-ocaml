
let read_json_file reader f =
  begin try
    let lexstate = Yojson.init_lexer ~fname:f () in
    let ch = open_in f in
    let lexbuf = Lexing.from_channel ch in
    let json = reader lexstate lexbuf in
    close_in ch;
    json
  with
  | Yojson.Json_error err ->
      Log.error "Json_util" None
        ("Unable to parse file "^f^": "^err)
  | exn ->
      Log.error "Json_util" None
        ("Unable to read file "^f^": "^(Printexc.to_string exn))
  end


(** {6. Conversion functions} *)


(** {8. workspace_response} *)

let json_of_workspace_response rsp =
  Yojson.Basic.from_string (Wcs_j.string_of_workspace_response rsp)

let pretty_workspace_response rsp =
  Yojson.Basic.pretty_to_string (json_of_workspace_response rsp)


(** {8. pagination_response} *)

let json_of_pagination_response rsp =
  Yojson.Basic.from_string (Wcs_j.string_of_pagination_response rsp)

let pretty_pagination_response rsp =
  Yojson.Basic.pretty_to_string (json_of_pagination_response rsp)


(** {8. list_workspaces_request} *)

let json_of_list_workspaces_request req =
  Yojson.Basic.from_string (Wcs_j.string_of_list_workspaces_request req)

let pretty_list_workspaces_request req =
  Yojson.Basic.pretty_to_string (json_of_list_workspaces_request req)


(** {8. list_workspaces_response} *)

let json_of_list_workspaces_response rsp =
  Yojson.Basic.from_string (Wcs_j.string_of_list_workspaces_response rsp)

let pretty_list_workspaces_response rsp =
  Yojson.Basic.pretty_to_string (json_of_list_workspaces_response rsp)
