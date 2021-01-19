SELECT  asg.name             AS data_point_group
      , aas.display_name     AS data_point
      , aov.value            AS data_point_value
FROM abstractor_subjects asb JOIN abstractor_abstraction_schemas aas ON asb.abstractor_abstraction_schema_id = aas.id
                             JOIN abstractor_namespaces an ON asb.namespace_id = an.id AND asb.namespace_type = 'Abstractor::AbstractorNamespace'
                             LEFT JOIN abstractor_abstraction_schema_object_values aasov ON aas.id = aasov.abstractor_abstraction_schema_id
                             LEFT JOIN abstractor_object_values aov ON aasov.abstractor_object_value_id = aov.id
                             LEFT JOIN abstractor_subject_group_members asgm ON asb.id = asgm.abstractor_subject_id
                             LEFT JOIN abstractor_subject_groups asg ON asgm.abstractor_subject_group_id = asg.id
WHERE an.name = 'Surgical Pathology'
ORDER BY aas.id, aov.value


SELECT  asg.name             AS data_point_group
      , aas.display_name     AS data_point
FROM abstractor_subjects asb JOIN abstractor_abstraction_schemas aas ON asb.abstractor_abstraction_schema_id = aas.id
                             JOIN abstractor_namespaces an ON asb.namespace_id = an.id AND asb.namespace_type = 'Abstractor::AbstractorNamespace'
                             LEFT JOIN abstractor_subject_group_members asgm ON asb.id = asgm.abstractor_subject_id
                             LEFT JOIN abstractor_subject_groups asg ON asgm.abstractor_subject_group_id = asg.id
WHERE an.name = 'Surgical Pathology'
ORDER BY aas.id


SELECT  asg.name             AS data_point_group
      , aas.display_name     AS data_point
      , aov.value            AS data_point_value
      , aovv.value           AS data_point_value_synonym
FROM abstractor_subjects asb JOIN abstractor_abstraction_schemas aas ON asb.abstractor_abstraction_schema_id = aas.id
                             JOIN abstractor_namespaces an ON asb.namespace_id = an.id AND asb.namespace_type = 'Abstractor::AbstractorNamespace'
                             LEFT JOIN abstractor_abstraction_schema_object_values aasov ON aas.id = aasov.abstractor_abstraction_schema_id
                             LEFT JOIN abstractor_object_values aov ON aasov.abstractor_object_value_id = aov.id
                             LEFT JOIN abstractor_object_value_variants aovv ON aov.id = aovv.abstractor_object_value_id
                             LEFT JOIN abstractor_subject_group_members asgm ON asb.id = asgm.abstractor_subject_id
                             LEFT JOIN abstractor_subject_groups asg ON asgm.abstractor_subject_group_id = asg.id
WHERE an.name = 'Surgical Pathology'
ORDER BY aas.id, aov.value

--1419
SELECT distinct
        asg.name             AS data_point_group
      , aas.display_name     AS data_point
      , aov.value            AS data_point_value
      , aovv.value           AS data_point_value_synonym
FROM abstractor_subjects asb JOIN abstractor_abstraction_schemas aas ON asb.abstractor_abstraction_schema_id = aas.id
                             JOIN abstractor_namespaces an ON asb.namespace_id = an.id AND asb.namespace_type = 'Abstractor::AbstractorNamespace'
                             LEFT JOIN abstractor_abstraction_schema_object_values aasov ON aas.id = aasov.abstractor_abstraction_schema_id
                             LEFT JOIN abstractor_object_values aov ON aasov.abstractor_object_value_id = aov.id
                             LEFT JOIN abstractor_object_value_variants aovv ON aov.id = aovv.abstractor_object_value_id
                             LEFT JOIN abstractor_subject_group_members asgm ON asb.id = asgm.abstractor_subject_id
                             LEFT JOIN abstractor_subject_groups asg ON asgm.abstractor_subject_group_id = asg.id
WHERE an.name = 'Surgical Pathology'
and aas.display_name = 'Histology'
and asg.name = 'Primary Cancer'
--ORDER BY aas.id, aov.value

SELECT  aovv.value           AS data_point_value_synonym
      , count(*)
FROM abstractor_subjects asb JOIN abstractor_abstraction_schemas aas ON asb.abstractor_abstraction_schema_id = aas.id
                             JOIN abstractor_namespaces an ON asb.namespace_id = an.id AND asb.namespace_type = 'Abstractor::AbstractorNamespace'
                             LEFT JOIN abstractor_abstraction_schema_object_values aasov ON aas.id = aasov.abstractor_abstraction_schema_id
                             LEFT JOIN abstractor_object_values aov ON aasov.abstractor_object_value_id = aov.id
                             LEFT JOIN abstractor_object_value_variants aovv ON aov.id = aovv.abstractor_object_value_id
                             LEFT JOIN abstractor_subject_group_members asgm ON asb.id = asgm.abstractor_subject_id
                             LEFT JOIN abstractor_subject_groups asg ON asgm.abstractor_subject_group_id = asg.id
WHERE an.name = 'Surgical Pathology'
and aas.display_name = 'Histology'
and asg.name = 'Primary Cancer'
group by aovv.value
having count(*) > 1

--1420
select distinct
       ih.icdo3_code
	   , ih.icdo3_description
	   , ihs.icdo3_synonym_description
     , ih.*
from icdo3_histologies ih join icdo3_histology_synonyms ihs on ih.id = ihs.icdo3_histology_id
order by ih.icdo3_code, ih.icdo3_description, ihs.icdo3_synonym_description


 'chordoid glioma of third ventricle'
,'diffuse astrocytoma'
,'epithelioid mpnst'
,'haemangioblastoma'
,'immature teratoma'
,'mature teratoma'
,'medullocytoma'
,'neurolipocytoma'
,'papillary glioneuronal tumor'
,'paraganglioma'

SELECT distinct
        asg.name             AS data_point_group
      , aas.display_name     AS data_point
      , aov.value            AS data_point_value
      , aovv.value           AS data_point_value_synonym
FROM abstractor_subjects asb JOIN abstractor_abstraction_schemas aas ON asb.abstractor_abstraction_schema_id = aas.id
                             JOIN abstractor_namespaces an ON asb.namespace_id = an.id AND asb.namespace_type = 'Abstractor::AbstractorNamespace'
                             LEFT JOIN abstractor_abstraction_schema_object_values aasov ON aas.id = aasov.abstractor_abstraction_schema_id
                             LEFT JOIN abstractor_object_values aov ON aasov.abstractor_object_value_id = aov.id
                             LEFT JOIN abstractor_object_value_variants aovv ON aov.id = aovv.abstractor_object_value_id
                             LEFT JOIN abstractor_subject_group_members asgm ON asb.id = asgm.abstractor_subject_id
                             LEFT JOIN abstractor_subject_groups asg ON asgm.abstractor_subject_group_id = asg.id
WHERE an.name = 'Surgical Pathology'
and aas.display_name = 'Site'
and asg.name = 'Primary Cancer'
--ORDER BY aas.id, aov.value


select distinct
        ist.icdo3_code
      , ist.icdo3_description
      , ists.icdo3_synonym_description
      , ists.*
from icdo3_sites ist join icdo3_site_synonyms ists on ist.id = ists.icdo3_site_id
order by ist.icdo3_code, ist.icdo3_description, ists.icdo3_synonym_description