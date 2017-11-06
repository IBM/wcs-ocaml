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

(** Json utilities. *)

open Wcs_t

type json_spel = Spel_t.json_expression

val null : json_spel
(** The [null] value of JSON. *)

val set : json_spel -> string -> json_spel -> json_spel
(**
   [set o x v] add (or replace) the a field [x] of the object [o] with
   value [v].
*)

val get : json_spel -> string -> json_spel option
(**
   [get o x] gets the value of the field [x] of the object [o].
*)

val take : json_spel -> string -> json_spel * json_spel option
(**
   [take o x] gets the value of the field [x] of the object [o] and
   remove the field from the object. The left part of the return value
   is the modified object and the right part is the value of the
   field.
*)


val assign : json_spel list -> json_spel
(**
   [assign [o1; ...; on]] create a json object that contains all the
   fields of the objets [o1], ..., [on]. It is similare the the JavaScript
   function [Object.assing({}, o1, ... on)].
*)


(** {8 The ["skip_user_input"] field} *)

val set_skip_user_input : json_spel -> bool -> json_spel
(**
   [set_skip_user_input ctx b] set the field ["skip_user_input"] of
   the object [ctx] with value [b].
*)

val take_skip_user_input : json_spel -> json_spel * bool
(**
   [take_skip_user_input ctx] take the field ["skip_user_input"] of
   the object [ctx]. If the field is the defined, it returns [false].
*)


(** {8 The ["actions"] field} *)

val set_actions : json_spel -> action list -> json_spel
(**
   [set_actions ctx l] set the field ["actions"] of
   the object [ctx] with the list of actions [l].
*)

val take_actions : json_spel -> json_spel * action list option
(**
   [take_actions ctx] take the field ["actions"] of the object
   [ctx].
*)

val push_action : json_spel -> action -> json_spel
(**
   [push_action ctx act] add the action [act] in the list of actions
   stored in the field ["actions"] of ctx. It the field ["actions"]
   doesn't exists, it creates it.
*)

val pop_action : json_spel -> json_spel * action option
(**
   [pop_action ctx] take an action [act] in the list of actions
   stored in the field ["actions"] of ctx.
*)


(** {8 The ["continuation"] field} *)

val set_continuation : json_spel -> action -> json_spel
(**
   [set_continuation ctx act] set the field ["continuation"] of
   the object [ctx] with the action [act].
*)

val get_continuation : json_spel -> action option
(**
   [get_continuation ctx] get the value of the field ["continuation"]
   of the object [ctx].
*)

val take_continuation : json_spel -> json_spel * action option
(**
   [take_continuation ctx] take the value of the field ["continuation"]
   of the object [ctx].
*)


(** {8 The ["return"] field} *)

val set_return : json_spel -> json_spel -> json_spel
(**
   [set_return ctx v] set the field ["return"] of
   the object [ctx] with the value [v].
*)

val get_return : json_spel -> json_spel option
(**
   [get_return ctx] get the value of the field ["return"]
   of the object [ctx].
*)


(** {8 Boolean fields} *)

val set_bool : json_spel -> string -> bool -> json_spel
(**
   [set_bool o x b] sets the a field [x] of the object [o] with value
   [b].
*)

(* val get_bool : json_spel -> string -> bool option *)
(**
   [get_bool o x] gets the value of the field [x] of the object [o].
*)

(** {8 String fields} *)

val set_string : json_spel -> string -> string -> json_spel
(**
   [set_string o x x] sets the a field [x] of the object [o] with string
   [s].
*)

(* val get_string : json_spel -> string -> string option *)
(**
   [get_string o x] gets the value of the field [x] of the object [o].
*)

(* val take_string : json_spel -> string -> json_spel * string option *)
(**
   [take_string o x] takes the value of the field [x] of the object [o].
*)
