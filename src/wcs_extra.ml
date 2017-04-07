open Wcs_t

let pretty_json_string s =
  (Yojson.Basic.pretty_to_string (Yojson.Basic.from_string s))

let bypass_default (txt: string) : (bool * 'a) option =
  None

let before_default (msg_req: message_request) : message_request =
  msg_req

let after_default (msg_resp: message_response) : message_response =
  msg_resp

let user_input_default () =
  print_string "H: "; flush stdout;
  input_line stdin

let matcher_default (msg_resp: message_response) : 'a option =
  None

(* type step = Step of (json -> string -> json * step) *)

(* let interpret *)
(*     ?(bypass=bypass_default) *)
(*     ?(before=before_default) *)
(*     ?(after=after_default) *)
(*     ?(matcher=matcher_default) *)
(*     (wcs_cred: credential) *)
(*     (workspace_id: string) *)
(*     (end_k: step) *)
(*     : step = *)
(*   let rec step ctx txt = *)
(*     begin match bypass txt with *)
(*     | Some (skip_user_input, x) -> *)
(*         let txt = *)
(*           if skip_user_input then (txt, x) *)
(*           else ("", x) *)
(*         in *)
(*     | None -> *)
(* 	let req_msg = *)
(* 	  { msg_req_input = { in_text = txt }; *)
(*             msg_req_alternate_intents = false; *)
(*             msg_req_context = Some ctx; *)
(*             msg_req_entities = None; *)
(*             msg_req_intents = None; *)
(*             msg_req_output = None; } *)
(* 	in *)
(*         let req_msg = before req_msg in *)
(* 	let resp = *)
(* 	  Wcs.message wcs_cred c.call_workspace_id req_msg *)
(* 	in *)
(*         let resp = after resp in *)
(*         (\* Format.eprintf "XXXXX interpret: %s XXXXXXX@." *\) *)
(*         (\*   (pretty_json_string (Wcs_j.string_of_message_response resp)); *\) *)
(*         let ctx = resp.msg_rsp_context in *)
(*         let ctx, txt = *)
(*           begin match Context.take_call ctx with *)
(*           | ctx, Some c -> *)
(*               let txt, res = *)
(*                 call ~bypass ~before ~after ~user_input wcs_cred c *)
(*               in *)
(*               let ctx = *)
(*                 begin match c.call_return with *)
(*                 | None -> ctx *)
(*                 | Some lbl -> Context.set ctx lbl res *)
(*                 end *)
(*               in *)
(*               ctx, txt *)
(*           | ctx, None -> ctx, txt *)
(*           end *)
(*         in *)
(*         let ctx, skip_user_input = Context.take_skip_user_input ctx in *)
(* 	begin match Context.get_return resp.msg_rsp_context with *)
(* 	| Some v -> *)
(*             if skip_user_input then (txt, v) *)
(*             else ("", v) *)
(* 	| None -> *)
(*             let txt = *)
(*               if skip_user_input then txt *)
(*               else user_input () *)
(*             in *)
(*             loop ctx txt *)
(* 	end *)
(*     end *)
(*   in *)
(*   loop c.call_context c.call_text *)


let rec call
    ?(bypass=bypass_default)
    ?(before=before_default)
    ?(after=after_default)
    ?(user_input=user_input_default)
    (wcs_cred: credential)
    (act: action)
    : string * json =
  let rec loop ctx txt =
    begin match bypass txt with
    | Some (skip_user_input, x) ->
        if skip_user_input then (txt, x)
        else ("", x)
    | None ->
	let req_msg =
          before
	    { msg_req_input = { in_text = txt };
              msg_req_alternate_intents = false;
              msg_req_context = Some ctx;
              msg_req_entities = None;
              msg_req_intents = None;
              msg_req_output = None; }
	in
	let resp =
	  Wcs.message wcs_cred act.act_name req_msg
	in
        (* Format.eprintf "XXXXX call: %s XXXXXXX@." *)
        (*   (pretty_json_string (Wcs_j.string_of_message_response resp)); *)
	List.iter
	  (fun txt -> print_string "C: "; print_endline txt)
	  resp.msg_rsp_output.out_text;
        let resp = after resp in
        let ctx = resp.msg_rsp_context in
        let ctx, txt =
          begin match Context.take_actions ctx with
          | ctx, Some acts ->
              List.fold_left
                (fun (ctx, txt) act ->
                  let txt, res =
                    call ~bypass ~before ~after ~user_input wcs_cred act
                  in
                  let ctx =
                    begin match act.act_result_variable with
                    | None -> ctx
                    | Some lbl ->
                        let prefix = String.sub lbl 0 8 in
                        let var = String.sub lbl 8 (String.length lbl - 8) in
                        assert (prefix = "context.");
                        Context.set ctx var res
                    end
                  in
                  ctx, txt)
                (ctx, txt) acts
          | ctx, None -> ctx, txt
          end
        in
        let ctx, skip_user_input = Context.take_skip_user_input ctx in
	begin match Context.get_return resp.msg_rsp_context with
	| Some v ->
            if skip_user_input then (txt, v)
            else ("", v)
	| None ->
            let txt =
              if skip_user_input then txt
              else user_input ()
            in
            loop ctx txt
	end
    end
  in
  begin match act.act_agent, act.act_type_ with
  | "client", "conversation" ->
      let ctx =
        begin match Context.get act.act_parameters "context" with
        | None -> `Null
        | Some ctx -> ctx
        end
      in
      let text =
        begin match Context.get_string act.act_parameters "text" with
        | None -> ""
        | Some s -> s
        end
      in
      loop ctx text
  | _ -> assert false
  end

let rec get_value
    ?(bypass=bypass_default)
    ?(before=before_default)
    ?(after=after_default)
    ?(user_input=user_input_default)
    ?(matcher=matcher_default)
    (wcs_cred: credential)
    (workspace_id: string)
    (ctx_init: json)
    (txt_init: string)
    : string * 'a =
  let rec loop ctx txt =
    begin match bypass txt with
    | Some (skip_user_input, x) ->
        if skip_user_input then (txt, x)
        else ("", x)
    | None ->
	let req_msg =
          before
	    { msg_req_input = { in_text = txt };
              msg_req_alternate_intents = false;
              msg_req_context = Some ctx;
              msg_req_entities = None;
              msg_req_intents = None;
              msg_req_output = None; }
	in
        Log.debug "Wcs_extra"
          ("Request:\n"^
           (Json_util.pretty_message_request req_msg));
	let resp =
	  Wcs.message wcs_cred workspace_id req_msg
	in
        Log.debug "Wcs_extra"
          ("Response:\n"^
           (Json_util.pretty_message_response resp));
	List.iter
	  (fun txt -> print_string "C: "; print_endline txt)
	  resp.msg_rsp_output.out_text;
        let resp = after resp in
        let ctx = resp.msg_rsp_context in
        let ctx, txt =
          begin match Context.take_actions ctx with
          | ctx, Some acts ->
              List.fold_left
                (fun (ctx, txt) act ->
                  let txt, res =
                    call ~before ~after ~user_input wcs_cred act
                  in
                  let ctx =
                    begin match act.act_result_variable with
                    | None -> ctx
                    | Some lbl ->
                        let prefix = String.sub lbl 0 8 in
                        let var = String.sub lbl 8 (String.length lbl - 8) in
                        assert (prefix = "context.");
                        Context.set ctx var res
                    end
                  in
                  ctx, txt)
                (ctx, txt) acts
          | ctx, None -> ctx, txt
          end
        in
        let ctx, skip_user_input = Context.take_skip_user_input ctx in
	begin match matcher resp with
	| Some v ->
            if skip_user_input then (txt, v)
            else ("", v)
	| None ->
            let txt =
              if skip_user_input then txt
              else user_input ()
            in
            loop ctx txt
	end
    end
  in
  loop ctx_init txt_init
