open Cnl_t
open Cnl_util
open Cnl_instr_t
open Cnl_engine
open Cnl_samples

let script1 =
  [I_repl_evnt (1,when1);
   I_repl_cond (2,cond1);
   I_repl_actns (3,then1);
   I_conf_evnt (1,true);
   I_conf_cond (2,true);
   I_conf_actns (3,true);]

let script2 =
  [I_repl_evnt (1,when1);
   I_repl_cond (2,cond_init ());
   I_repl_actns (3,then1);
   I_conf_evnt (1,true);
   I_conf_cond (2,true);
   I_conf_actns (3,true);]

let script3 =
  [I_repl_evnt (1,when1);
   I_repl_cond (2,C_no_condition);
   I_repl_actns (3,then1);
   I_conf_evnt (1,true);
   I_conf_cond (2,true);
   I_conf_actns (3,true);]

let script4 =
  [I_repl_evnt (1,when1);
   I_repl_cond (2,C_no_condition);
   I_repl_actns (3,actns_init ());
   I_conf_evnt (1,true);
   I_conf_cond (2,true);
   I_conf_actns (3,true);]

let script5 =
  [I_repl_evnt (1,when1);
   I_repl_cond (2,C_no_condition);
   I_repl_actns (3,actns_init ());
   I_insr_actn;
   I_insr_actn;
   I_insr_actn;
   I_conf_evnt (1,true);
   I_conf_cond (2,true);
   I_conf_actns (3,true);]

let script6 =
  [I_repl_evnt (1,when1);
   I_repl_cond (2,C_no_condition);
   I_repl_actns (3,actns_init ());
   I_insr_actn;
   I_repl_actn (4,setdesc21);
   I_repl_actn (5,setdesc22);
   I_conf_evnt (1,true);
   I_conf_cond (2,true);
   I_conf_actns (3,true);]

let script7 =
  [I_repl_evnt (1,when1);
   I_repl_cond (2,C_no_condition);
   I_repl_actns (3,actns_init ());
   I_insr_actn;
   I_insr_actn;
   I_insr_actn;
   I_repl_actn (4,print_init ());
   I_repl_actn (5,emit_init ());
   I_repl_actn (6,define_init "VNAME");
   I_repl_actn (7,set_init "VNAME" "FNAME");
   I_conf_evnt (1,true);
   I_conf_cond (2,true);
   I_conf_actns (3,true);]

let cnl_script_samples =
  [("script1",script1);
   ("script2",script2);
   ("script3",script3);
   ("script4",script4);
   ("script5",script5);
   ("script6",script6);
   ("script7",script7);]

