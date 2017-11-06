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

type json_spel = Spel_t.json_expression

(** {6. Utils} *)

let null : json_spel = `Null

let set (ctx: json_spel) (lbl: string) (v: json_spel) : json_spel =
  begin match ctx with
  | `Null -> `Assoc [ lbl, v ]
  | `Assoc l -> `Assoc ((lbl, v) :: (List.remove_assoc lbl l))
  | _ ->
      Log.error "Json_spel"
        (Some ctx)
        "Unable to add a property to a non-object value"
  end

let take (ctx: json_spel) (lbl: string) : json_spel * json_spel option =
  begin match ctx with
  | `Assoc l ->
      begin try
        let v = List.assoc lbl l in
        `Assoc (List.remove_assoc lbl l), Some v
      with Not_found ->
        ctx, None
      end
  | _ -> ctx, None
  end

let get (ctx: json_spel) (lbl: string) : json_spel option =
  begin match ctx with
  | `Assoc l ->
      begin try
        Some (List.assoc lbl l)
      with Not_found ->
        None
      end
  | _ ->  None
  end

let assign (os: json_spel list) : json_spel =
  List.fold_left (fun acc o ->
    begin match o with
    | `Assoc l ->
        List.fold_right
          (fun (lbl, v) acc -> set acc lbl v)
          l acc
    | _ ->
        Log.error "Json" (Some acc) ""
    end)
    null os

(** {6. skip_user_input} *)

let set_skip_user_input (ctx: json_spel) (b: bool) : json_spel =
  set ctx "skip_user_input" (`Bool b)

let take_skip_user_input (ctx: json_spel) : json_spel * bool =
  begin match take ctx "skip_user_input" with
  | ctx, Some (`Bool b) -> ctx, b
  | _ -> ctx, false
  end


(** {6. Actions} *)

let json_spel_of_action (act : action) : json_spel =
  let json = Wcs_json.json_of_action act in
  let json_spel = Spel_parse.json_expr_from_json json in
  json_spel

let action_of_json_spel (act : json_spel) : action =
  Wcs_j.action_of_string (Yojson.Basic.to_string (Spel_print.to_json act))

let set_actions ctx (acts: action list) : json_spel =
  let js_acts = List.map json_spel_of_action acts in
  set ctx "actions" (`List js_acts)

let take_actions (ctx: json_spel) : json_spel * action list option =
  begin match take ctx "actions" with
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
  set ctx "continuation" (json_spel_of_action k)

let take_continuation (ctx: json_spel) : json_spel * action option =
  begin match take ctx "continuation" with
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
  set ctx "return" x

let get_return (ctx: json_spel) : json_spel option =
  get ctx "return"

(** {6. Bool} *)

let set_bool (ctx: json_spel) (lbl: string) (b: bool) : json_spel =
  set ctx lbl (`Bool b)

(* let get_bool (ctx: json_spel) (lbl: string) : bool option =
   begin match Yojson.Basic.Util.member lbl ctx with
   | `Bool b -> Some b
   | _ -> None
   end *)

(** {6. String} *)

let set_string (ctx: json_spel) (lbl: string) (s: string) : json_spel =
  set ctx lbl (`Expr (Spel.string s))

(* let get_string (ctx: json_spel) (lbl: string) : string option =
   begin match get ctx lbl with
   | Some (`String s) -> Some s
   | _ -> None
   end *)

(* let take_string (ctx: json_spel) (lbl: string) : json_spel * string option =
   begin match take ctx lbl with
   | ctx, Some (`String s) -> ctx, Some s
   | ctx, _ -> ctx, None
   end *)

