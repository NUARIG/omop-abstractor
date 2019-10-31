SELECT DISTINCT dt.*
FROM fact.vw_diagnosis_event de JOIN dim.vw_diagnosis_event_profile dep ON de.diagnosis_event_profile_key = dep.diagnosis_event_profile_key
                                JOIN dim.vw_diagnosis_terminology dt ON de.diagnosis_key = dt.diagnosis_key
                                JOIN dim.vw_patient p ON de.patient_key = p.patient_key

WHERE de.is_primary_diagnosis = 1
AND p.west_mrn = '?'
order by dt.diagnosis_code_set, dt.diagnosis_name