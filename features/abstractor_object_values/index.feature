Feature: Listing and searching abstractor object values
  User should be able to list and search for abstractor object values

  @javascript
  Scenario: Viewing and searching a list of abstractor object values
    Given abstraction schemas are set
    When I go to the abstraction schemas index page
    And I follow "Values" within the "Anatomical location" schema
    Then I should see the first 10 "Anatomical location" abstractor object values
    When I fill in "Search" with "abdomen"
    And I press "Search"
    Then I should see the following "Anatomical location" abstractor object values
      | Value                                                               | Vocabulary Code                                             |
      | abdomen, nos                                                        | abdomen, nos                                                |
      | connective, subcutaneous and other soft tissues of abdomen          | connective, subcutaneous and other soft tissues of abdomen  |
      | peripheral nerves and autonomic nervous system of abdomen           | peripheral nerves and autonomic nervous system of abdomen   |

  @javascript
  Scenario: Deleting an abstractor object value
    Given abstraction schemas are set
    When I go to the abstraction schemas index page
    And I follow "Values" within the "Anatomical location" schema
    Then I should see the first 10 "Anatomical location" abstractor object values
    When I fill in "Search" with "abdomen"
    And I press "Search"
    Then I should see the following "Anatomical location" abstractor object values
      | Value                                                               | Vocabulary Code                                             |
      | abdomen, nos                                                        | abdomen, nos                                                |
      | connective, subcutaneous and other soft tissues of abdomen          | connective, subcutaneous and other soft tissues of abdomen  |
      | peripheral nerves and autonomic nervous system of abdomen           | peripheral nerves and autonomic nervous system of abdomen   |
    When I follow "Delete" within the first ".abstractor_object_value" and accept confirm
    When I fill in "Search" with "abdomen"
    And I press "Search"
    Then I should see the following "Anatomical location" abstractor object values
      | Value                                                               | Vocabulary Code                                             |
      | connective, subcutaneous and other soft tissues of abdomen          | connective, subcutaneous and other soft tissues of abdomen  |
      | peripheral nerves and autonomic nervous system of abdomen           | peripheral nerves and autonomic nervous system of abdomen   |
