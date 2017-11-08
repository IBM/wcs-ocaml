open Bmd_t

val bmd_concept_of_entity : bmd_concept_name -> bmd_concept
val bmd_concept_of_brand :
  bmd_concept_name list -> bmd_concept list
val process_brandTypes : Io_t.brand_type list -> string list
val bmd_concepts_of_io : Io_t.io -> bmd_concept list
val bmd_of_io : Io_t.io -> bmd_schema
