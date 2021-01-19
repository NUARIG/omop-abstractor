class Icdo3Histology < ApplicationRecord
  has_many :icdo3_histology_synonyms
  has_many :icdo3_categorizations, as: :categorizable

  scope :by_primary_cns, -> do
    joins(icdo3_categorizations: :icdo3_category).where('icdo3_histologies.version = ? AND icdo3_histologies.minor_version = ? AND icdo3_categories.category = ?', 'new', 'ICD-O-3.2.csv', 'primary cns histology')
  end

  scope :by_metastasis, -> do
    joins(icdo3_categorizations: :icdo3_category).where('icdo3_histologies.version = ? AND icdo3_histologies.minor_version = ? AND icdo3_categories.category = ?', 'new', 'ICD-O-3.2.csv', 'metastatic histology')
  end

  scope :by_primary_cns_and_icdo3_code_with_synonyms, ->(icdo3_code) do
    joins(icdo3_categorizations: :icdo3_category).joins(:icdo3_histology_synonyms).where('icdo3_histologies.version = ? AND icdo3_histologies.minor_version = ? AND icdo3_categories.category = ? AND icdo3_histologies.icdo3_code = ?', 'new', 'ICD-O-3.2.csv', 'primary cns histology', icdo3_code).select('icdo3_histology_synonyms.icdo3_synonym_description')
  end

  scope :by_metastasis_and_icdo3_code_with_synonyms, ->(icdo3_code) do
    joins(icdo3_categorizations: :icdo3_category).joins(:icdo3_histology_synonyms).where('icdo3_histologies.version = ? AND icdo3_histologies.minor_version = ? AND icdo3_categories.category = ? AND icdo3_histologies.icdo3_code = ?', 'new', 'ICD-O-3.2.csv', 'metastatic histology', icdo3_code).select('icdo3_histology_synonyms.icdo3_synonym_description')
  end
end