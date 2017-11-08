let () =
  Arg.parse Rulebot_main.args Rulebot_main.anon_args Rulebot_main.usage;
  Rulebot_main.main ()
