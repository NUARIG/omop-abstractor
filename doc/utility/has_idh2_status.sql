--total
select *
from nlp_comparisons nlc
where  nlc.predicate = 'has_idh2_status'

--raw true positives
select abstractor_abstraction_group_id_old, *
from nlp_comparisons nlc
where nlc.predicate = 'has_idh2_status'
and nlc.value_old_normalized = nlc.value_new_normalized

--punts
select *
from nlp_comparisons nlc1
where nlc1.predicate = 'has_idh2_status'
and nlc1.value_new_normalized is null
and not exists(
  select 1
  from note_stable_identifier nsi join abstractor_abstractions aa on nsi.id = aa.about_id
                                  join abstractor_subjects asb on aa.abstractor_subject_id = asb.id
                                  join abstractor_abstraction_schemas aas on asb.abstractor_abstraction_schema_id = aas.id
                                  join abstractor_abstraction_group_members aagm on aa.id = aagm.abstractor_abstraction_id
                                  join abstractor_abstraction_groups aag on aagm.abstractor_abstraction_group_id = aag.id
                                  join abstractor_subject_groups asg on aag.abstractor_subject_group_id = asg.id

  where nlc1.stable_identifier_value = nsi.stable_identifier_value
  and aas.predicate = 'has_idh2_status'
  and (
    aa.value is not null
    or
    aa.not_applicable = true
  )
  and nlc1.abstractor_subject_group_name = asg.name
)

--curated
select *
from(
select  nlc.note_id
      , nlc.stable_identifier_value
	    , nlc.value_old_normalized
	    , nlc.value_new_normalized
      , nlc.abstractor_subject_group_name
      , 1 as group
from nlp_comparisons nlc
where nlc.predicate = 'has_idh2_status'
and nlc.value_old_normalized != nlc.value_new_normalized
union
select  nlc1.note_id
      , nlc1.stable_identifier_value
	    , nlc1.value_old_normalized
	    , nlc1.value_new_normalized
      , nlc1.abstractor_subject_group_name
      , 2 as group
from nlp_comparisons nlc1
where nlc1.predicate = 'has_idh2_status'
and nlc1.value_new_normalized is null
and exists(
  select 1
  from note_stable_identifier nsi join abstractor_abstractions aa on nsi.id = aa.about_id
                                  join abstractor_subjects asb on aa.abstractor_subject_id = asb.id
                                  join abstractor_abstraction_schemas aas on asb.abstractor_abstraction_schema_id = aas.id
                                  join abstractor_abstraction_group_members aagm on aa.id = aagm.abstractor_abstraction_id
                                  join abstractor_abstraction_groups aag on aagm.abstractor_abstraction_group_id = aag.id
                                  join abstractor_subject_groups asg on aag.abstractor_subject_group_id = asg.id

  where nlc1.stable_identifier_value = nsi.stable_identifier_value
  and aas.predicate = 'has_idh2_status'
  and (
    aa.value is not null
    or
    aa.not_applicable = true
  )
  and nlc1.abstractor_subject_group_name = asg.name
)
and nlc1.stable_identifier_value not in(
 '10260638408'
,'10267556267'
,'10308789394'
,'10267556267'
,'10301739029'
)
) data
--where data.value_new_normalized != 'not applicable'