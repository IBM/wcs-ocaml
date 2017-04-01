open Wcs_t

val example :
  string -> ?created:string -> unit -> intent_example

val intent :
  string ->
  ?description:string ->
  ?examples:string list ->
  ?created:string ->
    unit -> intent_def

val value :
  string ->
  ?metadata:json ->
  ?synonyms:string list ->
  ?created:string ->
    unit -> entity_value

val entity :
  string ->
  ?metadata:string ->
  ?source:string ->
  ?open_list:bool ->
  ?values:(string * string list) list ->
  ?created:string ->
    unit -> entity_def

type selector = User_input | Condition | Body

val go_to :
  dialog_node ->
  ?return:bool ->
  selector:selector ->
    unit -> go_to

val go_to_id :
  string ->
  ?return:bool ->
  selector:selector ->
    unit -> go_to

val output : string -> output_def

val dialog_node :
  string ->
  ?description:string ->
  ?conditions:string ->
  ?parent:dialog_node ->
  ?previous_sibling:dialog_node ->
  ?text:string ->
  ?output:output_def ->
  ?context:json ->
  ?metadata:json ->
  ?go_to:dialog_node * selector ->
  ?go_to_id:string * selector ->
  ?created:string ->
    unit -> dialog_node

val setNodeParent : Wcs_t.dialog_node option -> Wcs_t.dialog_node -> Wcs_t.dialog_node
val setNodeParentIfNone : Wcs_t.dialog_node option -> Wcs_t.dialog_node -> Wcs_t.dialog_node

val updateNodeName : (string -> string) -> Wcs_t.dialog_node -> Wcs_t.dialog_node
val getNodeName : Wcs_t.dialog_node -> string

val workspace :
  string ->
  ?description:string ->
  ?language:string ->
  ?metadata:json ->
  ?counterexamples:string list ->
  ?dialog_nodes:dialog_node list ->
  ?entities:entity_def list ->
  ?intents:intent_def list ->
  ?created:string ->
  ?modified:string ->
  ?created_by:string ->
  ?modified_by:string ->
  ?workspace_id:string ->
    unit -> workspace

val sys_number : entity_def
