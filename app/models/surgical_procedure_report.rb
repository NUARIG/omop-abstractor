class SurgicalProcedureReport < ApplicationRecord
  def source_name_method
    "#{reference_number} (#{report_date})"
  end
end