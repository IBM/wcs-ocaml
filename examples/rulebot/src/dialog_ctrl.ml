open Cnl_t
open Parser_util
open Wcs_t
open Dialog_interface_t
open Dialog_util

let user_input = Io_util.get_input_stdin
  
let select_example wcs_cred ws_select_example_id =
  let _, rule =
    Wcs_extra.get_value
      ~user_input
      ~matcher:(fun rsp -> Context.get_rule rsp.msg_rsp_context "rule")
      wcs_cred ws_select_example_id `Null ""
  in
  Format.printf "  @[%a@]@." Cnl_print.cnl_print_rule rule

let select_expr wcs_cred ws_select_expr_id ctx_init =
  let _, expr =
    Wcs_extra.get_value
      ~user_input
      ~bypass:bypass_expr
      ~matcher:(fun rsp -> Context.get_expr rsp.msg_rsp_context "expr")
      wcs_cred ws_select_expr_id ctx_init ""
  in
  (* Format.printf "  @[%a@]@." Cnl_print.cnl_print_expr_top expr; *)
  expr

let build_when_step wcs_cred ws_rulebot_when_id rule focus =
  let _, when_fragment =
    Wcs_extra.get_value
      ~user_input
      ~matcher:(fun rsp ->
        Context.get_evnt_desc rsp.msg_rsp_context "evnt_desc")
      wcs_cred ws_rulebot_when_id `Null ""
  in
  let instr =
    Cnl_instr_t.I_repl_evnt (focus,when_fragment)
  in
  let new_rule = Cnl_engine.cnl_instr_apply instr rule in
  Format.printf "  @[%a@]@." Cnl_print.cnl_print_rule new_rule;
  new_rule

let build_cond_step wcs_cred ws_rulebot_cond_id rule focus =
  let _, cond_fragment =
    Wcs_extra.get_value
      ~user_input
      ~matcher:(fun rsp ->
        Context.get_cond_desc rsp.msg_rsp_context "cond_desc")
      wcs_cred ws_rulebot_cond_id `Null ""
  in
  let instr =
    Cnl_instr_t.I_repl_cond (focus,cond_fragment)
  in
  let new_rule = Cnl_engine.cnl_instr_apply instr rule in
  Format.printf "  @[%a@]@." Cnl_print.cnl_print_rule new_rule;
  new_rule

let build_then_step wcs_cred ws_rulebot_then_id rule focus =
  let _, then_fragment =
    Wcs_extra.get_value
      ~user_input
      ~matcher:(fun rsp ->
        Context.get_actns_desc rsp.msg_rsp_context "actns_desc")
      wcs_cred ws_rulebot_then_id `Null ""
  in
  let instr =
    Cnl_instr_t.I_repl_actns (focus,then_fragment)
  in
  let new_rule = Cnl_engine.cnl_instr_apply instr rule in
  Format.printf "  @[%a@]@." Cnl_print.cnl_print_rule new_rule;
  new_rule

let build_expr_step wcs_cred ws_rulebot_expr_id rule focus =
  let expr =
    let expr =
      select_expr wcs_cred ws_rulebot_expr_id
        (Context.build_cnl (K_expr None) focus "") in
    begin match expr.expr_node with
    | N_undefined _ -> assert false
    | N_filled (_ , expr_desc) -> expr_desc
    | N_rejected (_ , expr_desc) -> assert false
    | N_accepted expr_desc -> expr_desc
    end
  in
  let instr =
    Cnl_instr_t.I_repl_expr (focus, expr)
  in
  let new_rule = Cnl_engine.cnl_instr_apply instr rule in
  Format.printf "  @[%a@]@." Cnl_print.cnl_print_rule new_rule;
  new_rule

let build_actn_step wcs_cred ws_rulebot_actn_id rule focus =
  let _, (actn_fragment,final_check) =
    Wcs_extra.get_value
      ~user_input
      ~matcher:(fun rsp ->
        let actn = Context.get_actn_desc rsp.msg_rsp_context "actn_desc" in
        let final = Context.get_bool rsp.msg_rsp_context "final" in
        begin match actn, final with
        | Some actn, Some b -> Some (actn, b)
        | _, _ -> None
        end)
      wcs_cred ws_rulebot_actn_id `Null ""
  in
  let instr =
    Cnl_instr_t.I_repl_actn (focus,actn_fragment)
  in
  let new_rule =
    let next_rule = Cnl_engine.cnl_instr_apply instr rule in
    if final_check
    then next_rule
    else (Cnl_engine.cnl_instr_apply Cnl_instr_t.I_insr_actn next_rule)
  in
  Format.printf "  @[%a@]@." Cnl_print.cnl_print_rule new_rule;
  new_rule

(** {6. Accept Dialog} *)

let accept wcs_cred ws_accept rule focus kind =
  let _, is_accepted =
    Wcs_extra.get_value
      ~user_input
      ~matcher:(fun rsp -> Context.get_bool rsp.msg_rsp_context "accept")
      wcs_cred ws_accept (Context.build_cnl kind focus "") ""
  in
  let instr =
    begin match kind with
    | K_expr _ -> Cnl_instr_t.I_conf_expr (focus, is_accepted)
    | K_actn -> Cnl_instr_t.I_conf_actn (focus, is_accepted)
    | K_evnt -> Cnl_instr_t.I_conf_evnt (focus, is_accepted)
    | K_cond -> Cnl_instr_t.I_conf_cond (focus, is_accepted)
    | K_actns -> Cnl_instr_t.I_conf_actns (focus, is_accepted)
    | K_actns_closed -> assert false (* XXX TODO XXX *)
    | K_rule -> Cnl_instr_t.I_conf_rule (focus, is_accepted)
    end
  in
  let new_rule = Cnl_engine.cnl_instr_apply instr rule in
  Format.printf "  @[%a@]@." Cnl_print.cnl_print_rule new_rule;
  new_rule

(** {6. Dispatch Dialog} *)

let build_step wcs_cred ws_ids rule focus kind =
  begin match kind with
  | K_expr _ -> build_expr_step wcs_cred ws_ids.ws_expr_id rule focus
  | K_actn -> build_actn_step wcs_cred ws_ids.ws_actn_id rule focus
  | K_evnt -> build_when_step wcs_cred ws_ids.ws_when_id rule focus
  | K_cond -> build_cond_step wcs_cred ws_ids.ws_cond_id rule focus
  | K_actns -> build_then_step wcs_cred ws_ids.ws_then_id rule focus
  | K_actns_closed -> assert false (* XXX TODO XXX *)
  | K_rule -> assert false (* XXX TODO ? XXX *)
  end

let build_when wcs_cred ws_ids rule =
  let rec loop rule =
    begin match rule.rule_node with
    | N_filled (_, rule_desc) ->
      begin match List.rev (Cnl_util.evnt_get_rejected rule_desc.rule_evnt) with
      | (Some focus, kind) :: _ ->
          let rule = build_step wcs_cred ws_ids rule focus kind in
          loop rule
      | [] ->
          begin match List.rev (Cnl_util.evnt_get_undefined rule_desc.rule_evnt) with
          | (Some focus, kind) :: _->
              let rule = build_step wcs_cred ws_ids rule focus kind in
              loop rule
          | [] ->
              rule
          | (None, _) :: _ -> assert false
          end
      | (None, _) :: _ -> assert false
      end
    | N_undefined _ | N_rejected (_, _) | N_accepted _ -> assert false
    end
  in
  loop rule

let build_cond wcs_cred ws_ids rule =
  let rec loop rule =
    begin match rule.rule_node with
    | N_filled (_, rule_desc) ->
        begin match List.rev (Cnl_util.cond_get_rejected rule_desc.rule_cond) with
        | (Some focus, kind) :: _ ->
            let rule = build_step wcs_cred ws_ids rule focus kind in
            loop rule
        | [] ->
            begin match List.rev (Cnl_util.cond_get_undefined rule_desc.rule_cond) with
            | (Some focus, kind) :: _->
                let rule = build_step wcs_cred ws_ids rule focus kind in
                loop rule
            | [] ->
                rule
            | (None, _) :: _ -> assert false
            end
        | (None, _) :: _ -> assert false
        end
    | N_undefined _ | N_rejected (_, _) | N_accepted _ -> assert false
    end
  in
  loop rule

let build_then wcs_cred ws_ids rule =
  let rec loop rule =
    begin match rule.rule_node with
    | N_filled (_, rule_desc) ->
        begin match List.rev (Cnl_util.actns_get_rejected rule_desc.rule_actns) with
        | (Some focus, kind) :: _ ->
            let rule = build_step wcs_cred ws_ids rule focus kind in
            loop rule
        | [] ->
            begin match List.rev (Cnl_util.actns_get_undefined rule_desc.rule_actns) with
            | (Some focus, kind) :: _ ->
                let rule = build_step wcs_cred ws_ids rule focus kind in
                loop rule
            | [] ->
                rule
            | (None, _) :: _ -> assert false
            end
        | (None, _) :: _ -> assert false
        end
    | N_undefined _ | N_rejected (_, _) | N_accepted _ -> assert false
    end
  in
  loop rule

(** {6. Dispatch Dialog} *)

let dispatch wcs_cred ws_dispatch_id input =
  let _, dsp =
    Wcs_extra.get_value
      ~user_input
      ~matcher:(fun rsp -> Context.get_dispatch rsp.msg_rsp_context "dispatch")
      wcs_cred ws_dispatch_id `Null input
  in
  dsp

let build_rule wcs_cred ws_ids =
  let rec loop rule input =
    let undefined = Cnl_util.rule_get_undefined rule in
    let filled = Cnl_util.rule_get_filled rule in
    let rejected = Cnl_util.rule_get_rejected rule in
    begin match undefined, filled, rejected with
    | [], [], [] ->
        rule
    | [], filled, [] ->
        begin try
          let focus =
            begin match List.find (fun (_, k) -> k = K_rule) filled with
            | Some focus, _ -> focus
            | None, _-> raise Not_found
            end
          in
          let rule = accept wcs_cred ws_ids.ws_accept_id rule focus K_rule in
          let input = Io_util.get_input_stdin () in
          loop rule input
        with Not_found ->
          rule
        end
    | _ ->
        begin match dispatch wcs_cred ws_ids.ws_dispatch_id input with
        | { dsp_abort = true } -> Cnl_samples.rule_init ()
        | { dsp_number = Some n } ->
            raise (Failure "TODO: search the hole in the term and call the correct subdialog")
        | { dsp_when = true } ->
            let rule = build_when wcs_cred ws_ids rule in
            loop rule ""
        | { dsp_cond = true } ->
            let rule = build_cond wcs_cred ws_ids rule in
            loop rule ""
        | { dsp_then = true } ->
            let rule = build_then wcs_cred ws_ids rule in
            loop rule ""
        | _ ->
            let input = Io_util.get_input_stdin () in
            loop rule input
        end
    end
  in
  let rule = Cnl_samples.rule_init () in
  Format.printf "  @[%a@]@." Cnl_print.cnl_print_rule rule;
  loop rule ""
