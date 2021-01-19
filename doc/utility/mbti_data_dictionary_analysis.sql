SELECT *
FROM(
SELECT  'Metastatic Histology' AS classificaiton
      , aov.value            AS data_point_value
      , aov.vocabulary_code
	    , aovv.value           AS data_point_value_synonym
	    , aov.favor_more_specific
FROM abstractor_subjects asb JOIN abstractor_abstraction_schemas aas ON asb.abstractor_abstraction_schema_id = aas.id
                             JOIN abstractor_namespaces an ON asb.namespace_id = an.id AND asb.namespace_type = 'Abstractor::AbstractorNamespace'
                             LEFT JOIN abstractor_abstraction_schema_object_values aasov ON aas.id = aasov.abstractor_abstraction_schema_id
                             LEFT JOIN abstractor_object_values aov ON aasov.abstractor_object_value_id = aov.id
                             LEFT JOIN abstractor_object_value_variants aovv ON aov.id = aovv.abstractor_object_value_id
                             LEFT JOIN abstractor_subject_group_members asgm ON asb.id = asgm.abstractor_subject_id
                             LEFT JOIN abstractor_subject_groups asg ON asgm.abstractor_subject_group_id = asg.id
WHERE an.name = 'Surgical Pathology'
AND asg.name = 'Metastatic Cancer'
AND aas.display_name = 'Histology'
UNION
SELECT 'Primary CNS Histology' AS classificaiton
      , aov.value            AS data_point_value
      , aov.vocabulary_code
	    , aovv.value           AS data_point_value_synonym
	    , aov.favor_more_specific
FROM abstractor_subjects asb JOIN abstractor_abstraction_schemas aas ON asb.abstractor_abstraction_schema_id = aas.id
                             JOIN abstractor_namespaces an ON asb.namespace_id = an.id AND asb.namespace_type = 'Abstractor::AbstractorNamespace'
                             LEFT JOIN abstractor_abstraction_schema_object_values aasov ON aas.id = aasov.abstractor_abstraction_schema_id
                             LEFT JOIN abstractor_object_values aov ON aasov.abstractor_object_value_id = aov.id
                             LEFT JOIN abstractor_object_value_variants aovv ON aov.id = aovv.abstractor_object_value_id
                             LEFT JOIN abstractor_subject_group_members asgm ON asb.id = asgm.abstractor_subject_id
                             LEFT JOIN abstractor_subject_groups asg ON asgm.abstractor_subject_group_id = asg.id
WHERE an.name = 'Surgical Pathology'
AND asg.name = 'Primary Cancer'
AND aas.display_name = 'Histology'
) data
ORDER BY data.classificaiton, data.vocabulary_code, data.data_point_value,  data.data_point_value_synonym



SELECT *
FROM(
SELECT  'Primary CNS Site' AS classificaiton
      , aov.value            AS data_point_value
      , aov.vocabulary_code
	    , aovv.value           AS data_point_value_synonym
	    , aov.favor_more_specific
FROM abstractor_subjects asb JOIN abstractor_abstraction_schemas aas ON asb.abstractor_abstraction_schema_id = aas.id
                             JOIN abstractor_namespaces an ON asb.namespace_id = an.id AND asb.namespace_type = 'Abstractor::AbstractorNamespace'
                             LEFT JOIN abstractor_abstraction_schema_object_values aasov ON aas.id = aasov.abstractor_abstraction_schema_id
                             LEFT JOIN abstractor_object_values aov ON aasov.abstractor_object_value_id = aov.id
                             LEFT JOIN abstractor_object_value_variants aovv ON aov.id = aovv.abstractor_object_value_id
                             LEFT JOIN abstractor_subject_group_members asgm ON asb.id = asgm.abstractor_subject_id
                             LEFT JOIN abstractor_subject_groups asg ON asgm.abstractor_subject_group_id = asg.id
WHERE an.name = 'Surgical Pathology'
AND asg.name = 'Primary Cancer'
AND aas.display_name = 'Site'
UNION
SELECT 'Primary Site' AS classificaiton
      , aov.value            AS data_point_value
      , aov.vocabulary_code
	    , aovv.value           AS data_point_value_synonym
	    , aov.favor_more_specific
FROM abstractor_subjects asb JOIN abstractor_abstraction_schemas aas ON asb.abstractor_abstraction_schema_id = aas.id
                             JOIN abstractor_namespaces an ON asb.namespace_id = an.id AND asb.namespace_type = 'Abstractor::AbstractorNamespace'
                             LEFT JOIN abstractor_abstraction_schema_object_values aasov ON aas.id = aasov.abstractor_abstraction_schema_id
                             LEFT JOIN abstractor_object_values aov ON aasov.abstractor_object_value_id = aov.id
                             LEFT JOIN abstractor_object_value_variants aovv ON aov.id = aovv.abstractor_object_value_id
                             LEFT JOIN abstractor_subject_group_members asgm ON asb.id = asgm.abstractor_subject_id
                             LEFT JOIN abstractor_subject_groups asg ON asgm.abstractor_subject_group_id = asg.id
WHERE an.name = 'Surgical Pathology'
AND asg.name = 'Metastatic Cancer'
AND aas.display_name = 'Primary Site'
) data
ORDER BY data.classificaiton, data.vocabulary_code, data.data_point_value,  data.data_point_value_synonym

