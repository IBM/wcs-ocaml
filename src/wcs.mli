(**
   Watson Conversation Service API

   Based on the documentation available at:
   https://www.ibm.com/watson/developercloud/conversation/api/v1/

   Version 2017-02-03.
*)


open Wcs_t

(** {6. Workspaces} *)

val list_workspaces : credential ->
  list_workspaces_request -> list_workspaces_response
(**
   [list_workspaces wcs_cred req]
   List the workspaces associated with a Conversation service instance.
   [https://www.ibm.com/watson/developercloud/conversation/api/v1/#list_workspaces]
*)

val create_workspace : credential ->
  workspace -> create_response
(**
   [create_workspace wcs_cred ws]
   Create a workspace on the Conversation service instance.
   [https://www.ibm.com/watson/developercloud/conversation/api/v1/#create_workspace]
*)

val delete_workspace : credential ->
  string -> unit
(**
   [delete_workspace wcs_cred ws_id]
   Delete a workspace from the Conversation service instance.
   [https://www.ibm.com/watson/developercloud/conversation/api/v1/#delete_workspace]
*)

val get_workspace : credential ->
  get_workspace_request -> workspace
(**
   [get_workspace wcs_cred req]
   Get information about a workspace, optionally including all
   workspace content.
   [https://www.ibm.com/watson/developercloud/conversation/api/v1/#get_workspace]
*)

val update_workspace : credential ->
  string -> workspace -> unit
(**
   [update_workspace wcs_cred ws_id ws]
   Update an existing workspace with new or modified data.
   [https://www.ibm.com/watson/developercloud/conversation/api/v1/#update_workspace]
*)


(** {6. Messages} *)

val message : credential ->
  string -> message_request -> message_response
(**
   [message wcs_cred ws_id req]
   Get a response to a user's input.
   [https://www.ibm.com/watson/developercloud/conversation/api/v1/#send_message]
*)
