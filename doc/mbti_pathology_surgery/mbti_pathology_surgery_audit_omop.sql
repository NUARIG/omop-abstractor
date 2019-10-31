--Inside Pathology Cases
SELECT  note.note_id
      , note.note_date
      , note_stable_identifier.stable_identifier_path
      , note_stable_identifier.stable_identifier_value
      , note.note_title
      , note.note_text
      , procedure_occurrence.procedure_occurrence_id
      , procedure_occurrence.procedure_concept_id
      , concept.concept_code
      , procedure_occurrence.procedure_date
      , procedure_occurrence_stable_identifier.stable_identifier_path
      , procedure_occurrence_stable_identifier.stable_identifier_value_1
FROM note_stable_identifier JOIN note ON note_stable_identifier.note_id = note.note_id
                            JOIN fact_relationship ON fact_relationship.domain_concept_id_1 = 5085 AND fact_relationship.fact_id_1 = note.note_id AND fact_relationship.relationship_concept_id = 44818790
                            JOIN procedure_occurrence ON fact_relationship.domain_concept_id_2 = 10 AND fact_relationship.fact_id_2 = procedure_occurrence.procedure_occurrence_id AND procedure_occurrence.procedure_concept_id = 4213297
                            JOIN procedure_occurrence_stable_identifier ON procedure_occurrence.procedure_occurrence_id = procedure_occurrence_stable_identifier.procedure_occurrence_id
                            JOIN concept ON procedure_occurrence.procedure_concept_id = concept.concept_id
--WHERE (NOT EXISTS(SELECT 1 FROM abstractor_namespace_events WHERE abstractor_namespace_events.eventable_type = 'NoteStableIdentifier' AND abstractor_namespace_events.eventable_id = note_stable_identifier.id AND abstractor_namespace_events.abstractor_namespace_id = 4))
WHERE note.note_title = 'Final Diagnosis'
AND note_date >='2018-03-01'

--Inside Pathology Cases with Surgeries
SELECT note.note_id
     , note.note_date
     , note_stable_identifier.id
     , note_stable_identifier.stable_identifier_path
     , note_stable_identifier.stable_identifier_value
     , note.note_title
     , note.note_text
     , procedure_occurrence.procedure_occurrence_id
     , procedure_occurrence.procedure_concept_id
     , concept.concept_code
     , procedure_occurrence.procedure_date
     , procedure_occurrence_stable_identifier.id
     , procedure_occurrence_stable_identifier.stable_identifier_path
     , procedure_occurrence_stable_identifier.stable_identifier_value_1
     , prov1.provider_name
     , prov2.provider_name
     , posi2.id
     , posi2.stable_identifier_path
     , posi2.stable_identifier_value_1
FROM note_stable_identifier JOIN note_stable_identifier_full ON note_stable_identifier.stable_identifier_path = note_stable_identifier_full.stable_identifier_path AND note_stable_identifier.stable_identifier_value = note_stable_identifier_full.stable_identifier_value
                            JOIN note ON note_stable_identifier_full.note_id = note.note_id
                            JOIN fact_relationship ON fact_relationship.domain_concept_id_1 = 5085 AND fact_relationship.fact_id_1 = note.note_id AND fact_relationship.relationship_concept_id = 44818790
                            JOIN procedure_occurrence ON fact_relationship.domain_concept_id_2 = 10 AND fact_relationship.fact_id_2 = procedure_occurrence.procedure_occurrence_id AND procedure_occurrence.procedure_concept_id = 4213297
                            JOIN procedure_occurrence_stable_identifier ON procedure_occurrence.procedure_occurrence_id = procedure_occurrence_stable_identifier.procedure_occurrence_id
                            JOIN concept ON procedure_occurrence.procedure_concept_id = concept.concept_id
                            JOIN fact_relationship AS fr2 ON fr2.domain_concept_id_1 = 10 AND fr2.fact_id_1 = procedure_occurrence.procedure_occurrence_id AND fr2.relationship_concept_id = 44818888
                            JOIN procedure_occurrence pr2 ON fr2.domain_concept_id_2 = 10 AND fr2.fact_id_2 = pr2.procedure_occurrence_id
                            JOIN procedure_occurrence_stable_identifier posi2 ON pr2.procedure_occurrence_id = posi2.procedure_occurrence_id
                            JOIN provider prov1  ON procedure_occurrence.provider_id = prov1.provider_id
                            JOIN provider prov2  ON pr2.provider_id = prov2.provider_id
WHERE note.note_title = 'Final Diagnosis'
AND note_date >='2018-03-01'
AND prov1.provider_id IN(
  select provider_id
  from provider
  where npi in(
    '1619139631' --Christina Appin
  , '1639145311' --Eileen Bigio
  , '1982639001' --Daniel Brat
  , '1730345026' --Craig Horbinski
  , '1053514513' --Qinwen Mao
  , '1417983131' --Numa Gottardi-Littell, previously known as Numa Marquez-Sterling

  )
  or provider_name in(
    'DALCANTO, MAURO '
  , 'BRODY, BETTYANN '
  )
)

--Inside Pathology Cases with Surgeries and Abstractions
SELECT  note.note_id
      , note.note_date
      , note_stable_identifier.stable_identifier_path
      , note_stable_identifier.stable_identifier_value
      , note.note_title
      , note.note_text
      , procedure_occurrence.procedure_occurrence_id
      , procedure_occurrence.procedure_concept_id
      , concept.concept_code
      , procedure_occurrence.procedure_date
      , procedure_occurrence_stable_identifier.stable_identifier_path
      , procedure_occurrence_stable_identifier.stable_identifier_value_1
      , abstractor_abstraction_schemas.predicate
      , abstractor_suggestions.*
FROM note_stable_identifier JOIN note ON note_stable_identifier.note_id = note.note_id
                            JOIN fact_relationship ON fact_relationship.domain_concept_id_1 = 5085 AND fact_relationship.fact_id_1 = note.note_id AND fact_relationship.relationship_concept_id = 44818790
                            JOIN procedure_occurrence ON fact_relationship.domain_concept_id_2 = 10 AND fact_relationship.fact_id_2 = procedure_occurrence.procedure_occurrence_id AND procedure_occurrence.procedure_concept_id = 4213297
                            JOIN procedure_occurrence_stable_identifier ON procedure_occurrence.procedure_occurrence_id = procedure_occurrence_stable_identifier.procedure_occurrence_id
                            JOIN concept ON procedure_occurrence.procedure_concept_id = concept.concept_id
                            JOIN abstractor_abstractions ON note_stable_identifier.id = abstractor_abstractions.about_id
                            JOIN abstractor_suggestions ON abstractor_abstractions.id = abstractor_suggestions.abstractor_abstraction_id
                            JOIN abstractor_subjects ON abstractor_abstractions.abstractor_subject_id = abstractor_subjects.id
                            JOIN abstractor_abstraction_schemas ON abstractor_subjects.abstractor_abstraction_schema_id = abstractor_abstraction_schemas.id
--WHERE (NOT EXISTS(SELECT 1 FROM abstractor_namespace_events WHERE abstractor_namespace_events.eventable_type = 'NoteStableIdentifier' AND abstractor_namespace_events.eventable_id = note_stable_identifier.id AND abstractor_namespace_events.abstractor_namespace_id = 4))
WHERE note.note_title = 'Final Diagnosis'
AND note_date >='2018-03-01'
AND procedure_occurrence_stable_identifier.stable_identifier_value_1 = '?'
