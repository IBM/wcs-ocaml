(**********************************)
(* Library functions              *)
(**********************************)

let rulebot_main () =
  Rulebot_main.main ()

let rulebot_test () =
  begin
    let rule = Cnl_samples.rule_init () in
    Cnl_print.cnl_print_rule_top rule
  end
    
let _ =
  Js.Unsafe.global##.rulebot_test :=
    Js.wrap_callback rulebot_test;
  Js.Unsafe.global##.rulebot_main :=
    Js.wrap_callback rulebot_main

