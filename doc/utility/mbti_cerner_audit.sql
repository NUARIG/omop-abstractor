SELECT p.*
FROM nmh_cerner.nmh_cerner_ods.pathology_case pc  JOIN nmh_cerner.nmh_cerner_ods.prefix_group pg on pc.group_id = pg.group_id
                                                  JOIN nmh_cerner.nmh_cerner_ods.code_value cv on pc.case_type_cd = cv.code_value
                                                  JOIN nmh_cerner.nmh_cerner_ods.case_report cr ON pc.case_id = cr.case_id
                                                  JOIN nmh_cerner.nmh_cerner_ods.clinical_event ce ON cr.event_id = ce.event_id AND ce.result_status_cd IN(9, 17, 124938)
                                                  JOIN nmh_cerner.nmh_cerner_ods.code_value cv2 on cr.catalog_cd = cv2.code_value
                                                  JOIN nmh_cerner.nmh_cerner_ods.clinical_event ce2 ON ce2.parent_event_id = ce.event_id AND ce2.result_status_cd IN(9, 17, 124938)
                                                  JOIN nmh_cerner.nmh_cerner_ods.code_value cv3 on ce2.event_cd = cv3.code_value
                                                  JOIN nmh_cerner.nmh_cerner_dm.ce_blob b ON ce2.event_id = b.event_id
                                                  JOIN nmh_cerner.nmh_cerner_ods.person p on pc.responsible_pathologist_id = p.person_id
                                                  --JOIN nmh_cerner.nmh_cerner_ods.case_specimen cs ON pc.case_id = cs.case_id
                                                  --JOIN nmh_cerner.nmh_cerner_ods.code_value cv2 ON cs.specimen_cd = cv2.code_value
WHERE pc.accessioned_dt_tm between '1/1/2019' AND '2/1/2019'
AND cv3.description = 'Final Diagnosis'
AND cv.description IN(
  'Surgical'
)
order by p.name_last_key, p.name_first_key