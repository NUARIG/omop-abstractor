--Outside Pathology Cases
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
      , prov1.provider_name
FROM note_stable_identifier JOIN note ON note_stable_identifier.note_id = note.note_id
                            JOIN fact_relationship ON fact_relationship.domain_concept_id_1 = 5085 AND fact_relationship.fact_id_1 = note.note_id AND fact_relationship.relationship_concept_id = 44818790
                            JOIN procedure_occurrence ON fact_relationship.domain_concept_id_2 = 10 AND fact_relationship.fact_id_2 = procedure_occurrence.procedure_occurrence_id AND procedure_occurrence.procedure_concept_id = 4019097
                            JOIN procedure_occurrence_stable_identifier ON procedure_occurrence.procedure_occurrence_id = procedure_occurrence_stable_identifier.procedure_occurrence_id
                            JOIN concept ON procedure_occurrence.procedure_concept_id = concept.concept_id
                            JOIN provider prov1  ON procedure_occurrence.provider_id = prov1.provider_id
WHERE note.note_title IN('Interpretation', 'Final Diagnosis')
AND note_date >='2018-03-01'
AND procedure_occurrence_stable_identifier.stable_identifier_value_1 IN(
  ?
)
