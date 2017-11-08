let not_on_black_list enl =
  begin match enl with
  | (_,"java"::_) -> false
  | (_,"com"::"ibm"::"ia"::_) -> false
  | _ -> true
  end

let rec last_part enl =
  begin match enl with
  | (en,[]) -> raise (Failure "Empty entity")
  | (en,[x]) -> (en,x)
  | (en,_ :: enl') -> last_part (en,enl')
  end

let split_entity en =
  (en,Str.split (Str.regexp "\\.") en)

let process_entities entities =
  let no_dup_entities = List.sort_uniq compare entities in (* XXX Eliminate duplicates -- WCS doesn't like twice the same entity being declare XXX *)
  let split_entities = List.map split_entity no_dup_entities in
  let kept_entities = List.filter not_on_black_list split_entities in
  List.map last_part kept_entities


