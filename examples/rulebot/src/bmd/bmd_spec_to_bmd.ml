open Wcs_j
open Bmd_t
open Bmd_builder

let rec find_fields cname spec =
  begin match spec with
  | []
  | BC_concept _ :: _
  | BC_enum _ :: _ -> []
  | BC_field (cname',fname,btype) :: spec ->
      if (cname' = cname)
      then (fname,btype) :: (find_fields cname spec)
      else  (find_fields cname spec)
  end

let bmd_rec_of_fields fields =
  mk_bmd_rec fields
  
let bmd_concept_of_concept spec cname1 cname2 =
  let fields = find_fields cname1 spec in
  mk_bmd_concept cname1 cname2 (bmd_rec_of_fields fields)
  
let bmd_concept_of_enum cname enumlist =
  mk_bmd_concept cname None (mk_bmd_enum enumlist)
  
let rec bmd_concepts_of_spec spec =
  begin match spec with
  | [] ->
      []
  | BC_concept (cname1,cname2) :: spec ->
      (bmd_concept_of_concept spec cname1 cname2) :: (bmd_concepts_of_spec spec)
  | BC_enum (cname,enumlist) :: spec ->
      (bmd_concept_of_enum cname enumlist) :: (bmd_concepts_of_spec spec)
  | BC_field _ :: spec ->
      bmd_concepts_of_spec spec 
  end

let bmd_schema_of_spec spec =
  mk_bmd_schema (bmd_concepts_of_spec spec)
