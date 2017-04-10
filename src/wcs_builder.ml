(*
 *  This file is part of the Watson Conversation Service OCaml API project.
 *
 * Copyright 2016-2017 IBM Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *)

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
