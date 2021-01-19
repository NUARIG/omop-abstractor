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
and icdo3_histology_synonyms.icdo3_synonym_description not in(
  select icdo3_histology_synonyms.icdo3_synonym_description
  from icdo3_histologies left join icdo3_histology_synonyms on icdo3_histologies.id = icdo3_histology_synonyms.icdo3_histology_id
                         join icdo3_categorizations on icdo3_histologies.id = icdo3_categorizations.categorizable_id and icdo3_categorizations.categorizable_type = 'Icdo3Histology'
                         join icdo3_categories on icdo3_categorizations.icdo3_category_id = icdo3_categories.id
  where icdo3_categories.category = 'metastatic histology'
  and icdo3_histologies.version = 'new'
)
order by icdo3_histologies.version, icdo3_categories.category, icdo3_histologies.icdo3_code, icdo3_histology_synonyms.icdo3_synonym_description
