open Wcs_t

let list_workspaces_request
    ?(version=`V_2017_02_03)
    ?(page_limit=100)
    ?(include_count=false)
    ?(sort=`Sort_workspace_id_incr)
    ?(cursor=None)
    ()
    : list_workspaces_request =
  { list_ws_req_version = version;
    list_ws_req_page_limit = page_limit;
    list_ws_req_include_count = include_count;
    list_ws_req_sort = sort;
    list_ws_req_cursor = cursor; }
