Feature: Listing abstraction schemas
  User should be able to list abstraction schemas

  @javascript
  Scenario: Viewing a list of abstraction schemas
    Given abstraction schemas are set
    When I go to the abstraction schemas index page
    Then I should see "Anatomical location"
    And I should see "Laterality"
    And I should see "Radiation therapy prescription date"
    And I should see "Karnofsky performance status"
    And I should see "Karnofsky performance status date"
    And I should see "Surgery"
    And I should see "Extent of resection"
    And I should see "Favorite major Moomin character"
    And I should see "Dopamine transporter level"
    And I should see "RECIST response criteria"
    And I should see "Diagnosis"
    And I should see "Score 1"
    And I should see "Score 2"
    And I should see "Falls"
    And I should see "Freezing"
    When I follow "Values" within the last "tr.abstractor_abstraction_schema"
    Then I should be on the the last abstraction schema object values index page
