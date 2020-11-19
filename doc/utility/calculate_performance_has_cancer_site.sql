--total
select abstractor_abstraction_group_id_old, *
from nlp_comparisons nlc
where  nlc.predicate = 'has_cancer_site'

--raw true positives
select abstractor_abstraction_group_id_old, *
from nlp_comparisons nlc
where nlc.predicate = 'has_cancer_site'
and nlc.abstractor_abstraction_group_id_new is not null
and nlc.value_old_normalized = nlc.value_new_normalized

--punts
select abstractor_abstraction_group_id_old, *
from nlp_comparisons nlc
where  nlc.predicate = 'has_cancer_site'
-- and exists(
--   select 1
--   from note_stable_identifier nsi join abstractor_abstractions aa on nsi.id = aa.about_id
--                                   join abstractor_subjects asb on aa.abstractor_subject_id = asb.id
--                                   join abstractor_abstraction_schemas aas on asb.abstractor_abstraction_schema_id = aas.id
--                                   join abstractor_abstraction_group_members aagm on aa.id = aagm.abstractor_abstraction_id
--                                   join abstractor_abstraction_groups aag on aagm.abstractor_abstraction_group_id = aag.id
--                                   join abstractor_subject_groups asg on aag.abstractor_subject_group_id = asg.id
--   where nlc.stable_identifier_value = nsi.stable_identifier_value
--   and aas.predicate = 'has_cancer_site'
--   and aa.value is null
--   and aa.not_applicable is null
--   and nlc.abstractor_subject_group_name = asg.name
-- )
and not exists(
  select 1
  from note_stable_identifier nsi join abstractor_abstractions aa on nsi.id = aa.about_id
                                  join abstractor_subjects asb on aa.abstractor_subject_id = asb.id
                                  join abstractor_abstraction_schemas aas on asb.abstractor_abstraction_schema_id = aas.id
                                  join abstractor_abstraction_group_members aagm on aa.id = aagm.abstractor_abstraction_id
                                  join abstractor_abstraction_groups aag on aagm.abstractor_abstraction_group_id = aag.id
                                  join abstractor_subject_groups asg on aag.abstractor_subject_group_id = asg.id

  where nlc.stable_identifier_value = nsi.stable_identifier_value
  and aas.predicate = 'has_cancer_site'
  and (
    aa.value is not null
    or
    aa.not_applicable = true
  )
  and nlc.abstractor_subject_group_name = asg.name
)

--curated

select  nlc.note_id
      , nlc.stable_identifier_value
	    , nlc.value_old_normalized
	    , nlc.value_new_normalized
      , nlc.abstractor_subject_group_name
      , 1 as group
from nlp_comparisons nlc
where nlc.predicate = 'has_cancer_site'
and nlc.abstractor_abstraction_group_id_new is not null
and nlc.value_old_normalized != nlc.value_new_normalized
and nlc.note_id = 83299921
UNION
select  nlc.note_id
      , nlc.stable_identifier_value
	    , nlc.value_old_normalized
	    , nlc.value_new_normalized
		  , nlc.abstractor_subject_group_name
      , 2 as group
from nlp_comparisons nlc
where  nlc.predicate = 'has_cancer_site'
and nlc.abstractor_abstraction_group_id_new is null
and exists(
  select 1
  from note_stable_identifier nsi join abstractor_abstractions aa on nsi.id = aa.about_id
                                  join abstractor_subjects asb on aa.abstractor_subject_id = asb.id
                                  join abstractor_abstraction_schemas aas on asb.abstractor_abstraction_schema_id = aas.id
                                  join abstractor_abstraction_group_members aagm on aa.id = aagm.abstractor_abstraction_id
                                  join abstractor_abstraction_groups aag on aagm.abstractor_abstraction_group_id = aag.id
                                  join abstractor_subject_groups asg on aag.abstractor_subject_group_id = asg.id
  where nlc.stable_identifier_value = nsi.stable_identifier_value
  and aas.predicate = 'has_cancer_site'
  and (
    aa.value is not null
    or
    aa.not_applicable = true
  )
  and nlc.abstractor_subject_group_name = asg.name
)
and not exists(
  select 1
  from note_stable_identifier nsi join abstractor_abstractions aa on nsi.id = aa.about_id
                                  join abstractor_subjects asb on aa.abstractor_subject_id = asb.id
                                  join abstractor_abstraction_schemas aas on asb.abstractor_abstraction_schema_id = aas.id
                                  join abstractor_abstraction_group_members aagm on aa.id = aagm.abstractor_abstraction_id
                                  join abstractor_abstraction_groups aag on aagm.abstractor_abstraction_group_id = aag.id
                                  join abstractor_subject_groups asg on aag.abstractor_subject_group_id = asg.id

  where nlc.stable_identifier_value = nsi.stable_identifier_value
  and aas.predicate = 'has_cancer_site'
  and (
    aa.value is null
    and
    aa.not_applicable is null
  )
  and nlc.abstractor_subject_group_name = asg.name
)
and nlc.note_id = 83299921