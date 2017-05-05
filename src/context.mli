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

val null : json

val set : json -> string -> json -> json
val take : json -> string -> json * json option
val get : json -> string -> json option

val set_skip_user_input : json -> bool -> json
val take_skip_user_input : json -> json * bool

val set_actions : json -> action list -> json
val take_actions : json -> json * action list option

val push_action : json -> action -> json
val pop_action : json -> json * action option

val set_continuation : json -> action -> json
val get_continuation : json -> action option
val take_continuation : json -> json * action option

val set_return : json -> json -> json
val get_return : json -> json option

val set_bool : json -> string -> bool -> json
val get_bool : json -> string -> bool option

val set_string : json -> string -> string -> json
val get_string : json -> string -> string option
val take_string : json -> string -> json * string option
