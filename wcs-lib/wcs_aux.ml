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

type selector =
  | Goto_user_input
  | Goto_condition
  | Goto_body

let selector_wrap s =
  begin match s with
  | "user_input" | "client" -> Goto_user_input
  | "condition" -> Goto_condition
  | "body" -> Goto_body
  | _ -> Log.error "Wcs_aux" (Some Goto_user_input) ("bad selector: "^s)
  end

let selector_unwrap s =
  begin match s with
  | Goto_user_input -> "user_input"
  | Goto_condition -> "condition"
  | Goto_body -> "body"
  end
