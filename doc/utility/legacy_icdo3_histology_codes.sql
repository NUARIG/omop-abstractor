SELECT distinct     aov.vocabulary_code  AS icdo3_code
                  , aov.value            AS icdo3_description
FROM abstractor_subjects asb JOIN abstractor_abstraction_schemas aas ON asb.abstractor_abstraction_schema_id = aas.id
                             JOIN abstractor_namespaces an ON asb.namespace_id = an.id AND asb.namespace_type = 'Abstractor::AbstractorNamespace'
                             LEFT JOIN abstractor_abstraction_schema_object_values aasov ON aas.id = aasov.abstractor_abstraction_schema_id
                             LEFT JOIN abstractor_object_values aov ON aasov.abstractor_object_value_id = aov.id
                             LEFT JOIN abstractor_subject_group_members asgm ON asb.id = asgm.abstractor_subject_id
                             LEFT JOIN abstractor_subject_groups asg ON asgm.abstractor_subject_group_id = asg.id
WHERE an.name = 'Surgical Pathology'
and aas.display_name = 'Histology'
and asg.name = 'Primary Cancer'
and aov.vocabulary_code not in(
  select icdo3_histologies.icdo3_code
  from icdo3_histologies join icdo3_categorizations on icdo3_histologies.id = icdo3_categorizations.categorizable_id and icdo3_categorizations.categorizable_type = 'Icdo3Histology'
                         join icdo3_categories on icdo3_categorizations.icdo3_category_id = icdo3_categories.id
  where icdo3_histologies.minor_version = 'ICD-O-3.2.csv'
)
and aov.vocabulary_code in(
  select icdo3_histologies.icdo3_code
  from icdo3_histologies
  where icdo3_histologies.minor_version = 'ICD-O-3.2.csv'
)
and aov.value like '%/%'
order by aov.vocabulary_code, aov.value



SELECT distinct     aov.vocabulary_code  AS icdo3_code
                  , aov.value            AS icdo3_description
FROM abstractor_subjects asb JOIN abstractor_abstraction_schemas aas ON asb.abstractor_abstraction_schema_id = aas.id
                             JOIN abstractor_namespaces an ON asb.namespace_id = an.id AND asb.namespace_type = 'Abstractor::AbstractorNamespace'
                             LEFT JOIN abstractor_abstraction_schema_object_values aasov ON aas.id = aasov.abstractor_abstraction_schema_id
                             LEFT JOIN abstractor_object_values aov ON aasov.abstractor_object_value_id = aov.id
                             LEFT JOIN abstractor_subject_group_members asgm ON asb.id = asgm.abstractor_subject_id
                             LEFT JOIN abstractor_subject_groups asg ON asgm.abstractor_subject_group_id = asg.id
WHERE an.name = 'Surgical Pathology'
and aas.display_name = 'Histology'
and asg.name = 'Primary Cancer'
and aov.vocabulary_code not in(
  select icdo3_histologies.icdo3_code
  from icdo3_histologies join icdo3_categorizations on icdo3_histologies.id = icdo3_categorizations.categorizable_id and icdo3_categorizations.categorizable_type = 'Icdo3Histology'
                         join icdo3_categories on icdo3_categorizations.icdo3_category_id = icdo3_categories.id
  where icdo3_histologies.minor_version = 'ICD-O-3.2.csv'
)
and aov.vocabulary_code not in(
  select icdo3_histologies.icdo3_code
  from icdo3_histologies
  where icdo3_histologies.minor_version = 'ICD-O-3.2.csv'
)
and aov.value like '%/%'
order by aov.vocabulary_code, aov.value


vocabulary_code	data_point_value
8680/1	paraganglioma (8680/1)	                                  Moved to /3
8693/1	paraganglioma (8693/1)	                                  Moved to /3
8700/0	pheochromocytoma (8700/0)	                                Moved to /3
8991/0	spindle cell oncocytoma of the adenohypophysis (8991/0)	  ?	yes
9133/1	epithelioid hemangioendothelioma (9133/1)	                Moved to /3
9150/1	hemangiopericytoma (9150/1)	?	                            no
9150/3	anaplastic hemangiopericytoma (9150/3)	                  ?	yes
9530/1	meningiomatosis (9530/1)	                                deleted