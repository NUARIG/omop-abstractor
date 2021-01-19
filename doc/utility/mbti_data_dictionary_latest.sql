



select icdo3_histologies.version
     , icdo3_categories.category
     , icdo3_histologies.version
     , icdo3_histologies.minor_version
     , icdo3_histologies.icdo3_code
     , icdo3_histologies.icdo3_description
     , icdo3_histology_synonyms.icdo3_synonym_description
from icdo3_histologies icdo3_histology_synonyms on icdo3_histologies.id = icdo3_histology_synonyms.icdo3_histology_id
                       join icdo3_categorizations on icdo3_histologies.id = icdo3_categorizations.categorizable_id and icdo3_categorizations.categorizable_type = 'Icdo3Histology'
                       join icdo3_categories on icdo3_categorizations.icdo3_category_id = icdo3_categories.id
where icdo3_categories.category = 'metastatic histology'
and icdo3_histologies.version = 'new'
order by icdo3_histologies.version, icdo3_categories.category, icdo3_histologies.icdo3_code, icdo3_histology_synonyms.icdo3_synonym_description




select icdo3_histologies.version
     , icdo3_categories.category
     , icdo3_histologies.version
     , icdo3_histologies.minor_version
     , icdo3_histologies.icdo3_code
     , icdo3_histologies.icdo3_description
     , icdo3_histology_synonyms.icdo3_synonym_description
from icdo3_histologies left join icdo3_histology_synonyms on icdo3_histologies.id = icdo3_histology_synonyms.icdo3_histology_id
                       join icdo3_categorizations on icdo3_histologies.id = icdo3_categorizations.categorizable_id and icdo3_categorizations.categorizable_type = 'Icdo3Histology'
                       join icdo3_categories on icdo3_categorizations.icdo3_category_id = icdo3_categories.id
where icdo3_categories.category = 'metastatic histology'
and icdo3_histologies.version = 'legacy'
and icdo3_histology_synonyms.icdo3_synonym_description in(
  select icdo3_histology_synonyms.icdo3_synonym_description
  from icdo3_histologies left join icdo3_histology_synonyms on icdo3_histologies.id = icdo3_histology_synonyms.icdo3_histology_id
                         join icdo3_categorizations on icdo3_histologies.id = icdo3_categorizations.categorizable_id and icdo3_categorizations.categorizable_type = 'Icdo3Histology'
                         join icdo3_categories on icdo3_categorizations.icdo3_category_id = icdo3_categories.id
  where icdo3_categories.category = 'metastatic histology'
  and icdo3_histologies.version = 'new'
)
order by icdo3_histologies.version, icdo3_categories.category, icdo3_histologies.icdo3_code, icdo3_histology_synonyms.icdo3_synonym_description






select icdo3_histologies.version
     , icdo3_categories.category
     , icdo3_histologies.version
     , icdo3_histologies.minor_version
     , icdo3_histologies.icdo3_code
     , icdo3_histologies.icdo3_description
from icdo3_histologies join icdo3_categorizations on icdo3_histologies.id = icdo3_categorizations.categorizable_id and icdo3_categorizations.categorizable_type = 'Icdo3Histology'
                       join icdo3_categories on icdo3_categorizations.icdo3_category_id = icdo3_categories.id
where icdo3_categories.category = 'metastatic histology'
and icdo3_histologies.version = 'legacy'
and icdo3_histologies.icdo3_code not in(
  select  icdo3_histologies.icdo3_code
  from icdo3_histologies join icdo3_categorizations on icdo3_histologies.id = icdo3_categorizations.categorizable_id and icdo3_categorizations.categorizable_type = 'Icdo3Histology'
                         join icdo3_categories on icdo3_categorizations.icdo3_category_id = icdo3_categories.id
  where icdo3_categories.category = 'metastatic histology'
  and icdo3_histologies.version = 'new'
)


select icdo3_histologies.version
     , icdo3_categories.category
     , icdo3_histologies.version
     , icdo3_histologies.minor_version
     , icdo3_histologies.icdo3_code
     , icdo3_histologies.icdo3_description
from icdo3_histologies join icdo3_categorizations on icdo3_histologies.id = icdo3_categorizations.categorizable_id and icdo3_categorizations.categorizable_type = 'Icdo3Histology'
                       join icdo3_categories on icdo3_categorizations.icdo3_category_id = icdo3_categories.id
where icdo3_categories.category = 'metastatic histology'
and icdo3_histologies.version = 'legacy'
and icdo3_histologies.icdo3_code not in(
  select  icdo3_histologies.icdo3_code
  from icdo3_histologies join icdo3_categorizations on icdo3_histologies.id = icdo3_categorizations.categorizable_id and icdo3_categorizations.categorizable_type = 'Icdo3Histology'
                         join icdo3_categories on icdo3_categorizations.icdo3_category_id = icdo3_categories.id
  where icdo3_categories.category = 'metastatic histology'
  and icdo3_histologies.version = 'new'
)


order by icdo3_histologies.version, icdo3_categories.category, icdo3_histologies.icdo3_code, icdo3_histology_synonyms.icdo3_synonym_description



select icdo3_histologies.version
     , icdo3_categories.category
     , icdo3_histologies.version
     , icdo3_histologies.minor_version
     , icdo3_histologies.icdo3_code
     , icdo3_histologies.icdo3_description
     , icdo3_histology_synonyms.icdo3_synonym_description
from icdo3_histologies left join icdo3_histology_synonyms on icdo3_histologies.id = icdo3_histology_synonyms.icdo3_histology_id
                       join icdo3_categorizations on icdo3_histologies.id = icdo3_categorizations.categorizable_id and icdo3_categorizations.categorizable_type = 'Icdo3Histology'
                       join icdo3_categories on icdo3_categorizations.icdo3_category_id = icdo3_categories.id
where icdo3_categories.category = 'metastatic histology'
and icdo3_histologies.version = 'new'
order by icdo3_histologies.version, icdo3_categories.category, icdo3_histologies.icdo3_code, icdo3_histology_synonyms.icdo3_synonym_description


select icdo3_histologies.version
     , icdo3_categories.category
     , icdo3_histologies.version
     , icdo3_histologies.minor_version
     , icdo3_histologies.icdo3_code
     , icdo3_histologies.icdo3_description
     , icdo3_histology_synonyms.icdo3_synonym_description
from icdo3_histologies left join icdo3_histology_synonyms on icdo3_histologies.id = icdo3_histology_synonyms.icdo3_histology_id
                       join icdo3_categorizations on icdo3_histologies.id = icdo3_categorizations.categorizable_id and icdo3_categorizations.categorizable_type = 'Icdo3Histology'
                       join icdo3_categories on icdo3_categorizations.icdo3_category_id = icdo3_categories.id
where icdo3_categories.category = 'metastatic histology'
and icdo3_histologies.version = 'new'
order by icdo3_histologies.version, icdo3_categories.category, icdo3_histologies.icdo3_code, icdo3_histology_synonyms.icdo3_synonym_description




select icdo3_histologies.version
     , icdo3_categories.category
     , icdo3_histologies.version
     , icdo3_histologies.minor_version
     , icdo3_histologies.icdo3_code
     , icdo3_histologies.icdo3_description
     , icdo3_histology_synonyms.icdo3_synonym_description
from icdo3_histologies join icdo3_histology_synonyms on icdo3_histologies.id = icdo3_histology_synonyms.icdo3_histology_id
                       join icdo3_categorizations on icdo3_histologies.id = icdo3_categorizations.categorizable_id and icdo3_categorizations.categorizable_type = 'Icdo3Histology'
                       join icdo3_categories on icdo3_categorizations.icdo3_category_id = icdo3_categories.id
where icdo3_categories.category = 'metastatic histology'
order by icdo3_histologies.version, icdo3_categories.category, icdo3_histologies.icdo3_code, icdo3_histology_synonyms.icdo3_synonym_description




"metastatic angiosarcoma"
"metastatic glioblastoma"
"metastatic glioblastoma"
"metastatic leiomyosarcoma"
"metastatic leiomyosarcoma"
"metastatic melanoma"
"metastatic sarcoma"
"metastatic sarcoma"
"metastatic sarcoma"

select icdo3_histologies.version
     , icdo3_categories.category
     , icdo3_histologies.version
     , icdo3_histologies.minor_version
     , icdo3_histologies.icdo3_code
     , icdo3_histologies.icdo3_description
     , icdo3_histology_synonyms.icdo3_synonym_description
from icdo3_histologies join icdo3_histology_synonyms on icdo3_histologies.id = icdo3_histology_synonyms.icdo3_histology_id
                       join icdo3_categorizations on icdo3_histologies.id = icdo3_categorizations.categorizable_id and icdo3_categorizations.categorizable_type = 'Icdo3Histology'
                       join icdo3_categories on icdo3_categorizations.icdo3_category_id = icdo3_categories.id
order by icdo3_histologies.version, icdo3_categories.category, icdo3_histologies.icdo3_code, icdo3_histology_synonyms.icdo3_synonym_description



where icdo3_sites.minor_version = 'icdo3_sites.csv'
and icdo3_site_synonyms.icdo3_synonym_description not in(
select icdo3_site_synonyms.icdo3_synonym_description
from icdo3_sites join icdo3_site_synonyms on icdo3_sites.id = icdo3_site_synonyms.icdo3_site_id
                 join icdo3_categorizations on icdo3_sites.id = icdo3_categorizations.categorizable_id and icdo3_categorizations.categorizable_type = 'Icdo3Site'
                 join icdo3_categories on icdo3_categorizations.icdo3_category_id = icdo3_categories.id
where icdo3_sites.minor_version = 'Topoenglish.csv'
)
order by icdo3_categories.category, icdo3_sites.icdo3_code, icdo3_site_synonyms.icdo3_synonym_description








select icdo3_histologies.icdo3_code
     , icdo3_histologies.icdo3_description
     , icdo3_histology_synonyms.icdo3_synonym_description
     , icdo3_categories.category
from icdo3_histologies join icdo3_histology_synonyms on icdo3_sites.id = icdo3_site_synonyms.icdo3_site_id
                       join icdo3_categorizations on icdo3_sites.id = icdo3_categorizations.categorizable_id and icdo3_categorizations.categorizable_type = 'Icdo3Histology'
                       join icdo3_categories on icdo3_categorizations.icdo3_category_id = icdo3_categories.id
where icdo3_sites.minor_version = 'icdo3_sites.csv'
and icdo3_site_synonyms.icdo3_synonym_description not in(
select icdo3_site_synonyms.icdo3_synonym_description
from icdo3_sites join icdo3_site_synonyms on icdo3_sites.id = icdo3_site_synonyms.icdo3_site_id
                 join icdo3_categorizations on icdo3_sites.id = icdo3_categorizations.categorizable_id and icdo3_categorizations.categorizable_type = 'Icdo3Site'
                 join icdo3_categories on icdo3_categorizations.icdo3_category_id = icdo3_categories.id
where icdo3_sites.minor_version = 'Topoenglish.csv'
)
order by icdo3_categories.category, icdo3_sites.icdo3_code, icdo3_site_synonyms.icdo3_synonym_description















select icdo3_sites.icdo3_code
     , icdo3_sites.icdo3_description
     , icdo3_site_synonyms.icdo3_synonym_description
     , icdo3_categories.category
     , icdo3_sites.version
from icdo3_sites join icdo3_site_synonyms on icdo3_sites.id = icdo3_site_synonyms.icdo3_site_id
                 join icdo3_categorizations on icdo3_sites.id = icdo3_categorizations.categorizable_id and icdo3_categorizations.categorizable_type = 'Icdo3Site'
                 join icdo3_categories on icdo3_categorizations.icdo3_category_id = icdo3_categories.id
where icdo3_sites.minor_version = 'Topoenglish.csv'


select icdo3_sites.icdo3_code
     , icdo3_sites.icdo3_description
     , icdo3_site_synonyms.icdo3_synonym_description
     , icdo3_categories.category
from icdo3_sites join icdo3_site_synonyms on icdo3_sites.id = icdo3_site_synonyms.icdo3_site_id
                 join icdo3_categorizations on icdo3_sites.id = icdo3_categorizations.categorizable_id and icdo3_categorizations.categorizable_type = 'Icdo3Site'
                 join icdo3_categories on icdo3_categorizations.icdo3_category_id = icdo3_categories.id
where icdo3_sites.minor_version = 'icdo3_sites.csv'
and icdo3_site_synonyms.icdo3_synonym_description not in(
select icdo3_site_synonyms.icdo3_synonym_description
from icdo3_sites join icdo3_site_synonyms on icdo3_sites.id = icdo3_site_synonyms.icdo3_site_id
                 join icdo3_categorizations on icdo3_sites.id = icdo3_categorizations.categorizable_id and icdo3_categorizations.categorizable_type = 'Icdo3Site'
                 join icdo3_categories on icdo3_categorizations.icdo3_category_id = icdo3_categories.id
where icdo3_sites.minor_version = 'Topoenglish.csv'
)
order by icdo3_categories.category, icdo3_sites.icdo3_code, icdo3_site_synonyms.icdo3_synonym_description


select icdo3_sites.icdo3_code
     , icdo3_sites.icdo3_description
     , icdo3_site_synonyms.icdo3_synonym_description
     , icdo3_categories.category
from icdo3_sites join icdo3_site_synonyms on icdo3_sites.id = icdo3_site_synonyms.icdo3_site_id
                 join icdo3_categorizations on icdo3_sites.id = icdo3_categorizations.categorizable_id and icdo3_categorizations.categorizable_type = 'Icdo3Site'
                 join icdo3_categories on icdo3_categorizations.icdo3_category_id = icdo3_categories.id
where icdo3_sites.minor_version = 'Topoenglish.csv'
order by icdo3_categories.category, icdo3_sites.icdo3_code, icdo3_site_synonyms.icdo3_synonym_description

order by icdo3_categories.category, icdo3_sites.icdo3_code, icdo3_site_synonyms.icdo3_synonym_description

select icdo3_sites.icdo3_code
     , icdo3_sites.icdo3_description
     , icdo3_site_synonyms.icdo3_synonym_description
     , icdo3_categories.category
from icdo3_sites join icdo3_site_synonyms on icdo3_sites.id = icdo3_site_synonyms.icdo3_site_id
                 join icdo3_categorizations on icdo3_sites.id = icdo3_categorizations.categorizable_id and icdo3_categorizations.categorizable_type = 'Icdo3Site'
                 join icdo3_categories on icdo3_categorizations.icdo3_category_id = icdo3_categories.id
where icdo3_sites.minor_version = 'Topoenglish.csv'
order by icdo3_categories.category, icdo3_sites.icdo3_code, icdo3_site_synonyms.icdo3_synonym_description



select icdo3_sites.icdo3_code
     , icdo3_sites.icdo3_description
     , icdo3_site_synonyms.icdo3_synonym_description
from icdo3_sites join icdo3_site_synonyms on icdo3_sites.id = icdo3_site_synonyms.icdo3_site_id
where icdo3_sites.minor_version = 'Topoenglish.csv'
order by icdo3_sites.icdo3_code, icdo3_site_synonyms.icdo3_synonym_description



select icdo3_sites.icdo3_code
     , icdo3_sites.icdo3_description
from icdo3_sites
where icdo3_sites.minor_version = 'icdo3_sites.csv'
order by icdo3_sites.icdo3_description

select icdo3_sites.icdo3_code
     , icdo3_sites.icdo3_description
from icdo3_sites
where icdo3_sites.minor_version = 'Topoenglish.csv'
order by icdo3_sites.icdo3_description





select icdo3_sites.icdo3_code
     , icdo3_sites.icdo3_description
from icdo3_sites join icdo3_site_synonyms on icdo3_sites.id = icdo3_site_synonyms.icdo3_site_id
where icdo3_sites.minor_version = 'icdo3_sites.csv'
order by icdo3_sites.icdo3_description





select icdo3_histologies.icdo3_code
     , icdo3_histologies.icdo3_description
from icdo3_histologies join icdo3_categorizations on icdo3_histologies.id = icdo3_categorizations.categorizable_id and icdo3_categorizations.categorizable_type = 'Icdo3Histology'
                       join icdo3_categories on icdo3_categorizations.icdo3_category_id = icdo3_categories.id
where icdo3_histologies.minor_version = 'ICD-O-3.2.csv'
order by icdo3_histologies.icdo3_description



Moved to /3

SELECT distinct     aov.vocabulary_code
                  , aov.value            AS data_point_value
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
and aov.value not like '%/%'
order by aov.vocabulary_code, aov.value



SELECT distinct
        asg.name             AS data_point_group
      , aas.display_name     AS data_point
      , aov.value            AS data_point_value
      , aas.*
FROM abstractor_subjects asb JOIN abstractor_abstraction_schemas aas ON asb.abstractor_abstraction_schema_id = aas.id
                             JOIN abstractor_namespaces an ON asb.namespace_id = an.id AND asb.namespace_type = 'Abstractor::AbstractorNamespace'
                             LEFT JOIN abstractor_abstraction_schema_object_values aasov ON aas.id = aasov.abstractor_abstraction_schema_id
                             LEFT JOIN abstractor_object_values aov ON aasov.abstractor_object_value_id = aov.id
                             LEFT JOIN abstractor_subject_group_members asgm ON asb.id = asgm.abstractor_subject_id
                             LEFT JOIN abstractor_subject_groups asg ON asgm.abstractor_subject_group_id = asg.id
WHERE an.name = 'Surgical Pathology'
and aas.display_name = 'Histology'
and asg.name = 'Primary Cancer'
--ORDER BY aas.id, aov.value



select icdo3_histologies.icdo3_code
     , icdo3_histologies.icdo3_description
from icdo3_histologies join icdo3_categorizations on icdo3_histologies.id = icdo3_categorizations.categorizable_id and icdo3_categorizations.categorizable_type = 'Icdo3Histology'
                       join icdo3_categories on icdo3_categorizations.icdo3_category_id = icdo3_categories.id
where icdo3_histologies.minor_version = 'ICD-O-3.2.csv'
order by icdo3_histologies.icdo3_description



already
glioma, malignant   9380/3              brainstem glioma
chordoma, nos       9370/3              chordoma
glioma, malignant   9380/3              glioma
glioma, malignant   9380/3              optic nerve glioma
pineoblastoma       9362/3              pineal tumor of intermediate differentiation


add custom
colloid cyst
epidermoid
gliosis
gliosis-epilepsy
no evidence of tumor
primary intraocular lymphoma
radiation necrosis

add categorization
dysembryoplastic neuroepithelial tumor 9413/0               desmoplastic neuroectodermal tumor
nerve sheath tumor, nos                9563/0               nerve sheath tumor
retinoblastoma, nos                    9510/3               retinoblastoma


SELECT distinct
        asg.name             AS data_point_group
      , aas.display_name     AS data_point
      , aov.value            AS data_point_value
      , aovv.value           AS data_point_value_synonym
      , aas.*
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



select icdo3_histologies.icdo3_code
     , icdo3_histologies.icdo3_description
	   , icdo3_histology_synonyms.icdo3_synonym_description
from icdo3_histologies join icdo3_categorizations on icdo3_histologies.id = icdo3_categorizations.categorizable_id and icdo3_categorizations.categorizable_type = 'Icdo3Histology'
                       join icdo3_categories on icdo3_categorizations.icdo3_category_id = icdo3_categories.id
                       left join icdo3_histology_synonyms on icdo3_histologies.id = icdo3_histology_synonyms.icdo3_histology_id
where icdo3_histologies.minor_version = 'ICD-O-3.2.csv'
order by icdo3_histologies.icdo3_description

select *
from icdo3_histologies join icdo3_categorizations on icdo3_histologies.id = icdo3_categorizations.categorizable_id and icdo3_categorizations.categorizable_type = 'Icdo3Histology'
                       join icdo3_categories on icdo3_categorizations.icdo3_category_id = icdo3_categories.id
                       left join icdo3_histology_synonyms on icdo3_histologies.id = icdo3_histology_synonyms.icdo3_histology_id
where icdo3_histologies.minor_version = 'ICD-O-3.2.csv'
order by icdo3_histologies.icdo3_description



select *
from icdo3_histologies join icdo3_categorizations on icdo3_histologies.id = icdo3_categorizations.categorizable_id and icdo3_categorizations.categorizable_type = 'Icdo3Histology'
                       join icdo3_categories on icdo3_categorizations.icdo3_category_id = icdo3_categories.id
where icdo3_histologies.minor_version = 'ICD-O-3.2.csv'



select distinct ih.icdo3_code
from icdo3_histologies ih
where ih.minor_version = 'the_2016_world_health_organization_classification_of_tumors_of_the_central_nervous_system.csv'
and ih.icdo3_code in(
  select ih2.icdo3_code ih2
  from icdo3_histologies ih2
  where ih2.minor_version = 'ICD-O-3.2.csv'
)
order by ih.icdo3_code





select distinct ih.icdo3_code
from icdo3_histologies ih
where ih.minor_version = 'the_2016_world_health_organization_classification_of_tumors_of_the_central_nervous_system.csv'
and ih.icdo3_code in(
  select ih2.icdo3_code ih2
  from icdo3_histologies ih2
  where ih2.minor_version = 'ICD-O-3.2.csv'
)
order by ih.icdo3_code


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
ORDER BY aov.value, aovv.value

--1419
SELECT distinct
                aov.value            AS data_point_value
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
ORDER BY aov.value, aovv.value


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


select distinct
       ih.version
     , ih.minor_version
     , ih.icdo3_code
	   , ih.icdo3_description
	   , ihs.icdo3_synonym_description
     , ih.*
from icdo3_histologies ih join icdo3_histology_synonyms ihs on ih.id = ihs.icdo3_histology_id
where ih.icdo3_code = '8074/3'
order by ih.version, ih.minor_version, ih.icdo3_code, ih.icdo3_description, ihs.icdo3_synonym_description


--1420
select distinct
       ih.icdo3_description
	   , ihs.icdo3_synonym_description
from icdo3_histologies ih join icdo3_histology_synonyms ihs on ih.id = ihs.icdo3_histology_id
order by ih.icdo3_description, ihs.icdo3_synonym_description


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


select distinct
      ih.icdo3_code
    , ih.icdo3_description
    , ihs.icdo3_synonym_description
    , ih.*
from icdo3_histologies ih join icdo3_histology_synonyms ihs on ih.id = ihs.icdo3_histology_id
where ih.version = 'WHO 2016'
order by ih.icdo3_code, ih.icdo3_description, ihs.icdo3_synonym_description

select ih.*
from icdo3_histologies ih
where ih.version = 'WHO 2016'
and ih.icdo3_code in(
  select ih2.icdo3_code ih2
  from icdo3_histologies ih2
  where ih2.version = 'legacy'
)
order by ih.icdo3_code, ih.icdo3_description


221

select ih.*
from icdo3_histologies ih
where ih.version = 'legacy'
and ih.icdo3_code not in(
  select ih2.icdo3_code ih2
  from icdo3_histologies ih2
  where ih2.version = 'WHO 2016'
)
order by ih.icdo3_code, ih.icdo3_description


select distinct
       ih.version
     , ih.minor_version
     , ih.icdo3_code
	   , ih.icdo3_description
	   , ihs.icdo3_synonym_description
     , ih.*
from icdo3_histologies ih join icdo3_histology_synonyms ihs on ih.id = ihs.icdo3_histology_id
where ih.icdo3_code = '8074/3'
order by ih.version, ih.minor_version, ih.icdo3_code, ih.icdo3_description, ihs.icdo3_synonym_description