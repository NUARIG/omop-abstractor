class Icdo3Site < ApplicationRecord
  has_many :icdo3_site_synonyms
  has_many :icdo3_categorizations, as: :categorizable

  scope :by_primary_cns, -> do
    joins(icdo3_categorizations: :icdo3_category).where('icdo3_sites.version = ? AND icdo3_sites.minor_version = ? AND icdo3_categories.category = ?', 'new', 'Topoenglish.csv', 'primary cns site')
  end

  scope :by_primary, -> do
    joins(icdo3_categorizations: :icdo3_category).where('icdo3_sites.version = ? AND icdo3_sites.minor_version = ? AND icdo3_categories.category = ?', 'new', 'Topoenglish.csv', 'primary site')
  end

  scope :by_primary_cns_and_icdo3_code_with_synonyms, ->(icdo3_code) do
    joins(icdo3_categorizations: :icdo3_category).joins(:icdo3_site_synonyms).where('icdo3_sites.version = ? AND icdo3_sites.minor_version = ? AND icdo3_categories.category = ? AND icdo3_sites.icdo3_code = ?', 'new', 'Topoenglish.csv', 'primary cns site', icdo3_code).select('icdo3_site_synonyms.icdo3_synonym_description')
  end

  scope :by_primary_and_icdo3_code_with_synonyms, ->(icdo3_code) do
    joins(icdo3_categorizations: :icdo3_category).joins(:icdo3_site_synonyms).where('icdo3_sites.version = ? AND icdo3_sites.minor_version = ? AND icdo3_categories.category = ? AND icdo3_sites.icdo3_code = ?', 'new', 'Topoenglish.csv', 'primary site', icdo3_code).select('icdo3_site_synonyms.icdo3_synonym_description')
  end

  scope :by_icdo3_code_with_synonyms, ->(icdo3_code) do
    joins(:icdo3_site_synonyms).where('icdo3_sites.version = ? AND icdo3_sites.minor_version = ? AND icdo3_sites.icdo3_code = ?', 'new', 'Topoenglish.csv', icdo3_code).select('icdo3_site_synonyms.icdo3_synonym_description')
  end
end