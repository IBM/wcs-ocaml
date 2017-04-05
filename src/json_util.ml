
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


(** {8. intent_example} *)

let json_of_intent_example x =
  Yojson.Basic.from_string (Wcs_j.string_of_intent_example x)

let pretty_intent_example x =
  Yojson.Basic.pretty_to_string (json_of_intent_example x)


(** {8. intent_def} *)

let json_of_intent_def x =
  Yojson.Basic.from_string (Wcs_j.string_of_intent_def x)

let pretty_intent_def x =
  Yojson.Basic.pretty_to_string (json_of_intent_def x)


(** {8. entity_value} *)

let json_of_entity_value x =
  Yojson.Basic.from_string (Wcs_j.string_of_entity_value x)

let pretty_entity_value x =
  Yojson.Basic.pretty_to_string (json_of_entity_value x)


(** {8. entity_def} *)

let json_of_entity_def x =
  Yojson.Basic.from_string (Wcs_j.string_of_entity_def x)

let pretty_entity_def x =
  Yojson.Basic.pretty_to_string (json_of_entity_def x)


(** {8. go_to} *)

let json_of_go_to x =
  Yojson.Basic.from_string (Wcs_j.string_of_go_to x)

let pretty_go_to x =
  Yojson.Basic.pretty_to_string (json_of_go_to x)


(** {8. output_def} *)

let json_of_output_def x =
  Yojson.Basic.from_string (Wcs_j.string_of_output_def x)

let pretty_output_def x =
  Yojson.Basic.pretty_to_string (json_of_output_def x)


(** {8. dialog_node} *)

let json_of_dialog_node x =
  Yojson.Basic.from_string (Wcs_j.string_of_dialog_node x)

let pretty_dialog_node x =
  Yojson.Basic.pretty_to_string (json_of_dialog_node x)


(** {8. workspace} *)

let json_of_workspace x =
  Yojson.Basic.from_string (Wcs_j.string_of_workspace x)

let pretty_workspace x =
  Yojson.Basic.pretty_to_string (json_of_workspace x)


(** {8. input} *)

let json_of_input x =
  Yojson.Basic.from_string (Wcs_j.string_of_input x)

let pretty_input x =
  Yojson.Basic.pretty_to_string (json_of_input x)


(** {8. entity} *)

let json_of_entity x =
  Yojson.Basic.from_string (Wcs_j.string_of_entity x)

let pretty_entity x =
  Yojson.Basic.pretty_to_string (json_of_entity x)


(** {8. output} *)

let json_of_output x =
  Yojson.Basic.from_string (Wcs_j.string_of_output x)

let pretty_output x =
  Yojson.Basic.pretty_to_string (json_of_output x)


(** {8. message_request} *)

let json_of_message_request x =
  Yojson.Basic.from_string (Wcs_j.string_of_message_request x)

let pretty_message_request x =
  Yojson.Basic.pretty_to_string (json_of_message_request x)


(** {8. message_response} *)

let json_of_message_response x =
  Yojson.Basic.from_string (Wcs_j.string_of_message_response x)

let pretty_message_response x =
  Yojson.Basic.pretty_to_string (json_of_message_response x)


(** {8. create_response} *)

let json_of_create_response x =
  Yojson.Basic.from_string (Wcs_j.string_of_create_response x)

let pretty_create_response x =
  Yojson.Basic.pretty_to_string (json_of_create_response x)


(* (\** {8. action} *\) *)

(* let json_of_action x = *)
(*   Yojson.Basic.from_string (Wcs_j.string_of_action x) *)

(* let pretty_action x = *)
(*   Yojson.Basic.pretty_to_string (json_of_action x) *)

