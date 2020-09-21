class AddAnchorToAbstractorAbstractionGroupMembers < ActiveRecord::Migration[5.2]
  def change
    add_column :abstractor_subject_group_members, :anchor, :boolean
  end
end
