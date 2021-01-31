select REGEXP_REPLACE(icdo3_histologies.icdo3_code, '\/', '') AS icdo3_code
     , ','
     , icdo3_histologies.icdo3_description
from icdo3_histologies
where icdo3_histologies.version = 'new'
and icdo3_histologies.minor_version = 'ICD-O-3.2.csv'
and not exists(
  select 1
  from  icdo3_categorizations join icdo3_categories on icdo3_categorizations.icdo3_category_id = icdo3_categories.id
  where icdo3_histologies.id = icdo3_categorizations.categorizable_id
  and icdo3_categorizations.categorizable_type = 'Icdo3Histology'
  and icdo3_categories.category = 'metastatic histology'
)
and icdo3_histologies.icdo3_code like '%/%'
order by icdo3_histologies.icdo3_description



select REGEXP_REPLACE(icdo3_histologies.icdo3_code, '\/', '') AS icdo3_code
     , ','
     , icdo3_histologies.icdo3_description
from icdo3_histologies join icdo3_categorizations on icdo3_histologies.id = icdo3_categorizations.categorizable_id and icdo3_categorizations.categorizable_type = 'Icdo3Histology'
                       join icdo3_categories on icdo3_categorizations.icdo3_category_id = icdo3_categories.id
where icdo3_categories.category = 'metastatic histology'
and icdo3_histologies.version = 'new'
and icdo3_histologies.icdo3_code like '%/%'
order by icdo3_histologies.icdo3_description

select icdo3_sites.icdo3_code
     , icdo3_sites.icdo3_description
from icdo3_sites join icdo3_categorizations on icdo3_sites.id = icdo3_categorizations.categorizable_id and icdo3_categorizations.categorizable_type = 'Icdo3Site'
                 join icdo3_categories      on icdo3_categorizations.icdo3_category_id = icdo3_categories.id
where icdo3_categories.category = 'metastatic histology'
--and icdo3_sites.version = 'new'


select icdo3_sites.icdo3_code
     , ','
     , icdo3_sites.icdo3_description
from icdo3_sites
where icdo3_sites.version = 'new'
order by icdo3_code
