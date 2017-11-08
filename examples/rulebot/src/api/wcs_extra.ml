open Wcs_t
open Call_t

let pretty_json_string s =
  (Yojson.Basic.pretty_to_string (Yojson.Basic.from_string s))

let bypass_default (txt: string) : (bool * 'a) option =
  None

let before_default (msg_req: message_request) : message_request =
  msg_req

let after_default (msg_resp: message_response) : message_response =
  msg_resp

let user_input_default = Io_util.get_input_stdin

let matcher_default (msg_resp: message_response) : 'a option =
  None

let rec call
    ?(bypass=bypass_default)
    ?(before=before_default)
    ?(after=after_default)
    ?(user_input=user_input_default)
    (wcs_cred: credential)
    (c: call)
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
	  Wcs_api.message wcs_cred c.call_workspace_id req_msg
	in
        (* Format.eprintf "XXXXX call: %s XXXXXXX@." *)
        (*   (pretty_json_string (Wcs_j.string_of_message_response resp)); *)
	List.iter
	  Io_util.print_C
	  resp.msg_rsp_output.out_text;
        let resp = after resp in
        let ctx = resp.msg_rsp_context in
        let ctx, txt =
          begin match Context.take_call ctx with
          | ctx, Some c ->
              let txt, res =
                call ~bypass ~before ~after ~user_input wcs_cred c
              in
              let ctx =
                begin match c.call_return with
                | None -> ctx
                | Some lbl -> Context.set ctx lbl res
                end
              in
              ctx, txt
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
  loop c.call_context c.call_text


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
	let resp =
	  Wcs_api.message wcs_cred workspace_id req_msg
	in
        (* Format.eprintf "XXXXX get_value: %s XXXXXXX@." *)
        (*   (pretty_json_string (Wcs_j.string_of_message_response resp)); *)
	List.iter
	  Io_util.print_C
	  resp.msg_rsp_output.out_text;
        let resp = after resp in
        let ctx = resp.msg_rsp_context in
        let ctx, txt =
          begin match Context.take_call ctx with
          | ctx, Some c ->
              let txt, res =
                call ~before ~after ~user_input wcs_cred c
              in
              let ctx =
                begin match c.call_return with
                | None -> ctx
                | Some lbl -> Context.set ctx lbl res
                end
              in
              ctx, txt
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
