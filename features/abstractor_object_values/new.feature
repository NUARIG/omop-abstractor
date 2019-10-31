Feature: Adding an abstractor object value
  User should be able to add an abstractor object value

  @javascript
  Scenario: Adding an abstractor object value
    Given abstraction schemas are set
    When I go to the abstraction schemas index page
    And I follow "Values" within the "Anatomical location" schema
    And I follow "New"
    And I fill in "Value" with "moomin"
    And I fill in "Vocabulary Code" with "moomin code"
    And I check "Case Sensitive?"
    And I fill in "Comments" with "moomin comments"
    And I follow "Add variant"
    And I fill in "Variant Value" with "moomin variant"
    And I check "Case Sensitive?" within the first ".abstractor_object_value_variant"
    And I press "Save"
    When I fill in "Search" with "moomin"
    And I press "Search"
    Then I should see the following "Anatomical location" abstractor object values
      | Value   | Vocabulary Code |
      | moomin  | moomin code     |
    When I follow "Edit" within the first ".abstractor_object_value"
    Then the "Value" field should not be disabled and contain the value "moomin"
    And the "Vocabulary Code" field should not be disabled and contain the value "moomin code"
    And the "Comments" field should not be disabled and contain the value "moomin comments"
    And "#abstractor_object_value_case_sensitive" should be checked
    And I should see the following variants
      | Variant Value                                                       | Case Sensitve? | Disabled |
      | moomin variant                                                      | yes            | no       |

  @javascript
  Scenario: Adding an abstractor object value with validation
    Given abstraction schemas are set
    When I go to the abstraction schemas index page
    And I follow "Values" within the "Anatomical location" schema
    And I follow "New"
    And I follow "Add variant"
    And I press "Save"
    Then "Value" field should display the error message "can't be blank"
    And "Vocabulary Code" field should display the error message "can't be blank"
    And the Variant Values "Value" field should display the error message "can't be blank"