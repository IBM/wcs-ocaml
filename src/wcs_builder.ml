open Wcs_t

let list_workspaces_request
    (* ?version *)
    ?page_limit
    ?include_count
    ?sort
    ?cursor
    ()
    : list_workspaces_request =
  { (* list_ws_req_version = version; *)
    list_ws_req_page_limit = page_limit;
    list_ws_req_include_count = include_count;
    list_ws_req_sort = sort;
    list_ws_req_cursor = cursor; }

let get_workspace_request ?export workspace_id =
  { get_ws_req_workspace_id = workspace_id;
    get_ws_req_export = export; }
