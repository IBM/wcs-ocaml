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


(** Spel data structure constructors *)

open Spel_t
open Wcs_t

(** {6 from OCaml types} *)

let of_string s = Spel_parse.expr_from_string s

let of_text s = Spel_parse.quoted_expr_from_string s

let of_json j = Spel_parse.json_expr_from_json j

let entity entity_def ?value () =
  begin match value with
  | None ->
      Spel_util.mk_expr (E_entity (entity_def.e_def_entity, None))
  | Some value_def ->
      let value = value_def.e_val_value in
      if List.mem value (List.map (fun ev -> ev.e_val_value) entity_def.e_def_values)
      then
        Spel_util.mk_expr (E_entity (entity_def.e_def_entity, Some value))
      else
        Log.error "Spel builder" None ("Undefined entity: " ^  value)
  end

let intent intent_def =
  Spel_util.mk_expr (E_intent intent_def.i_def_intent)

let bool b =
  Spel_util.mk_expr (E_lit (L_boolean b))

(** {6 other constructors} *)

let conversation_start =
  Spel_util.mk_expr E_conversation_start

let anything_else =
  Spel_util.mk_expr E_anything_else

(** {6 Spel checker *)

let spel_check s =
  let e = of_string s in
  Spel_print.to_string e

