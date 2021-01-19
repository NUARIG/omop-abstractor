select icdo3_categories.category
     , icdo3_sites.icdo3_code
     , icdo3_sites.icdo3_description
     , icdo3_site_synonyms.icdo3_synonym_description
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
and length(icdo3_sites.icdo3_code) != 3
and icdo3_site_synonyms.icdo3_synonym_description not like '%, nos%'
order by icdo3_categories.category, icdo3_sites.icdo3_code, icdo3_site_synonyms.icdo3_synonym_description
