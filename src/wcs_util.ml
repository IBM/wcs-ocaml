let json_of_list_workspaces_response rsp =
  Yojson.Basic.from_string (Wcs_j.string_of_list_workspaces_response rsp)

let pretty_list_workspaces_response rsp =
  Yojson.Basic.pretty_to_string (json_of_list_workspaces_response rsp)
