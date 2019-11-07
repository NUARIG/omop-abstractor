-- options = { namespace_type: 'Abstractor::AbstractorNamespace', namespace_id: 1 }
-- NoteStableIdentifier.pivot_abstractions(options).by_abstractor_abstraction_status(Abstractor::Enum::ABSTRACTION_STATUS_REVIEWED , options).to_sql
-- NoteStableIdentifier.pivot_grouped_abstractions('Primary Cancer', options).by_abstractor_abstraction_status(Abstractor::Enum::ABSTRACTION_STATUS_REVIEWED , options).to_sql
-- NoteStableIdentifier.pivot_grouped_abstractions('Metastatic Cancer', options).by_abstractor_abstraction_status(Abstractor::Enum::ABSTRACTION_STATUS_REVIEWED , options).to_sql

DROP TABLE IF EXISTS cancer_diagnosis_abstractions;

CREATE TEMPORARY TABLE cancer_diagnosis_abstractions
(
  id                                       BIGINT        NOT NULL,
  note_id                                  BIGINT        NOT NULL,
  stable_identifier_path                   varchar(255)  NULL,
  stable_identifier_value                  varchar(255)  NULL,
  subject_id                               BIGINT        NOT NULL ,
  has_cancer_histology                     varchar(255)  NULL,
  has_cancer_site                          varchar(255)  NULL,
  has_cancer_site_laterality               varchar(255)  NULL,
  has_cancer_who_grade                     varchar(255)  NULL,
  has_cancer_recurrence_status             varchar(255)  NULL,
  has_metastatic_cancer_histology          varchar(255)  NULL,
  has_metastatic_cancer_primary_site       varchar(255)  NULL,
  has_metastatic_cancer_site_laterality    varchar(255)  NULL,
  has_metastatic_cancer_recurrence_status  varchar(255)  NULL
);


INSERT INTO cancer_diagnosis_abstractions (
    id
  , note_id
  , stable_identifier_path
  , stable_identifier_value
  , subject_id
  , has_cancer_histology
  , has_cancer_site
  , has_cancer_site_laterality
  , has_cancer_who_grade
  , has_cancer_recurrence_status
  , has_metastatic_cancer_histology
  , has_metastatic_cancer_primary_site
  , has_metastatic_cancer_site_laterality
  , has_metastatic_cancer_recurrence_status
)
SELECT  note_stable_identifier.id
      , note_stable_identifier.note_id
      , note_stable_identifier.stable_identifier_path
      , note_stable_identifier.stable_identifier_value
      , pivoted_abstractions.subject_id
      , pivoted_abstractions.has_cancer_histology
      , pivoted_abstractions.has_cancer_site
      , pivoted_abstractions.has_cancer_site_laterality
      , pivoted_abstractions.has_cancer_who_grade
      , pivoted_abstractions.has_cancer_recurrence_status
      , pivoted_abstractions.has_metastatic_cancer_histology
      , pivoted_abstractions.has_metastatic_cancer_primary_site
      , pivoted_abstractions.has_metastatic_cancer_site_laterality
      , pivoted_abstractions.has_metastatic_cancer_recurrence_status
FROM   "note_stable_identifier"
       JOIN (SELECT note_stable_identifier.id AS subject_id,
                    Max(CASE
                          WHEN data.predicate = 'has_cancer_histology' THEN
                          data.value
                          ELSE NULL
                        END)                  AS has_cancer_histology,
                    Max(CASE
                          WHEN data.predicate = 'has_cancer_site' THEN
                          data.value
                          ELSE NULL
                        END)                  AS has_cancer_site,
                    Max(CASE
                          WHEN data.predicate = 'has_cancer_site_laterality'
                        THEN
                          data.value
                          ELSE NULL
                        END)                  AS has_cancer_site_laterality,
                    Max(CASE
                          WHEN data.predicate = 'has_cancer_who_grade' THEN
                          data.value
                          ELSE NULL
                        END)                  AS has_cancer_who_grade,
                    Max(CASE
                          WHEN data.predicate = 'has_cancer_recurrence_status'
                        THEN
                          data.value
                          ELSE NULL
                        END)                  AS has_cancer_recurrence_status,
                    Max(CASE
                          WHEN data.predicate =
                               'has_metastatic_cancer_histology' THEN
                          data.value
                          ELSE NULL
                        END)                  AS has_metastatic_cancer_histology
                    ,
                    Max(CASE
                          WHEN data.predicate = 'has_metastatic_cancer_site'
                        THEN
                          data.value
                          ELSE NULL
                        END)                  AS has_metastatic_cancer_site,
                    Max(CASE
                          WHEN data.predicate =
                               'has_metastatic_cancer_primary_site'
                        THEN
                          data.value
                          ELSE NULL
                        END)                  AS
                    has_metastatic_cancer_primary_site,
                    Max(CASE
                          WHEN data.predicate =
                               'has_metastatic_cancer_site_laterality'
                        THEN
                          data.value
                          ELSE NULL
                        END)                  AS
                    has_metastatic_cancer_site_laterality,
                    Max(CASE
                          WHEN data.predicate =
                               'has_metastatic_cancer_recurrence_status'
                        THEN
                          data.value
                          ELSE NULL
                        END)                  AS
       has_metastatic_cancer_recurrence_status,
                    abstractor_abstraction_group_id
             FROM   (SELECT aas.predicate,
                            aas.id AS abstraction_schema_id,
                            asb.subject_type,
                            aa.about_id,
                            CASE
                              WHEN aa.value IS NOT NULL
                                   AND aa.value != '' THEN aa.value
                              WHEN aa.unknown = true THEN 'unknown'
                              WHEN aa.not_applicable = true THEN
                              'not applicable'
                            END    AS value,
                            aag.id AS abstractor_abstraction_group_id
                     FROM   abstractor_abstractions aa
                            JOIN abstractor_subjects asb
                              ON aa.abstractor_subject_id = asb.id
                            JOIN abstractor_abstraction_schemas aas
                              ON asb.abstractor_abstraction_schema_id = aas.id
                            JOIN abstractor_abstraction_group_members aagm
                              ON aa.id = aagm.abstractor_abstraction_id
                            JOIN abstractor_abstraction_groups aag
                              ON aagm.abstractor_abstraction_group_id = aag.id
                     WHERE  asb.subject_type = 'NoteStableIdentifier'
                            AND asb.namespace_type =
                                'Abstractor::AbstractorNamespace'
                            AND asb.namespace_id = 1
                            AND aag.abstractor_subject_group_id = 1) data
                    JOIN note_stable_identifier
                      ON data.about_id = note_stable_identifier.id
             GROUP  BY note_stable_identifier.id,
                       abstractor_abstraction_group_id) pivoted_abstractions
         ON pivoted_abstractions.subject_id = note_stable_identifier.id
WHERE  ( EXISTS (SELECT 1
                 FROM   abstractor_abstractions aa
                        JOIN abstractor_subjects sub
                          ON aa.abstractor_subject_id = sub.id
                             AND sub.namespace_type =
                                 'Abstractor::AbstractorNamespace'
                             AND sub.namespace_id = 1
                 WHERE  aa.deleted_at IS NULL
                        AND aa.about_type = 'NoteStableIdentifier'
                        AND note_stable_identifier.id = aa.about_id)
         AND NOT EXISTS (SELECT 1
                         FROM   abstractor_abstractions aa
                                JOIN abstractor_subjects sub
                                  ON aa.abstractor_subject_id = sub.id
                                     AND sub.namespace_type =
                                         'Abstractor::AbstractorNamespace'
                                     AND sub.namespace_id = 1
                         WHERE  aa.deleted_at IS NULL
                                AND aa.about_type = 'NoteStableIdentifier'
                                AND note_stable_identifier.id = aa.about_id
                                AND COALESCE(aa.value, '') = ''
                                AND COALESCE(aa.unknown, false) != true
                                AND COALESCE(aa.not_applicable, false) != true)
       );


INSERT INTO cancer_diagnosis_abstractions (
   id
 , note_id
 , stable_identifier_path
 , stable_identifier_value
 , subject_id
 , has_cancer_histology
 , has_cancer_site
 , has_cancer_site_laterality
 , has_cancer_who_grade
 , has_cancer_recurrence_status
 , has_metastatic_cancer_histology
 , has_metastatic_cancer_primary_site
 , has_metastatic_cancer_site_laterality
 , has_metastatic_cancer_recurrence_status
)
SELECT  note_stable_identifier.id
     , note_stable_identifier.note_id
     , note_stable_identifier.stable_identifier_path
     , note_stable_identifier.stable_identifier_value
     , pivoted_abstractions.subject_id
     , pivoted_abstractions.has_cancer_histology
     , pivoted_abstractions.has_cancer_site
     , pivoted_abstractions.has_cancer_site_laterality
     , pivoted_abstractions.has_cancer_who_grade
     , pivoted_abstractions.has_cancer_recurrence_status
     , pivoted_abstractions.has_metastatic_cancer_histology
     , pivoted_abstractions.has_metastatic_cancer_primary_site
     , pivoted_abstractions.has_metastatic_cancer_site_laterality
     , pivoted_abstractions.has_metastatic_cancer_recurrence_status
FROM   "note_stable_identifier"
      JOIN (SELECT note_stable_identifier.id AS subject_id,
                   Max(CASE
                         WHEN data.predicate = 'has_cancer_histology' THEN
                         data.value
                         ELSE NULL
                       END)                  AS has_cancer_histology,
                   Max(CASE
                         WHEN data.predicate = 'has_cancer_site' THEN
                         data.value
                         ELSE NULL
                       END)                  AS has_cancer_site,
                   Max(CASE
                         WHEN data.predicate = 'has_cancer_site_laterality'
                       THEN
                         data.value
                         ELSE NULL
                       END)                  AS has_cancer_site_laterality,
                   Max(CASE
                         WHEN data.predicate = 'has_cancer_who_grade' THEN
                         data.value
                         ELSE NULL
                       END)                  AS has_cancer_who_grade,
                   Max(CASE
                         WHEN data.predicate = 'has_cancer_recurrence_status'
                       THEN
                         data.value
                         ELSE NULL
                       END)                  AS has_cancer_recurrence_status,
                   Max(CASE
                         WHEN data.predicate =
                              'has_metastatic_cancer_histology' THEN
                         data.value
                         ELSE NULL
                       END)                  AS has_metastatic_cancer_histology
                   ,
                   Max(CASE
                         WHEN data.predicate = 'has_metastatic_cancer_site'
                       THEN
                         data.value
                         ELSE NULL
                       END)                  AS has_metastatic_cancer_site,
                   Max(CASE
                         WHEN data.predicate =
                              'has_metastatic_cancer_primary_site'
                       THEN
                         data.value
                         ELSE NULL
                       END)                  AS
                   has_metastatic_cancer_primary_site,
                   Max(CASE
                         WHEN data.predicate =
                              'has_metastatic_cancer_site_laterality'
                       THEN
                         data.value
                         ELSE NULL
                       END)                  AS
                   has_metastatic_cancer_site_laterality,
                   Max(CASE
                         WHEN data.predicate =
                              'has_metastatic_cancer_recurrence_status'
                       THEN
                         data.value
                         ELSE NULL
                       END)                  AS
      has_metastatic_cancer_recurrence_status,
                   abstractor_abstraction_group_id
            FROM   (SELECT aas.predicate,
                           aas.id AS abstraction_schema_id,
                           asb.subject_type,
                           aa.about_id,
                           CASE
                             WHEN aa.value IS NOT NULL
                                  AND aa.value != '' THEN aa.value
                             WHEN aa.unknown = true THEN 'unknown'
                             WHEN aa.not_applicable = true THEN
                             'not applicable'
                           END    AS value,
                           aag.id AS abstractor_abstraction_group_id
                    FROM   abstractor_abstractions aa
                           JOIN abstractor_subjects asb
                             ON aa.abstractor_subject_id = asb.id
                           JOIN abstractor_abstraction_schemas aas
                             ON asb.abstractor_abstraction_schema_id = aas.id
                           JOIN abstractor_abstraction_group_members aagm
                             ON aa.id = aagm.abstractor_abstraction_id
                           JOIN abstractor_abstraction_groups aag
                             ON aagm.abstractor_abstraction_group_id = aag.id
                    WHERE  asb.subject_type = 'NoteStableIdentifier'
                           AND asb.namespace_type =
                               'Abstractor::AbstractorNamespace'
                           AND asb.namespace_id = 1
                           AND aag.abstractor_subject_group_id = 2) data
                   JOIN note_stable_identifier
                     ON data.about_id = note_stable_identifier.id
            GROUP  BY note_stable_identifier.id,
                      abstractor_abstraction_group_id) pivoted_abstractions
        ON pivoted_abstractions.subject_id = note_stable_identifier.id
WHERE  ( EXISTS (SELECT 1
                FROM   abstractor_abstractions aa
                       JOIN abstractor_subjects sub
                         ON aa.abstractor_subject_id = sub.id
                            AND sub.namespace_type =
                                'Abstractor::AbstractorNamespace'
                            AND sub.namespace_id = 1
                WHERE  aa.deleted_at IS NULL
                       AND aa.about_type = 'NoteStableIdentifier'
                       AND note_stable_identifier.id = aa.about_id)
        AND NOT EXISTS (SELECT 1
                        FROM   abstractor_abstractions aa
                               JOIN abstractor_subjects sub
                                 ON aa.abstractor_subject_id = sub.id
                                    AND sub.namespace_type =
                                        'Abstractor::AbstractorNamespace'
                                    AND sub.namespace_id = 1
                        WHERE  aa.deleted_at IS NULL
                               AND aa.about_type = 'NoteStableIdentifier'
                               AND note_stable_identifier.id = aa.about_id
                               AND COALESCE(aa.value, '') = ''
                               AND COALESCE(aa.unknown, false) != true
                               AND COALESCE(aa.not_applicable, false) != true)
      );


DROP TABLE IF EXISTS cancer_abstractions;

CREATE TEMPORARY TABLE cancer_abstractions
(
 id                                       BIGINT        NOT NULL,
 note_id                                  BIGINT        NOT NULL,
 stable_identifier_path                   varchar(255)  NULL,
 stable_identifier_value                  varchar(255)  NULL,
 subject_id                               BIGINT        NOT NULL ,
 has_idh1_status                          varchar(255)  NULL,
 has_idh2_status                          varchar(255)  NULL,
 has_1p_status                            varchar(255)  NULL,
 has_19q_status                           varchar(255)  NULL,
 has_10q_PTEN_status                      varchar(255)  NULL,
 has_mgmt_status                          varchar(255)  NULL,
 has_ki67                                 varchar(255)  NULL,
 has_p53                                  varchar(255)  NULL
);

INSERT INTO cancer_abstractions (
   id
 , note_id
 , stable_identifier_path
 , stable_identifier_value
 , subject_id
 , has_idh1_status
 , has_idh2_status
 , has_1p_status
 , has_19q_status
 , has_10q_PTEN_status
 , has_mgmt_status
 , has_ki67
 , has_p53

)
SELECT  note_stable_identifier.id
     , note_stable_identifier.note_id
     , note_stable_identifier.stable_identifier_path
     , note_stable_identifier.stable_identifier_value
     , pivoted_abstractions.subject_id
     , pivoted_abstractions.has_idh1_status
     , pivoted_abstractions.has_idh2_status
     , pivoted_abstractions.has_1p_status
     , pivoted_abstractions.has_19q_status
     , pivoted_abstractions.has_10q_PTEN_status
     , pivoted_abstractions.has_mgmt_status
     , pivoted_abstractions.has_ki67
     , pivoted_abstractions.has_p53
FROM   "note_stable_identifier"
     LEFT JOIN (SELECT note_stable_identifier.id AS subject_id,
                       Max(CASE
                             WHEN data.predicate = 'has_idh1_status' THEN
                             data.value
                             ELSE NULL
                           END)                  AS has_idh1_status,
                       Max(CASE
                             WHEN data.predicate = 'has_idh2_status' THEN
                             data.value
                             ELSE NULL
                           END)                  AS has_idh2_status,
                       Max(CASE
                             WHEN data.predicate = 'has_1p_status' THEN
                             data.value
                             ELSE NULL
                           END)                  AS has_1p_status,
                       Max(CASE
                             WHEN data.predicate = 'has_19q_status' THEN
                             data.value
                             ELSE NULL
                           END)                  AS has_19q_status,
                       Max(CASE
                             WHEN data.predicate = 'has_10q_PTEN_status' THEN
                             data.value
                             ELSE NULL
                           END)                  AS has_10q_PTEN_status,
                       Max(CASE
                             WHEN data.predicate = 'has_mgmt_status' THEN
                             data.value
                             ELSE NULL
                           END)                  AS has_mgmt_status,
                       Max(CASE
                             WHEN data.predicate = 'has_ki67' THEN data.value
                             ELSE NULL
                           END)                  AS has_ki67,
                       Max(CASE
                             WHEN data.predicate = 'has_p53' THEN data.value
                             ELSE NULL
                           END)                  AS has_p53
                FROM   (SELECT aas.predicate,
                               aas.id AS abstractor_abstraction_schema_id,
                               asb.subject_type,
                               aa.about_id,
                               CASE
                                 WHEN aa.value IS NOT NULL
                                      AND aa.value != '' THEN aa.value
                                 WHEN aa.unknown = true THEN 'unknown'
                                 WHEN aa.not_applicable = true THEN
                                 'not applicable'
                               END    AS value
                        FROM   abstractor_abstractions aa
                               JOIN abstractor_subjects asb
                                 ON aa.abstractor_subject_id = asb.id
                               JOIN abstractor_abstraction_schemas aas
                                 ON asb.abstractor_abstraction_schema_id =
                                    aas.id
                        WHERE  asb.subject_type = 'NoteStableIdentifier'
                               AND asb.namespace_type =
                                   'Abstractor::AbstractorNamespace'
                               AND asb.namespace_id = 1
                               AND NOT
                       EXISTS (SELECT 1
                               FROM   abstractor_abstraction_group_members
                                      aagm
                               WHERE  aa.id = aagm.abstractor_abstraction_id))
                       data
                       JOIN note_stable_identifier
                         ON data.about_id = note_stable_identifier.id
                GROUP  BY note_stable_identifier.id) pivoted_abstractions
            ON pivoted_abstractions.subject_id = note_stable_identifier.id
WHERE  ( EXISTS (SELECT 1
               FROM   abstractor_abstractions aa
                      JOIN abstractor_subjects sub
                        ON aa.abstractor_subject_id = sub.id
                           AND sub.namespace_type =
                               'Abstractor::AbstractorNamespace'
                           AND sub.namespace_id = 1
               WHERE  aa.deleted_at IS NULL
                      AND aa.about_type = 'NoteStableIdentifier'
                      AND note_stable_identifier.id = aa.about_id)
       AND NOT EXISTS (SELECT 1
                       FROM   abstractor_abstractions aa
                              JOIN abstractor_subjects sub
                                ON aa.abstractor_subject_id = sub.id
                                   AND sub.namespace_type =
                                       'Abstractor::AbstractorNamespace'
                                   AND sub.namespace_id = 1
                       WHERE  aa.deleted_at IS NULL
                              AND aa.about_type = 'NoteStableIdentifier'
                              AND note_stable_identifier.id = aa.about_id
                              AND COALESCE(aa.value, '') = ''
                              AND COALESCE(aa.unknown, false) != true
                              AND COALESCE(aa.not_applicable, false) != true)
     );


SELECT DISTINCT
    note.note_id
  , note.note_date
  , note_stable_identifier.id
  , note.note_title
  , note.note_text
  , concept.concept_code
  , procedure_occurrence.procedure_date
  , prov1.provider_name                     AS pathologists_name
  , prov2.provider_name                     AS surgeon_name
  , cancer_abstractions.has_idh1_status
  , cancer_abstractions.has_idh2_status
  , cancer_abstractions.has_1p_status
  , cancer_abstractions.has_19q_status
  , cancer_abstractions.has_10q_PTEN_status
  , cancer_abstractions.has_mgmt_status
  , cancer_abstractions.has_ki67
  , cancer_abstractions.has_p53
  , cancer_diagnosis_abstractions.has_cancer_histology
  , cancer_diagnosis_abstractions.has_cancer_site
  , cancer_diagnosis_abstractions.has_cancer_site_laterality
  , cancer_diagnosis_abstractions.has_cancer_who_grade
  , cancer_diagnosis_abstractions.has_cancer_recurrence_status
  , cancer_diagnosis_abstractions.has_metastatic_cancer_histology
  , cancer_diagnosis_abstractions.has_metastatic_cancer_primary_site
  , cancer_diagnosis_abstractions.has_metastatic_cancer_site_laterality
  , cancer_diagnosis_abstractions.has_metastatic_cancer_recurrence_status
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
                          JOIN cancer_abstractions  ON note_stable_identifier.id = cancer_abstractions.subject_id
                          LEFT JOIN cancer_diagnosis_abstractions ON note_stable_identifier.id = cancer_diagnosis_abstractions.subject_id
WHERE note.note_title = 'Final Diagnosis'
AND note_date >='2018-03-01'
UNION
SELECT DISTINCT
      note.note_id
    , note.note_date
    , note_stable_identifier.id
    , note.note_title
    , note.note_text
    , concept.concept_code
    , procedure_occurrence.procedure_date
    , prov1.provider_name                     AS pathologists_name
    , NULL                                    AS provider_name
    , cancer_abstractions.has_idh1_status
    , cancer_abstractions.has_idh2_status
    , cancer_abstractions.has_1p_status
    , cancer_abstractions.has_19q_status
    , cancer_abstractions.has_10q_PTEN_status
    , cancer_abstractions.has_mgmt_status
    , cancer_abstractions.has_ki67
    , cancer_abstractions.has_p53
    , cancer_diagnosis_abstractions.has_cancer_histology
    , cancer_diagnosis_abstractions.has_cancer_site
    , cancer_diagnosis_abstractions.has_cancer_site_laterality
    , cancer_diagnosis_abstractions.has_cancer_who_grade
    , cancer_diagnosis_abstractions.has_cancer_recurrence_status
    , cancer_diagnosis_abstractions.has_metastatic_cancer_histology
    , cancer_diagnosis_abstractions.has_metastatic_cancer_primary_site
    , cancer_diagnosis_abstractions.has_metastatic_cancer_site_laterality
    , cancer_diagnosis_abstractions.has_metastatic_cancer_recurrence_status
FROM note_stable_identifier JOIN note_stable_identifier_full ON note_stable_identifier.stable_identifier_path = note_stable_identifier_full.stable_identifier_path AND note_stable_identifier.stable_identifier_value = note_stable_identifier_full.stable_identifier_value
                           JOIN note ON note_stable_identifier_full.note_id = note.note_id
                           JOIN fact_relationship ON fact_relationship.domain_concept_id_1 = 5085 AND fact_relationship.fact_id_1 = note.note_id AND fact_relationship.relationship_concept_id = 44818790
                           JOIN procedure_occurrence ON fact_relationship.domain_concept_id_2 = 10 AND fact_relationship.fact_id_2 = procedure_occurrence.procedure_occurrence_id AND procedure_occurrence.procedure_concept_id = 4213297
                           JOIN procedure_occurrence_stable_identifier ON procedure_occurrence.procedure_occurrence_id = procedure_occurrence_stable_identifier.procedure_occurrence_id
                           JOIN concept ON procedure_occurrence.procedure_concept_id = concept.concept_id
                           JOIN provider prov1  ON procedure_occurrence.provider_id = prov1.provider_id
                           JOIN cancer_abstractions  ON note_stable_identifier.id = cancer_abstractions.subject_id
                           LEFT JOIN cancer_diagnosis_abstractions ON note_stable_identifier.id = cancer_diagnosis_abstractions.subject_id
WHERE note.note_title = 'Final Diagnosis'
AND note_date >='2018-03-01'
-- AND prov1.provider_id IN(
--  select provider_id
--  from provider
--  where npi in(
--    '1619139631' --Christina Appin
--  , '1639145311' --Eileen Bigio
--  , '1982639001' --Daniel Brat
--  , '1730345026' --Craig Horbinski
--  , '1053514513' --Qinwen Mao
--  , '1417983131' --Numa Gottardi-Littell, previously known as Numa Marquez-Sterling
--
--  )
--  or provider_name in(
--    'DALCANTO, MAURO '
--  , 'BRODY, BETTYANN '
--  )
-- )
AND NOT EXISTS(
  SELECT 1
  FROM fact_relationship AS fr2 JOIN procedure_occurrence pr2 ON fr2.domain_concept_id_2 = 10 AND fr2.fact_id_2 = pr2.procedure_occurrence_id
                                JOIN procedure_occurrence_stable_identifier posi2 ON pr2.procedure_occurrence_id = posi2.procedure_occurrence_id
  WHERE fr2.domain_concept_id_1 = 10 AND fr2.fact_id_1 = procedure_occurrence.procedure_occurrence_id AND fr2.relationship_concept_id = 44818888
)
--AND note.note_id = 3506039