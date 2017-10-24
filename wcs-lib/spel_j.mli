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

type ('a, 'b) result =
  | Ok of 'a
  | Error of 'b

(** {6 JSON serialization/deserialization for Spel expressions} *)
val expression_of_yojson : Json_t.safe -> (Spel_t.expression, string) result
val expression_to_yojson : Spel_t.expression -> Json_t.safe

(** {6 JSON serialization/deserialization for JSON with embedded Spel expressions} *)
val json_expression_of_yojson : Json_t.safe -> (Spel_t.json_expression, string) result
val json_expression_to_yojson : Spel_t.json_expression -> Json_t.safe

