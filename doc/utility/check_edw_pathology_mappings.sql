SELECT  pg.group_id
      , pg.group_name
      , pg.group_desc
      , pg.active_ind
      , cv.description AS code_value_description
	  , cv.definition AS code_value_definition
FROM nmh_cerner.nmh_cerner_ods.prefix_group pg LEFT JOIN FSM_Analytics_Specialized.pathology_map.pathology_snomed_map psm ON pg.group_id = psm.group_id
                                               LEFT JOIN nmh_cerner.nmh_cerner_ods.code_value cv ON pg.site_cd = cv.code_value
WHERE pg.group_id > 0
AND psm.group_id is null