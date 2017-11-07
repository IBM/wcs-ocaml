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

(** Context utilities. *)

open Wcs_t


(** {6. skip_user_input} *)

let set_skip_user_input (ctx: json_spel) (b: bool) : json_spel =
  Json_spel.set ctx "skip_user_input" (`Bool b)

let take_skip_user_input (ctx: json_spel) : json_spel * bool =
  begin match Json_spel.take ctx "skip_user_input" with
  | ctx, Some (`Bool b) -> ctx, b
  | _ -> ctx, false
  end


(** {6. Actions} *)

let json_spel_of_action (act : action) : json_spel =
  let json = Json.of_action act in
  let json_spel = Spel_parse.json_expr_from_json json in
  json_spel

let action_of_json_spel (act : json_spel) : action =
  Wcs_j.action_of_string (Yojson.Basic.to_string (Spel_print.to_json act))

let set_actions ctx (acts: action list) : json_spel =
  let js_acts = List.map json_spel_of_action acts in
  Json_spel.set ctx "actions" (`List js_acts)

let take_actions (ctx: json_spel) : json_spel * action list option =
  begin match Json_spel.take ctx "actions" with
  | ctx', Some (`List acts) ->
      begin try
        ctx', Some (List.map action_of_json_spel acts)
      with _ ->
        Log.warning "Json"
          (Format.sprintf "illed formed actions:\n%s@."
             (Yojson.Basic.pretty_to_string (Spel_print.to_json (`List acts))));
        ctx, None
      end
  | _, Some o ->
      Log.warning "Json"
        (Format.sprintf "illed formed actions:\n%s@."
           (Yojson.Basic.pretty_to_string (Spel_print.to_json o)));
      ctx, None
  | _, None ->
      ctx, None
  end

let push_action (ctx: json_spel) (act: action) : json_spel =
  begin match take_actions ctx with
  | ctx, None ->
      set_actions ctx [ act ]
  | ctx, Some acts ->
      set_actions ctx (acts @ [ act ])
  end

let pop_action (ctx: json_spel) : json_spel * action option =
  begin match take_actions ctx with
  | ctx', Some (act :: acts) ->
      set_actions ctx' acts, Some act
  | _ -> ctx, None
  end

(** {6. Continuation} *)

let set_continuation (ctx: json_spel) (k: action) : json_spel =
  Json_spel.set ctx "continuation" (json_spel_of_action k)

let take_continuation (ctx: json_spel) : json_spel * action option =
  begin match Json_spel.take ctx "continuation" with
  | ctx', Some act ->
      begin try
        ctx', Some (action_of_json_spel act)
      with _ ->
        Log.warning "Json"
          (Format.sprintf "illed formed continuation:\n%s@."
             (Yojson.Basic.pretty_to_string (Spel_print.to_json act)));
        ctx, None
      end
  | _ -> ctx, None
  end

let get_continuation (ctx: json_spel) : action option =
  let _, act = take_continuation ctx in
  act


(** {6. Return} *)

let set_return (ctx: json_spel) (x: json_spel) : json_spel =
  Json_spel.set ctx "return" x

let get_return (ctx: json_spel) : json_spel option =
  Json_spel.get ctx "return"
