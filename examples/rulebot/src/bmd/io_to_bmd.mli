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

open Bmd_t

val bmd_concept_of_entity : bmd_concept_name -> bmd_concept
val bmd_concept_of_brand :
  bmd_concept_name list -> bmd_concept list
val process_brandTypes : Io_t.brand_type list -> string list
val bmd_concepts_of_io : Io_t.io -> bmd_concept list
val bmd_of_io : Io_t.io -> bmd_schema
