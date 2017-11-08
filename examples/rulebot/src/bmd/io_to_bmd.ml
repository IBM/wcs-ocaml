open Bmd_t
open Bmd_builder
open Bmd_util
open Io_j

let bmd_concept_of_entity cname =
  mk_bmd_concept
    cname
    None
    (mk_bmd_rec []) (* XXX Empty fields for now XXX *)

let bmd_concept_of_brand bts =
  List.map bmd_concept_of_entity bts

let process_brandTypes bts =
  List.map (fun x -> x.io_brand) bts
   
let bmd_concepts_of_io io_j =
  List.map bmd_concept_of_entity (process_brandTypes io_j.io_schema.io_brandTypes)

let bmd_of_io io_j =
  mk_bmd_schema (bmd_concepts_of_io io_j)

