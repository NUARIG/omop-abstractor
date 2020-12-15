SELECT  note_stable_identifier.stable_identifier_path
      , note_stable_identifier.stable_identifier_value
FROM note_stable_identifier  JOIN note_stable_identifier_full ON note_stable_identifier.stable_identifier_path = note_stable_identifier_full.stable_identifier_path AND note_stable_identifier.stable_identifier_value = note_stable_identifier_full.stable_identifier_value
                             JOIN note ON note_stable_identifier_full.note_id = note.note_id
                             JOIN concept AS note_type ON note.note_type_concept_id = note_type.concept_id
                             JOIN person ON note.person_id = person.person_id
                             LEFT JOIN pii_name ON person.person_id = pii_name.person_id
WHERE (
           lower(note.note_title) like '%%'
        OR lower(note.note_text) like '%%'
        OR lower(note_type.concept_name) like '%%'
        OR lower(pii_name.first_name) like '%%'
        OR lower(pii_name.last_name) like '%%'
        OR EXISTS (
                    SELECT 1 FROM pii_mrn WHERE person.person_id = pii_mrn.person_id AND pii_mrn.mrn like '%%'
                  )
      )
      AND (EXISTS (
                    SELECT 1
                    FROM abstractor_abstractions aa JOIN abstractor_subjects sub ON aa.abstractor_subject_id = sub.id AND sub.namespace_type = 'Abstractor::AbstractorNamespace' AND sub.namespace_id = '1'
                    WHERE aa.deleted_at IS NULL AND aa.about_type = 'NoteStableIdentifier' AND note_stable_identifier.id = aa.about_id
                  )
      AND NOT EXISTS (
                      SELECT 1
                      FROM abstractor_abstractions aa JOIN abstractor_subjects sub ON aa.abstractor_subject_id = sub.id AND sub.namespace_type = 'Abstractor::AbstractorNamespace' AND sub.namespace_id = '1'
                      WHERE aa.deleted_at IS NULL
                      AND aa.about_type = 'NoteStableIdentifier'
                      AND note_stable_identifier.id = aa.about_id
                      AND COALESCE(aa.value, '') = ''
                      AND COALESCE(aa.unknown, FALSE) != TRUE
                      AND COALESCE(aa.not_applicable, FALSE) != TRUE)
         )
ORDER BY note_date asc, note.note_id