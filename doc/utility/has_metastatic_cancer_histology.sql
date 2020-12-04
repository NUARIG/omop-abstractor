--total
select abstractor_abstraction_group_id_old, *
from nlp_comparisons nlc
where  nlc.predicate = 'has_metastatic_cancer_histology'

--raw true positives
select abstractor_abstraction_group_id_old, *
from nlp_comparisons nlc
where  nlc.predicate = 'has_metastatic_cancer_histology'
and nlc.abstractor_abstraction_group_id_new is not null

--punts
select abstractor_abstraction_group_id_old, *
from nlp_comparisons nlc
where  nlc.predicate = 'has_metastatic_cancer_histology'
and nlc.abstractor_abstraction_group_id_new is null
and exists(
  select 1
  from note_stable_identifier nsi join abstractor_abstractions aa on nsi.id = aa.about_id
                                  join abstractor_subjects asb on aa.abstractor_subject_id = asb.id
                                  join abstractor_abstraction_schemas aas on asb.abstractor_abstraction_schema_id = aas.id
  where nlc.stable_identifier_value = nsi.stable_identifier_value
  and aas.predicate = 'has_metastatic_cancer_histology'
  and aa.value is null
  and aa.not_applicable is null
)
-- and not exists(
--   select 1
--   from note_stable_identifier nsi join abstractor_abstractions aa on nsi.id = aa.about_id
--                                   join abstractor_subjects asb on aa.abstractor_subject_id = asb.id
--                                   join abstractor_abstraction_schemas aas on asb.abstractor_abstraction_schema_id = aas.id
--   where nlc.stable_identifier_value = nsi.stable_identifier_value
--   and aas.predicate = 'has_metastatic_cancer_histology'
--   and (
--     aa.value is not null
--     or
--     aa.not_applicable = true
--   )
-- )

--curated
select *
from(
select  nlc.note_id
      , nlc.stable_identifier_value
	    , nlc.value_old_normalized
	    , nlc.value_new_normalized
from nlp_comparisons nlc
where  nlc.predicate = 'has_metastatic_cancer_histology'
and nlc.abstractor_abstraction_group_id_new is null
and exists(
  select 1
  from note_stable_identifier nsi join abstractor_abstractions aa on nsi.id = aa.about_id
                                  join abstractor_subjects asb on aa.abstractor_subject_id = asb.id
                                  join abstractor_abstraction_schemas aas on asb.abstractor_abstraction_schema_id = aas.id
  where nlc.stable_identifier_value = nsi.stable_identifier_value
  and aas.predicate = 'has_metastatic_cancer_histology'
  and (
    aa.value is not null
    or
    aa.not_applicable = true
  )
)
and not exists(
  select 1
  from note_stable_identifier nsi join abstractor_abstractions aa on nsi.id = aa.about_id
                                  join abstractor_subjects asb on aa.abstractor_subject_id = asb.id
                                  join abstractor_abstraction_schemas aas on asb.abstractor_abstraction_schema_id = aas.id
  where nlc.stable_identifier_value = nsi.stable_identifier_value
  and aas.predicate = 'has_metastatic_cancer_histology'
  and (
    aa.value is null
    and
    aa.not_applicable is null
  )
)
) data
--where data.value_new_normalized != 'not applicable'