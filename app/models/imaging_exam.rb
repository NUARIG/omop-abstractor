class ImagingExam < ApplicationRecord
  include Abstractor::Abstractable

  def source_name_method
    "#{accession_number} (#{report_date})"
  end
end