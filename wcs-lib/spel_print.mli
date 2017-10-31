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

(** Spel pretty-printers *)

(** {6 Top level printer for Spel expressions} *)
val to_string : Spel_t.expression -> string

(** {6 Top level printer for JSON with embedded Spel expressions} *)
val to_json : Spel_t.json_expression -> Json_t.json

(** {6 Auxiliary printer for text expressions} *)
val to_text : Spel_t.expression -> string

