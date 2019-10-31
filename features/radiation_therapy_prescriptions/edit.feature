Feature: Editing radiation therapy prescription
  User should be able to edit radiation therapy prescription information

  @javascript
  Scenario: Editing an abstraction with radio button list
    Given abstraction schemas are set
    And radiation therapy prescriptions with the following information exist
      | Site                                    |
      | Vague blather.                          |
    When I go to the last radiation therapy prescription edit page
    And I click on ".edit_link" within the first ".has_laterality"
    And I wait for the ajax request to finish
    Then I should see "bilateral" within "#abstractor_abstraction_value_bilateral"
    And I choose "left"
    And I press "Save"
    And I wait for the ajax request to finish
    Then the "left" checkbox within "has_laterality" should be checked
    When I go to the last radiation therapy prescription edit page
    Then the "left" checkbox within "has_laterality" should be checked
    When I delete the "bilateral" object value for the "has_laterality" abstraction schema
    When I go to the last radiation therapy prescription edit page
    And I click on ".edit_link" within the first ".has_laterality"
    And I wait for the ajax request to finish
    Then I should not see "bilateral" within "#abstractor_abstraction_value_bilateral"

  @javascript
  Scenario: Adding and removing abstraction groups
    Given abstraction schemas are set
    And radiation therapy prescriptions with the following information exist
      | Site                                    |
      | Vague blather.                          |
    When I go to the last radiation therapy prescription edit page
    Then I should not see "Delete Anatomical Location"
    And I should see "Add Anatomical Location"
    And I wait 3 seconds
    When I do not confirm link "Add Anatomical Location"
    Then I should not see "Delete Anatomical Location"
    When I confirm link "Add Anatomical Location"
    And I wait for the ajax request to finish
    And I should see "Delete Anatomical Location"
    And I should see "unknown" anywhere within the last ".has_anatomical_location"
    And ".abstractor_abstraction_value" in the last ".abstractor_abstraction" should contain selector ".edit_link"
    When I go to the last radiation therapy prescription edit page
    And I should see "Delete Anatomical Location"
    And I should see "unknown" anywhere within the last ".has_anatomical_location"
    When I do not confirm link "Delete Anatomical Location" in the last ".abstractor_abstraction_group"
    Then I should see 2 ".abstractor_abstraction_group" within ".abstractor_subject_groups"
    When I confirm link "Delete Anatomical Location"
    And I wait for the ajax request to finish
    Then I should see 1 ".abstractor_abstraction_group" within ".abstractor_subject_groups"
    And I should see "Add Anatomical Location"
    And I should see "unknown" anywhere within the first ".has_anatomical_location"

  @javascript
  Scenario: Viewing abstraction groups with no suggestions
    Given abstraction schemas are set
    And radiation therapy prescriptions with the following information exist
      | Site                                    |
      | Vague blather.                          |
    When I go to the last radiation therapy prescription edit page
    Then I should see "Anatomical location"
    And I should see "Edit" anywhere within ".has_anatomical_location"
    And I should see "Add Anatomical Location"
    And I should not see "Delete Anatomical Location"
    And I should see "unknown" anywhere within the last ".has_anatomical_location"

  @javascript
  Scenario: Viewing abstraction groups with suggestions
    Given abstraction schemas are set
    And radiation therapy prescriptions with the following information exist
      | Site                                    |
      | right temporal lobe                     |
    When I go to the last radiation therapy prescription edit page
    Then I should see "Anatomical location"
    And the "temporal lobe" checkbox within "has_anatomical_location" should not be checked
    And I should see "Edit" anywhere within ".has_anatomical_location"
    And I should see "Add Anatomical Location"
    And I should not see "Delete Anatomical Location"
    And ".abstractor_suggestion_values" in the first ".has_anatomical_location" should contain text "temporal lobe"

  @javascript
  Scenario: Adding abstraction groups to abstraction groups with suggestions
    Given abstraction schemas are set
    And radiation therapy prescriptions with the following information exist
      | Site                                    |
      | treat the temporal lobe                 |
    When I go to the last radiation therapy prescription edit page
    Then I should see 1 ".abstractor_abstraction_group" rows
    And I confirm link "Add Anatomical Location"
    And I wait for the ajax request to finish
    And ".abstractor_abstraction_actions" in the last ".abstractor_abstraction_group" should contain selector ".abstractor_group_delete_link"
    And ".abstractor_abstraction_actions" in the first ".abstractor_abstraction_group" should not contain selector ".abstractor_group_delete_link"
    And ".abstractor_abstraction_actions" in the last ".abstractor_abstraction_group" should contain selector ".abstractor_group_not_applicable_all_link"
    And ".abstractor_abstraction_actions" in the last ".abstractor_abstraction_group" should contain selector ".abstractor_group_unknown_all_link"
    Then I should see 2 ".abstractor_abstraction_group" rows
    And ".abstractor_suggestion_values" in the first ".has_anatomical_location" should contain text "temporal lobe"
    And ".abstractor_suggestion_values" in the last ".has_anatomical_location" should contain text "temporal lobe"
    And the "temporal lobe" checkbox within the first ".has_anatomical_location" should not be checked
    And the "temporal lobe" checkbox within the last ".has_anatomical_location" should not be checked

  @javascript
  Scenario: User setting the value of an abstraction schema with a date object type in a group
    Given abstraction schemas are set
    And radiation therapy prescriptions with the following information exist
      | Site                                    |
      | Vague blather.                          |
    When I go to the last radiation therapy prescription edit page
    And I click on ".edit_link" within the first ".has_radiation_therapy_prescription_date"
    And I fill in "abstractor_abstraction_value" with "2014-06-03" within ".has_radiation_therapy_prescription_date"
    And I press "Save"
    And I wait for the ajax request to finish
    And the "2014-06-03" checkbox within the last ".has_radiation_therapy_prescription_date" should be checked

  @javascript
  Scenario: User setting all the values to 'not applicable' in an abstraction group
    Given abstraction schemas are set
    And radiation therapy prescriptions with the following information exist
      | Site                                    |
      | Vague blather.                          |
    When I go to the last radiation therapy prescription edit page
    Then I should see "unknown" anywhere within the last ".has_anatomical_location"
    And I should see "unknown" anywhere within the last ".has_laterality"
    And I should see "unknown" anywhere within the last ".has_radiation_therapy_prescription_date"
    And the "abstractor_suggestion[accepted]" checkbox within ".has_anatomical_location" should not be present
    And the "abstractor_suggestion[accepted]" checkbox within ".has_laterality" should not be present
    And the "abstractor_suggestion[accepted]" checkbox within ".has_radiation_therapy_prescription_date" should not be present
    When I do not confirm link "Not applicable group" in the first ".abstractor_abstraction_group"
    And I wait 1 seconds
    Then I should see "unknown" anywhere within the last ".has_anatomical_location"
    And I should see "unknown" anywhere within the last ".has_laterality"
    And I should see "unknown" anywhere within the last ".has_radiation_therapy_prescription_date"
    And the "abstractor_suggestion[accepted]" checkbox within ".has_anatomical_location" should not be present
    And the "abstractor_suggestion[accepted]" checkbox within ".has_laterality" should not be present
    And the "abstractor_suggestion[accepted]" checkbox within ".has_radiation_therapy_prescription_date" should not be present
    When I confirm link "Not applicable group" in the first ".abstractor_abstraction_group"
    And I wait 1 seconds
    Then I should see "not applicable" anywhere within the first ".has_anatomical_location"
    And I should see "not applicable" anywhere within the first ".has_laterality"
    And I should see "not applicable" anywhere within the first ".has_radiation_therapy_prescription_date"
    And the "not applicable" checkbox within the first ".has_anatomical_location" should be checked
    And the "not applicable" checkbox within the first ".has_laterality" should be checked
    And the "not applicable" checkbox within the first ".has_radiation_therapy_prescription_date" should be checked

  @javascript
  Scenario: User setting all the values to 'unknown' in an abstraction group
    Given abstraction schemas are set
    And radiation therapy prescriptions with the following information exist
      | Site                                    |
      | Vague blather.                          |
    When I go to the last radiation therapy prescription edit page
    Then I should see "unknown" anywhere within the last ".has_anatomical_location"
    And I should see "unknown" anywhere within the last ".has_laterality"
    And I should see "unknown" anywhere within the last ".has_radiation_therapy_prescription_date"
    And the "abstractor_suggestion[accepted]" checkbox within ".has_anatomical_location" should not be present
    And the "abstractor_suggestion[accepted]" checkbox within ".has_laterality" should not be present
    And the "abstractor_suggestion[accepted]" checkbox within ".has_radiation_therapy_prescription_date" should not be present
    When I do not confirm link "Unknown group" in the first ".abstractor_abstraction_group"
    And I wait 1 seconds
    Then I should see "unknown" anywhere within the last ".has_anatomical_location"
    And I should see "unknown" anywhere within the last ".has_laterality"
    And I should see "unknown" anywhere within the last ".has_radiation_therapy_prescription_date"
    And the "abstractor_suggestion[accepted]" checkbox within ".has_anatomical_location" should not be present
    And the "abstractor_suggestion[accepted]" checkbox within ".has_laterality" should not be present
    And the "abstractor_suggestion[accepted]" checkbox within ".has_radiation_therapy_prescription_date" should not be present
    When I confirm link "Unknown group" in the first ".abstractor_abstraction_group"
    And I wait 1 seconds
    Then I should see "unknown" anywhere within the first ".has_anatomical_location"
    And I should see "unknown" anywhere within the first ".has_laterality"
    And I should see "unknown" anywhere within the first ".has_radiation_therapy_prescription_date"

  @javascript
  Scenario: Updating the workflowstatus of a group
    Given abstraction schemas are set
    And workflow status is enabled on the "Anatomical Location"  with "Submit" as the submit label and "Remove" as the pend label
    And radiation therapy prescriptions with the following information exist
      | Site                                    |
      | right temporal lobe                     |
    When I go to the last radiation therapy prescription edit page
    Then the ".abstractor_group_update_workflow_status_link_submit" button within the first ".abstractor_abstraction_group" should be present
    And the ".abstractor_group_update_workflow_status_link_submit" button within the first ".abstractor_abstraction_group" should be disabled
    When I check "temporal lobe" within the first ".abstractor_abstraction_group"
    When I check "right" within the first ".abstractor_abstraction_group"
    And I click on ".edit_link" within the first ".has_radiation_therapy_prescription_date"
    And I wait for the ajax request to finish
    And I fill in "abstractor_abstraction_value" with "2014-06-03" within ".has_radiation_therapy_prescription_date"
    And I press "Save"
    And I wait for the ajax request to finish
    And the ".abstractor_group_update_workflow_status_link_submit" button within the first ".abstractor_abstraction_group" should not be disabled
    When I follow "Clear" within the first ".has_anatomical_location"
    And I wait for the ajax request to finish
    Then the ".abstractor_group_update_workflow_status_link_submit" button within the first ".abstractor_abstraction_group" should be disabled
    When I check "temporal lobe" within the first ".abstractor_abstraction_group"
    And I wait for the ajax request to finish
    Then the ".abstractor_group_update_workflow_status_link_submit" button within the first ".abstractor_abstraction_group" should not be disabled
    When I uncheck "temporal lobe" within the first ".abstractor_abstraction_group"
    And I wait for the ajax request to finish
    Then the ".abstractor_group_update_workflow_status_link_submit" button within the first ".abstractor_abstraction_group" should be disabled
    When I check "temporal lobe" within the first ".abstractor_abstraction_group"
    And I wait for the ajax request to finish
    Then the ".abstractor_group_update_workflow_status_link_submit" button within the first ".abstractor_abstraction_group" should not be disabled
    When I press "Submit" within the first ".abstractor_abstraction_group"
    And I wait 1 seconds
    Then the ".abstractor_group_update_workflow_status_link_submit" button within the first ".abstractor_abstraction_group" should not be present
    And the ".abstractor_group_update_workflow_status_link_pend" button within the first ".abstractor_abstraction_group" should be present
    And the ".abstractor_group_update_workflow_status_link_pend" button within the first ".abstractor_abstraction_group" should not be disabled
    And the "abstractor_suggestion[accepted]" checkbox within the first ".has_anatomical_location" should be disabled
    And the "abstractor_suggestion[accepted]" checkbox within the first ".has_laterality" should be disabled
    And the "abstractor_suggestion[accepted]" checkbox within the first ".has_radiation_therapy_prescription_date" should be disabled
    When I press "Remove" within the first ".abstractor_abstraction_group"
    And I wait 1 seconds
    Then the ".abstractor_group_update_workflow_status_link_submit" button within the first ".abstractor_abstraction_group" should be present
    And the ".abstractor_group_update_workflow_status_link_submit" button within the first ".abstractor_abstraction_group" should not be disabled
    And the ".abstractor_group_update_workflow_status_link_pend" button within the first ".abstractor_abstraction_group" should not be present
    When I press "Submit" within the first ".abstractor_abstraction_group"
    And I wait 1 seconds
    Then the ".abstractor_group_update_workflow_status_link_submit" button within the first ".abstractor_abstraction_group" should not be present
    And the ".abstractor_group_update_workflow_status_link_pend" button within the first ".abstractor_abstraction_group" should be present
    And the ".abstractor_group_update_workflow_status_link_pend" button within the first ".abstractor_abstraction_group" should not be disabled
    And the "abstractor_suggestion[accepted]" checkbox within the first ".has_anatomical_location" should be disabled
    And the "abstractor_suggestion[accepted]" checkbox within the first ".has_laterality" should be disabled
    And the "abstractor_suggestion[accepted]" checkbox within the first ".has_radiation_therapy_prescription_date" should be disabled
    When I confirm link "Add Anatomical Location"
    And I wait for the ajax request to finish
    Then the ".abstractor_group_update_workflow_status_link_submit" button within the last ".abstractor_abstraction_group" should be present
    And the ".abstractor_group_update_workflow_status_link_submit" button within the last ".abstractor_abstraction_group" should be disabled
    And the ".abstractor_group_update_workflow_status_link_pend" button within the last ".abstractor_abstraction_group" should not be present

  @javascript
  Scenario: Removing the workflowstatus of a radiation therapy when it is not fully set
    Given abstraction schemas are set
    And workflow status is not enabled on the "Anatomical Location"
    And radiation therapy prescriptions with the following information exist
      | Site                                    |
      | right temporal lobe                     |
    When I go to the last radiation therapy prescription edit page
    When I check "temporal lobe" within the first ".abstractor_abstraction_group"
    When I check "right" within the first ".abstractor_abstraction_group"
    And I click on ".edit_link" within the first ".has_radiation_therapy_prescription_date"
    And I wait for the ajax request to finish
    And I fill in "abstractor_abstraction_value" with "2014-06-03" within ".has_radiation_therapy_prescription_date"
    And I press "Save"
    And I wait for the ajax request to finish
    When I press "Submit" within the first ".abstraction_workflow_status_form"
    And the radiation therapy prescription becomes not fully set
    When I go to the last radiation therapy prescription edit page
    When I press "Remove" within the first ".abstraction_workflow_status_form"
    Then the ".abstractor_update_workflow_status_link" button within the first ".abstraction_workflow_status_form" should be present
    And the ".abstractor_update_workflow_status_link" button within the first ".abstraction_workflow_status_form" should be disabled

  @javascript
  Scenario: User editing an abstraction for a fully set radiation therapy prescription
    Given abstraction schemas are set
    And workflow status is not enabled on the "Anatomical Location"
    And radiation therapy prescriptions with the following information exist
      | Site                                    |
      | right temporal lobe                     |
    When I go to the last radiation therapy prescription edit page
    When I check "temporal lobe" within the first ".abstractor_abstraction_group"
    When I check "right" within the first ".abstractor_abstraction_group"
    And I click on ".edit_link" within the first ".has_radiation_therapy_prescription_date"
    And I wait for the ajax request to finish
    And I fill in "abstractor_abstraction_value" with "2014-06-03" within ".has_radiation_therapy_prescription_date"
    And I press "Save"
    And I wait for the ajax request to finish
    Then the ".abstractor_update_workflow_status_link" button within the first ".abstraction_workflow_status_form" should be present
    And the ".abstractor_update_workflow_status_link" button within the first ".abstraction_workflow_status_form" should not be disabled
    When I click on ".edit_link" within the first ".has_radiation_therapy_prescription_date"
    And I wait for the ajax request to finish
    Then the ".abstractor_update_workflow_status_link" button within the first ".abstraction_workflow_status_form" should be present
    And the ".abstractor_update_workflow_status_link" button within the first ".abstraction_workflow_status_form" should be disabled

  @javascript
  Scenario: Submitting and discarding across an entire radiation therapy prescription
    Given abstraction schemas are set
    And workflow status is enabled on the "Anatomical Location"  with "Submit" as the submit label and "Remove" as the pend label
    And radiation therapy prescriptions with the following information exist
      | Site                                    |
      | right temporal lobe                     |
    When I go to the last radiation therapy prescription edit page
    Then the ".abstractor_update_workflow_status_link_submit" button within the first ".radiation_therapy_prescription_actions" should be present
    And the ".abstractor_update_workflow_status_link_submit" button within the first ".radiation_therapy_prescription_actions" should be disabled
    When I confirm link "Add Anatomical Location"
    And I wait for the ajax request to finish
    When I check "temporal lobe" within the first ".abstractor_abstraction_group"
    When I check "right" within the first ".abstractor_abstraction_group"
    And I click on ".edit_link" within the first ".has_radiation_therapy_prescription_date"
    And I wait for the ajax request to finish
    And I fill in "abstractor_abstraction_value" with "2014-06-03" within the first ".has_radiation_therapy_prescription_date"
    And I press "Save"
    And I wait 1 seconds
    And the ".abstractor_update_workflow_status_link_submit" button within the first ".radiation_therapy_prescription_actions" should be disabled
    When I check "temporal lobe" within the last ".abstractor_abstraction_group"
    When I check "right" within the last ".abstractor_abstraction_group"
    And I click on ".edit_link" within the last ".has_radiation_therapy_prescription_date"
    And I wait for the ajax request to finish
    And I fill in "abstractor_abstraction_value" with "2014-06-03" within the last ".has_radiation_therapy_prescription_date"
    And I press "Save"
    And I wait 1 seconds
    Then the ".abstractor_update_workflow_status_link_submit" button within the first ".radiation_therapy_prescription_actions" should not be disabled
    And I should see "Add Anatomical Location" within the last ".abstractor_abstraction_group"
    When I press "Submit" within the first ".radiation_therapy_prescription_actions"
    And I wait 1 seconds
    Then the ".abstractor_update_workflow_status_link_pend" button within the first ".radiation_therapy_prescription_actions" should be present
    And I should see 0 ".workflow_status_pending" rows
    And I should see 2 ".workflow_status_submitted" rows
    And I should see 0 ".workflow_status_discarded" rows
    And the ".abstractor_update_workflow_status_link_pend" button within the first ".radiation_therapy_prescription_actions" should not be disabled
    And the radiation therapy prescription should be submitted
    And the radiation therapy prescription should not be discarded
    And the "abstractor_suggestion[accepted]" checkbox within the first ".has_anatomical_location" should be disabled
    And the "abstractor_suggestion[accepted]" checkbox within the first ".has_laterality" should be disabled
    And the "abstractor_suggestion[accepted]" checkbox within the first ".has_radiation_therapy_prescription_date" should be disabled
    And the "abstractor_suggestion[accepted]" checkbox within the last ".has_anatomical_location" should be disabled
    And the "abstractor_suggestion[accepted]" checkbox within the last ".has_laterality" should be disabled
    And the "abstractor_suggestion[accepted]" checkbox within the last ".has_radiation_therapy_prescription_date" should be disabled
    And I should not see "Add Anatomical Location" within ".abstractor_abstraction_group"
    When I press "Remove" within the first ".radiation_therapy_prescription_actions"
    And I wait 1 seconds
    Then the ".abstractor_update_workflow_status_link_submit" button within the first ".radiation_therapy_prescription_actions" should be present
    And the ".abstractor_update_workflow_status_link_submit" button within the first ".radiation_therapy_prescription_actions" should not be disabled
    And I should see 2 ".workflow_status_pending" rows
    And I should see 0 ".workflow_status_submitted" rows
    And I should see 0 ".workflow_status_discarded" rows
    And the radiation therapy prescription should not be submitted
    And the radiation therapy prescription should not be discarded
    And the "abstractor_suggestion[accepted]" checkbox within the first ".has_anatomical_location" should not be disabled
    And the "abstractor_suggestion[accepted]" checkbox within the first ".has_laterality" should not be disabled
    And the "abstractor_suggestion[accepted]" checkbox within the first ".has_radiation_therapy_prescription_date" should not be disabled
    And the "abstractor_suggestion[accepted]" checkbox within the last ".has_anatomical_location" should not be disabled
    And the "abstractor_suggestion[accepted]" checkbox within the last ".has_laterality" should not be disabled
    And the "abstractor_suggestion[accepted]" checkbox within the last ".has_radiation_therapy_prescription_date" should not be disabled
    And I should see "Add Anatomical Location" within ".abstractor_abstraction_group"
    When I confirm link "Discard" in the first ".radiation_therapy_prescription_actions"
    And I wait 1 seconds
    Then the radiation therapy prescription should not be submitted
    And the radiation therapy prescription should be discarded
    And I should see 0 ".workflow_status_pending" rows
    And I should see 0 ".workflow_status_submitted" rows
    And I should see 2 ".workflow_status_discarded" rows
    And the "abstractor_suggestion[accepted]" checkbox within the first ".has_anatomical_location" should be disabled
    And the "abstractor_suggestion[accepted]" checkbox within the first ".has_laterality" should be disabled
    And the "abstractor_suggestion[accepted]" checkbox within the first ".has_radiation_therapy_prescription_date" should be disabled
    And the "abstractor_suggestion[accepted]" checkbox within the last ".has_anatomical_location" should be disabled
    And the "abstractor_suggestion[accepted]" checkbox within the last ".has_laterality" should be disabled
    And the "abstractor_suggestion[accepted]" checkbox within the last ".has_radiation_therapy_prescription_date" should be disabled
    And I should not see "Add Anatomical Location" within ".abstractor_abstraction_group"
    When I confirm link "Undiscard" in the first ".radiation_therapy_prescription_actions"
    And I wait 1 seconds
    Then the radiation therapy prescription should not be submitted
    And the radiation therapy prescription should not be discarded
    And I should see 2 ".workflow_status_pending" rows
    And I should see 0 ".workflow_status_submitted" rows
    And I should see 0 ".workflow_status_discarded" rows
    And the "abstractor_suggestion[accepted]" checkbox within the first ".has_anatomical_location" should not be disabled
    And the "abstractor_suggestion[accepted]" checkbox within the first ".has_laterality" should not be disabled
    And the "abstractor_suggestion[accepted]" checkbox within the first ".has_radiation_therapy_prescription_date" should not be disabled
    And the "abstractor_suggestion[accepted]" checkbox within the last ".has_anatomical_location" should not be disabled
    And the "abstractor_suggestion[accepted]" checkbox within the last ".has_laterality" should not be disabled
    And the "abstractor_suggestion[accepted]" checkbox within the last ".has_radiation_therapy_prescription_date" should not be disabled

  @javascript
  Scenario: Editing an abstraction with autocompleter list is smart
    Given abstraction schemas are set
    And radiation therapy prescriptions with the following information exist
      | Site                                    |
      | Vague blather.                          |
    When I go to the last radiation therapy prescription edit page
    And I click on ".edit_link" within the first ".has_anatomical_location"
    And I wait for the ajax request to finish
    And I enter "mouth" into "input.combobox" within the first ".has_anatomical_location"
    And I should see "anterior floor of mouth" within ".ui-autocomplete"
    And I should see "mouth" within the first "ui-autocomplete a strong"
    And I should see "floor of mouth" within ".ui-autocomplete"
    And I should see "floor of mouth, nos" within ".ui-autocomplete"
    And I should see "lateral floor of mouth" within ".ui-autocomplete"
    And I should see "mouth, nos" within ".ui-autocomplete"
    And I should see "other and unspecified parts of mouth" within ".ui-autocomplete"
    And I should see "overlapping lesion of floor of mouth" within ".ui-autocomplete"
    And I should see "overlapping lesion of other and unspecified parts of mouth" within ".ui-autocomplete"
    And I should see "vestibule of mouth" within ".ui-autocomplete"