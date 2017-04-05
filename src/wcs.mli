(**
   Watson Conversation Service API

   Based on the documentation available at:
   https://www.ibm.com/watson/developercloud/conversation/api/v1/

   Version 2017-02-03.
*)


open Wcs_t

exception Error of string

(** {6. Workspaces} *)

val list_workspaces : credential ->
  list_workspaces_request -> list_workspaces_response
(**
   List the workspaces associated with a Conversation service instance.
   [https://www.ibm.com/watson/developercloud/conversation/api/v1/#list_workspaces]
*)

val create_workspace : credential ->
  workspace -> create_response
(**
   Create a workspace on a Conversation service instance.
   [https://www.ibm.com/watson/developercloud/conversation/api/v1/#create_workspace]
*)

val message : credential ->
  string -> message_request -> message_response

val get_workspace : credential ->
  string -> workspace

val update_workspace : credential ->
  string -> workspace -> unit

val delete_workspace : credential ->
  string -> unit
