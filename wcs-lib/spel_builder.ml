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


(** {6 Spel data structure constructors} *)

open Spel_t
open Wcs_t

let condition_of_string s =
  Spel_parse.expression_from_string s

let output_of_string j =
  Spel_parse.json_expression_from_json j

let of_entity_def entity_def ?value () =
  begin match value with
  | None ->
      Spel_util.mk_expr (E_entity (entity_def.e_def_entity, None))
  | Some value ->
      if List.mem value (List.map (fun ev -> ev.e_val_value) entity_def.e_def_values)
      then
        Spel_util.mk_expr (E_entity (entity_def.e_def_entity, Some value))
      else
        Log.error "Spel builder" None ("Undefined entity: " ^  value)
  end

