USE nm_bi;
IF OBJECT_ID('tempdb..#cohort') IS NOT NULL
  DROP TABLE #cohort;

IF OBJECT_ID('tempdb..#pathology_cases') IS NOT NULL
  DROP TABLE #pathology_cases;

IF OBJECT_ID('tempdb..#pathology_cases_surgery_mappings') IS NOT NULL
  DROP TABLE #pathology_cases_surgery_mappings;


SELECT DISTINCT p.ir_id AS patient_ir_id
INTO #cohort
FROM fact.vw_diagnosis_event de JOIN dim.vw_diagnosis_event_profile dep ON de.diagnosis_event_profile_key = dep.diagnosis_event_profile_key
                                JOIN dim.vw_diagnosis_terminology dt ON de.diagnosis_key = dt.diagnosis_key
                                JOIN dim.vw_patient p ON de.patient_key = p.patient_key
                                LEFT JOIN fsm_analytics.fsm_ids_dm.mrd_pt_id_mapping map ON p.ir_id = map.ir_id
WHERE de.is_primary_diagnosis = 1
AND
(
  (
    dt.diagnosis_code_set = 'ICD-9-CM' AND
    dt.diagnosis_code IN(
                          '142.0',
                          '160',
                          '160.4',
                          '170',
                          '170.2',
                          '170.9',
                          '171',
                          '171.9',
                          '190.2',
                          '191',
                          '191.1',
                          '191.2',
                          '191.3',
                          '191.4',
                          '191.5',
                          '191.6',
                          '191.7',
                          '191.8',
                          '191.9',
                          '192',
                          '192.1',
                          '192.2',
                          '192.3',
                          '192.8',
                          '192.9',
                          '194.3',
                          '194.4',
                          '195',
                          '196',
                          '198.3',
                          '198.4',
                          '198.5',
                          '198.89',
                          '199',
                          '199.1',
                          '200',
                          '200.5',
                          '202.8',
                          '210.2',
                          '210.7',
                          '213',
                          '213.2',
                          '213.9',
                          '215',
                          '215.9',
                          '225',
                          '225.1',
                          '225.2',
                          '225.3',
                          '225.4',
                          '225.8',
                          '225.9',
                          '227.3',
                          '227.4',
                          '227.5',
                          '227.6',
                          '228.02',
                          '234.8',
                          '237',
                          '237.1',
                          '237.2',
                          '237.3',
                          '237.4',
                          '237.5',
                          '237.6',
                          '237.7',
                          '237.7',
                          '237.71',
                          '237.72',
                          '237.73',
                          '237.79',
                          '237.9',
                          '238.1',
                          '239.6',
                          '239.7',
                          '253.8',
                          '324',
                          '324.1',
                          '324.9',
                          '336.9',
                          '348.89',
                          '759.5',
                          '759.6',
                          'V12.41',
                          'V58.11'
                        )
  )
  OR
  (
    dt.diagnosis_code_set = 'ICD-10-CM' AND
    dt.diagnosis_code IN(
                          'C07',
                          'C30.0',
                          'C31.2',
                          'C41.0',
                          'C41.2',
                          'C41.9',
                          'C49.0',
                          'C49.9',
                          'C69.50',
                          'C71.0',
                          'C71.1',
                          'C71.2',
                          'C71.3',
                          'C71.4',
                          'C71.5',
                          'C71.6',
                          'C71.7',
                          'C71.8',
                          'C71.9',
                          'C72.20',
                          'C72.21',
                          'C72.22',
                          'C72.30',
                          'C72.31',
                          'C72.32',
                          'C72.40',
                          'C72.41',
                          'C72.42',
                          'C72.50',
                          'C72.59',
                          'C70.0',
                          'C70.9',
                          'C72.0',
                          'C72.1',
                          'C70.1',
                          'C72.9',
                          'C72.9',
                          'C75.1',
                          'C75.2',
                          'C75.3',
                          'C75.4',
                          'C75.5',
                          'C76.0',
                          'C77.0',
                          'C79.31',
                          'C79.32',
                          'C79.40',
                          'C79.49',
                          'C79.51',
                          'C79.52',
                          'C79.89',
                          'C80.0',
                          'C80.1',
                          'C83.30',
                          'C83.39',
                          'C83.80',
                          'C83.89',
                          'C85.80',
                          'C85.89',
                          'D11.7',
                          'D11.9',
                          'D10.6',
                          'D16.4',
                          'D16.6',
                          'D16.9',
                          'D21.0',
                          'D21.9',
                          'D33.0',
                          'D33.1',
                          'D33.2',
                          'D33.3',
                          'D32.0',
                          'D32.9',
                          'D33.4',
                          'D32.1',
                          'D33.7',
                          'D33.9',
                          'D35.2',
                          'D35.3',
                          'D35.4',
                          'D35.5',
                          'D35.6',
                          'D18.02',
                          'D09.3',
                          'D09.8',
                          'D44.3',
                          'D44.4',
                          'D44.5',
                          'D44.10',
                          'D44.6',
                          'D44.7',
                          'D44.0',
                          'D44.2',
                          'D43.0',
                          'D43.1',
                          'D43.2',
                          'D43.4',
                          'D42.0',
                          'D42.1',
                          'D42.9',
                          'Q85.00',
                          'Q85.00',
                          'Q85.01',
                          'Q85.02',
                          'Q85.03',
                          'Q85.09',
                          'D43.3',
                          'D43.8',
                          'D43.9',
                          'D48.1',
                          'D49.6',
                          'D49.7',
                          'E23.6',
                          'E24.1',
                          'G06.0',
                          'G06.1',
                          'G06.2',
                          'G95.9',
                          'G93.89',
                          'Q85.1',
                          'Q85.8',
                          'Z86.011',
                          'Z51.11'
                        )
  )
)


SELECT  pc.pathology_case_key
      , pc.source_system_id
      , pc.accessioned_datetime
      , pc.case_collect_datetime
      , pc.accession_nbr_formatted
      , pc.responsible_pathologist_provider_key
      , pr.full_name     AS responsible_pathologist_full_name
      , pr.npi           AS responsible_pathologist_npi
      , p.clarity_west_id
      , g.group_name
      , g.group_desc
      , g.snomed_code
      , g.snomed_name
      , g.source_system_id as group_id
INTO #pathology_cases
FROM fsm_analytics.pathology_fact.pathology_case pc JOIN nm_bi.dim.vw_patient p ON pc.patient_ir_id = p.ir_id AND p.is_current = 1
                                                                JOIN fsm_analytics.pathology_dim.pathology_case_group g ON pc.pathology_case_group_key = g.pathology_case_group_key
                                                                JOIN #cohort ON p.ir_id = #cohort.patient_ir_id
                                                                JOIN nm_bi.dim.vw_provider pr ON pc.responsible_pathologist_provider_key = pr.provider_key
WHERE pc.accessioned_datetime >= '3/1/2018'
AND g.source_system_id IN(
  24067431  --Surgical Pathology
, 579832842 --LF Surgical Pathology
, 579832855 --GL Surgical Pathology
, 591077826 --Surgical Pathology
, 832638188 --LF Grayslake Surgical
)
AND pr.npi IN(
  '1619139631' --Christina Appin
, '1639145311' --Eileen Bigio
, '1982639001' --Daniel Brat
, '1730345026' --Craig Horbinski
, '1053514513' --Qinwen Mao
, '1417983131' --Numa Gottardi-Littell, previously known as Numa Marquez-Sterling
--No NPI
--Mauro dal Canto
--Bruce Quinn
--Betty Ann Brody
)
--AND pc.source_system_id = '39701545'

SELECT  orc.or_case_id
      , pc.pathology_case_key
      , sc.surgical_case_key
      , (SELECT count(*) FROM fsm_analytics.pathology_map.pathology_and_surgical_case map WHERE map.pathology_case_key = pc.pathology_case_key AND map.surgical_case_key = sc.surgical_case_key) AS present_map_count
      , pc.group_name
      , pc.group_desc
      , pc.snomed_code
      , pc.snomed_name
      , pc.group_id
      , prov1.full_name AS primary_surgeon_full_name
      , prov1.npi       AS primary_surgeon_npi
INTO #pathology_cases_surgery_mappings
FROM clarity.dbo.OR_CASE orc JOIN #pathology_cases pc ON pc.clarity_west_id = orc.pat_id AND CAST(orc.surgery_date AS DATE) = CAST(pc.case_collect_datetime AS DATE)
                             LEFT JOIN nm_bi.fact.vw_surgical_case sc ON orc.or_case_id = sc.surgical_case_number
                             LEFT JOIN nm_bi.dim.vw_provider prov1 ON sc.primary_surgeon_provider_key = prov1.provider_key


SELECT   #pathology_cases.source_system_id
      ,  #pathology_cases.accession_nbr_formatted
      ,  #pathology_cases.accessioned_datetime
      ,  #pathology_cases_surgery_mappings.surgical_case_key
      ,  #pathology_cases_surgery_mappings.or_case_id
      ,  #pathology_cases.group_name
      ,  #pathology_cases.group_desc
      ,  #pathology_cases.snomed_code
      ,  #pathology_cases.snomed_name
      ,  #pathology_cases.group_id
      ,  #pathology_cases.responsible_pathologist_full_name
      ,  #pathology_cases.responsible_pathologist_npi
      ,  #pathology_cases_surgery_mappings.primary_surgeon_full_name
      ,  #pathology_cases_surgery_mappings.primary_surgeon_npi
      ,  prcs.section_description
      ,  n.note_type
      ,  n.note_text
FROM #pathology_cases    JOIN fsm_analytics.pathology_fact.pathology_case_report prc ON #pathology_cases.pathology_case_key = prc.pathology_case_key
                         JOIN fsm_analytics.pathology_fact.pathology_case_report_section prcs ON prc.pathology_case_report_key = prcs.pathology_case_report_key
                         JOIN nm_bi.fact.vw_note n ON prcs.note_key = n.note_key
                         JOIN #pathology_cases_surgery_mappings ON  #pathology_cases.pathology_case_key = #pathology_cases_surgery_mappings.pathology_case_key
                         JOIN clarity.dbo.OR_CASE orc ON orc.or_case_id = #pathology_cases_surgery_mappings.or_case_id
                         JOIN clarity.dbo.ZC_OR_SERVICE ser on ser.service_c=orc.SERVICE_C
WHERE ser.NAME IN (
'Neurosurgery',
'Neurospine',
'Pediatric Neurosurgery',
'Interventional Neuroradiology',
'Spine Surgery',
'Head and Neck'
)
AND prcs.section_description IN('Final Diagnosis', 'Final Pathologic Diagnosis')
--AND #pathology_cases.source_system_id = '40505456'
ORDER BY #pathology_cases.accessioned_datetime ASC, #pathology_cases.source_system_id