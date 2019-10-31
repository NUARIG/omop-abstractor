SELECT  abstractor_abstraction_schemas.id                      AS abstractor_abstraction_schema_id
      , abstractor_abstraction_schemas.predicate
      , abstractor_abstraction_schemas.display_name
      , abstractor_abstraction_schemas.preferred_name
      , abstractor_object_types.value                          AS abstractor_object_types_value
      , abstractor_abstraction_schema_predicate_variants.value AS abstractor_abstraction_schema_predicate_variants_value
      , abstractor_object_values.value                         AS abstractor_object_values_vaue
      , abstractor_object_value_variants.value                 AS abstractor_object_value_variant_value
FROM  abstractor_abstraction_schemas JOIN abstractor_abstraction_schema_predicate_variants ON abstractor_abstraction_schemas.id = abstractor_abstraction_schema_predicate_variants.abstractor_abstraction_schema_id AND abstractor_abstraction_schema_predicate_variants.deleted_at IS NULL
                                     JOIN abstractor_object_types ON abstractor_abstraction_schemas.abstractor_object_type_id = abstractor_object_types.id
                                     JOIN abstractor_abstraction_schema_object_values ON abstractor_abstraction_schemas.id = abstractor_abstraction_schema_object_values.abstractor_abstraction_schema_id AND abstractor_abstraction_schema_object_values.deleted_at IS NULL
                                     JOIN abstractor_object_values ON abstractor_abstraction_schema_object_values.abstractor_object_value_id = abstractor_object_values.id AND abstractor_object_values.deleted_at IS NULl
                                     JOIN abstractor_object_value_variants ON abstractor_object_values.id  = abstractor_object_value_variants.abstractor_object_value_id
WHERE abstractor_abstraction_schemas.deleted_at IS NULL
ORDER BY abstractor_abstraction_schemas.id, abstractor_object_values.value, abstractor_object_value_variants.value



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
     , abstractor_abstraction_schemas.predicate
     , abstractor_suggestions.suggested_value
     , abstractor_suggestions.unknown
     , abstractor_suggestions.not_applicable
     , abstractor_suggestion_sources.match_value
     , abstractor_suggestion_sources.sentence_match_value
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
                            JOIN abstractor_abstractions ON note_stable_identifier.id = abstractor_abstractions.about_id
                            JOIN abstractor_suggestions ON abstractor_abstractions.id = abstractor_suggestions.abstractor_abstraction_id
                            JOIN abstractor_subjects ON abstractor_abstractions.abstractor_subject_id = abstractor_subjects.id
                            JOIN abstractor_abstraction_schemas ON abstractor_subjects.abstractor_abstraction_schema_id = abstractor_abstraction_schemas.id
                            JOIN abstractor_suggestion_sources ON abstractor_suggestions.id = abstractor_suggestion_sources.abstractor_suggestion_id
WHERE note.note_title = 'Final Diagnosis'
AND note_date >='2018-03-01'
AND note.note_id = 20051773
AND abstractor_abstraction_schemas.predicate = 'has_idh1_status'