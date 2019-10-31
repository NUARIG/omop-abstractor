Feature: Editing encounter note
  User should be able to edit encounter note information

  @javascript
  Scenario: Viewing an abstraction with an actual suggestion
    Given abstraction schemas are set
    And encounter notes with the following information exist
      | Note Text                               |
      | Looking good. KPS: 100 |
    When I go to the last encounter note edit page
    Then I should see "Karnofsky performance status"
    And the "100" checkbox within ".has_karnofsky_performance_status" should not be checked
    And the "2014-06-26" checkbox within ".has_karnofsky_performance_status_date" should not be checked
    And I should see "Edit" anywhere within ".has_karnofsky_performance_status"
    And I should see "Edit" anywhere within ".has_karnofsky_performance_status_date"
    And I should see "Clear" anywhere within ".has_karnofsky_performance_status"
    And I should see "Clear" anywhere within ".has_karnofsky_performance_status_date"
    And ".custom_explanation .explanation_text" in the first ".has_karnofsky_performance_status_date" should contain text "A bit of custom logic."

  @javascript
  Scenario: Viewing an abstraction with an unknown suggestion
    Given abstraction schemas are set
    And encounter notes with the following information exist
      | Note Text                               |
      | Hello, I have no idea what is your KPS. |
    When I go to the last encounter note edit page
    Then I should see "Karnofsky performance status"
    And the "abstractor_suggestion[accepted]" checkbox within ".has_karnofsky_performance_status" should not be present
    And I should see "unknown" anywhere within ".has_karnofsky_performance_status"
    And the "2014-06-26" checkbox within ".has_karnofsky_performance_status_date" should not be checked
    And I should see "Edit" anywhere within ".has_karnofsky_performance_status"
    And I should see "Edit" anywhere within ".has_karnofsky_performance_status_date"
    And I should see "Clear" anywhere within ".has_karnofsky_performance_status"
    And I should see "Clear" anywhere within ".has_karnofsky_performance_status_date"
    And ".custom_explanation .explanation_text" in the first ".has_karnofsky_performance_status_date" should contain text "A bit of custom logic."

  @javascript
  Scenario: Accepting a suggestion for an abstraction
    Given abstraction schemas are set
    And encounter notes with the following information exist
      | Note Text              |
      | Looking good. KPS: 100 |
    When I go to the last encounter note edit page
    When I check "100" within ".has_karnofsky_performance_status"
    And I go to the last encounter note edit page
    Then I should see "Karnofsky performance status"
    And the "100" checkbox within ".has_karnofsky_performance_status" should be checked
    And ".abstractor_suggestion_values" in the first ".abstractor_abstraction" should contain text "100% - Normal; no complaints; no evidence of disease."
    And I should see "Edit" anywhere within ".has_karnofsky_performance_status"
    And I should see "Clear" anywhere within ".has_karnofsky_performance_status"

  @javascript
  Scenario: Accepting a suggestion for an abstraction having multiple suggestions
    Given abstraction schemas are set
    And encounter notes with the following information exist
      | Note Text              |
      | Looking good. KPS: 90.  I recommended an appointment in 6 months.  I hope his kps will be 100 then. |
    When I go to the last encounter note edit page
    And I check "100" within ".has_karnofsky_performance_status"
    And I go to the last encounter note edit page
    Then I should see "Karnofsky performance status"
    And the "100" checkbox within ".has_karnofsky_performance_status" should be checked
    And I should see "Edit" anywhere within ".has_karnofsky_performance_status"
    And I should see "Clear" anywhere within ".has_karnofsky_performance_status"
    When I go to the last encounter note edit page
    And I check "90" within ".has_karnofsky_performance_status"
    And I go to the last encounter note edit page
    Then I should see "Karnofsky performance status"
    And the "90" checkbox within ".has_karnofsky_performance_status" should be checked
    And the "100" checkbox within ".has_karnofsky_performance_status" should not be checked

  @javascript
  Scenario:  Editing an abstraction with an actual suggestion
    Given abstraction schemas are set
    And encounter notes with the following information exist
      | Note Text                               |
      | Looking good. KPS: 100 |
    When I go to the last encounter note edit page
    Then I should see "Karnofsky performance status"
    And I follow "Edit" within ".has_karnofsky_performance_status"
    And I wait for the ajax request to finish
    And I fill in "input.combobox" autocompleter within the first ".abstractor_abstraction" with "60% - Requires occasional assistance, but is able to care for most of his personal needs."
    And I press "Save"
    When I go to the last encounter note edit page
    And the "60" checkbox within ".has_karnofsky_performance_status" should be checked

  @javascript
  Scenario: Editing an abstraction with an unknown suggestion
    Given abstraction schemas are set
    And encounter notes with the following information exist
      | Note Text                               |
      | Hello, I have no idea what is your KPS. |
    When I go to the last encounter note edit page
    Then I should see "Karnofsky performance status"
    And I should see "unknown" anywhere within ".has_karnofsky_performance_status"
    When I follow "Edit" within ".has_karnofsky_performance_status"
    And I wait for the ajax request to finish
    And I fill in "input.combobox" autocompleter within the first ".abstractor_abstraction" with "60% - Requires occasional assistance, but is able to care for most of his personal needs."
    And I press "Save"
    And I go to the last encounter note edit page
    Then the "60" checkbox within ".has_karnofsky_performance_status" should be checked
    When I follow "Edit" within ".has_karnofsky_performance_status"
    And I wait for the ajax request to finish
    And I follow "Cancel" within ".has_karnofsky_performance_status"
    And I wait for the ajax request to finish
    Then the "60" checkbox within ".has_karnofsky_performance_status" should be checked

  @javascript
  Scenario: Viewing source for suggestion with source and match value
    Given abstraction schemas are set
    And encounter notes with the following information exist
      | Note Text                            |
      |The patient is looking good.  KPS: 100|
    And I go to the last encounter note edit page
    And I click within ".has_karnofsky_performance_status span.abstractor_abstraction_source_tooltip_img"
    Then I should see an "[style*='background-color: yellow;']" element
    When I click within ".has_karnofsky_performance_status span.abstractor_abstraction_source_tooltip_img"
    Then I should not see an "[style*='background-color: yellow;']" element
    When I click within ".has_karnofsky_performance_status span.abstractor_abstraction_source_tooltip_img"
    And ".abstractor_source_tab label" should contain text "Encounter Note: Note text"
    And ".abstractor_source_tab_content" should contain text "The patient is looking good.  KPS: 100"
    And ".abstractor_source_tab_content" should equal highlighted text "KPS: 100"

  @javascript
  Scenario: Viewing source for suggestion with source containing characters needing to be escaped and match value
    Given abstraction schemas are set
    And encounter notes with the following information exist
      | Note Text                            |
      |The patient is looking good & fit. Much > than I would have thought.  KPS: 100|
    And I go to the last encounter note edit page
    And I click within ".has_karnofsky_performance_status span.abstractor_abstraction_source_tooltip_img"
    Then I should see an "[style*='background-color: yellow;']" element
    And ".abstractor_source_tab label" should contain text "Encounter Note: Note text"
    And ".abstractor_source_tab_content" should contain text "The patient is looking good & fit. Much > than I would have thought.  KPS: 100"
    And ".abstractor_source_tab_content" should equal highlighted text "KPS: 100"

  @javascript
  Scenario: Viewing source for suggestion with a source and no match value
    Given abstraction schemas are set
    And encounter notes with the following information exist
      | Note Text                                |
      |Hello, your KPS is something. Have a great day!|
    When I go to the last encounter note edit page
    Then I should see 0 "span.abstractor_abstraction_source_tooltip_img" within the first ".has_karnofsky_performance_status"
    And ".abstractor_source_tab label" should contain text "Encounter Note: Note text"
    And ".abstractor_source_tab_content" should contain text "Hello, your KPS is something. Have a great day!"

  @javascript
  Scenario: Viewing source for suggestion with source containing characters needing to be escaped and no match value
    Given abstraction schemas are set
    And encounter notes with the following information exist
      | Note Text                                |
      |The patient is looking good & fit. Much > than I would have thought. The KPS is something. Have a great day!|
    When I go to the last encounter note edit page
    Then I should see 0 "span.abstractor_abstraction_source_tooltip_img" within the first ".has_karnofsky_performance_status"
    And ".abstractor_source_tab label" should contain text "Encounter Note: Note text"
    And ".abstractor_source_tab_content" should contain text "The patient is looking good & fit. Much > than I would have thought. The KPS is something. Have a great day!"

  @javascript
  Scenario: Viewing source for suggestion with source and multiple match values
    Given abstraction schemas are set
    And encounter notes with the following information exist
      | Note Text                                                  |
      |Hello, your KPS is 100%. Have a great day! Yes, KPS is 100%! And then I elaborated.  KPS: 100.|
    And I go to the last encounter note edit page
    And I click on "i" within the first ".has_karnofsky_performance_status span.abstractor_abstraction_source_tooltip_img"
    And ".abstractor_source_tab label" should contain text "Encounter Note: Note text"
    And ".abstractor_source_tab_content" should contain text "Hello, your KPS is 100%. Have a great day! Yes, KPS is 100%!"
    And ".abstractor_source_tab_content" should equal highlighted text "Hello, your KPS is 100%."
    And ".abstractor_source_tab_content" should equal highlighted text "Yes, KPS is 100%!"
    And ".abstractor_source_tab_content" should equal highlighted text "KPS: 100"

  @javascript
  Scenario: User clearing an abstraction
    Given abstraction schemas are set
    And encounter notes with the following information exist
      | Note Text              |
      |Hello, your KPS is 100%.|
    When I go to the last encounter note edit page
    And I check "100" within ".has_karnofsky_performance_status"
    And I wait for the ajax request to finish
    And I go to the last encounter note edit page
    Then I should see "Karnofsky performance status"
    And the "100" checkbox within ".has_karnofsky_performance_status" should be checked
    When I follow "Clear" within ".has_karnofsky_performance_status"
    And I wait for the ajax request to finish
    And the "100" checkbox within ".has_karnofsky_performance_status" should not be checked
    When I follow "Edit" within ".has_karnofsky_performance_status"
    And I wait for the ajax request to finish
    And I fill in "input.combobox" autocompleter within the first ".abstractor_abstraction" with "60% - Requires occasional assistance, but is able to care for most of his personal needs."
    And I press "Save"
    And I wait for the ajax request to finish
    When I go to the last encounter note edit page
    Then the "60" checkbox within ".has_karnofsky_performance_status" should be checked
    When I follow "Clear" within ".has_karnofsky_performance_status"
    And I wait for the ajax request to finish
    Then the "60" checkbox within ".has_karnofsky_performance_status" should not be present
    And the "100" checkbox within ".has_karnofsky_performance_status" should be present

  @javascript
  Scenario: User creating abstraction when matching suggestion exists
    Given abstraction schemas are set
    And encounter notes with the following information exist
      | Note Text                            |
      | Hello, you look good to me. KPS: 100 |
    When I go to the last encounter note edit page
    Then the "100" checkbox within ".has_karnofsky_performance_status" should not be checked
    When I follow "Edit" within ".has_karnofsky_performance_status"
    And I wait for the ajax request to finish
    And I fill in "input.combobox" autocompleter within the first ".abstractor_abstraction" with "100% - Normal; no complaints; no evidence of disease."
    And I press "Save"
    And I wait for the ajax request to finish
    Then the "100" checkbox within ".has_karnofsky_performance_status" should be checked

  @javascript
  Scenario: User setting the value of an abstraction schema with a date object type
    Given abstraction schemas are set
    And encounter notes with the following information exist
      | Note Text                               |
      | Hello, I have no idea what is your KPS. |
    When I go to the last encounter note edit page
    And I follow "Edit" within ".has_karnofsky_performance_status_date"
    And I wait for the ajax request to finish
    And I fill in "abstractor_abstraction_value" with "2014-06-03" within ".has_karnofsky_performance_status_date"
    And I press "Save"
    And I wait for the ajax request to finish
    Then the "2014-06-03" checkbox within ".has_karnofsky_performance_status_date" should be checked

  @javascript
  Scenario: User setting all the values to 'not applicable' for an abstractable entitty
    Given abstraction schemas are set
    And encounter notes with the following information exist
      | Note Text                               |
      | Hello, I have no idea what is your KPS. |
    When I go to the last encounter note edit page
    Then I should see "unknown" anywhere within ".has_karnofsky_performance_status"
    And I should see "2014-06-26" anywhere within ".has_karnofsky_performance_status_date"
    When I confirm link "Not applicable all" in the first ".abstractor_abstractions"
    And I wait 1 seconds
    Then the "not applicable" checkbox within ".has_karnofsky_performance_status" should be checked
    And the "not applicable" checkbox within ".has_karnofsky_performance_status_date" should be checked
    And I wait 10 seconds

  @javascript
  Scenario: User setting all the values to 'unknown' for an abstractable entitty
    Given abstraction schemas are set
    And encounter notes with the following information exist
      | Note Text                               |
      | Hello, I have no idea what is your KPS. |
    When I go to the last encounter note edit page
    Then I should see "unknown" anywhere within ".has_karnofsky_performance_status"
    And I should see "2014-06-26" anywhere within ".has_karnofsky_performance_status_date"
    And I wait 10 seconds
    When I confirm link "Unknown all" in the first ".abstractor_abstractions"
    And I wait 1 seconds
    Then I should see "unknown" anywhere within ".has_karnofsky_performance_status"
    And I should see "unknown" anywhere within ".has_karnofsky_performance_status_date"

  @javascript
  Scenario: Viewing source for suggestion with source and match value with the match malue requiring scroll to.
    Given abstraction schemas are set
    And encounter notes with the following information exist
      | Note Text                            |
      | Little my says hi!\nLittle my says hi!\nLittle my says hi!\nLittle my says hi!\nLittle my says hi!\nLittle my says hi!\nLittle my says hi!\nLittle my says hi!\nLittle my says hi!\nLittle my says hi!\nLittle my says hi!\nLittle my says hi!\nLittle my says hi!\nLittle my says hi!\nLittle my says hi!\nLittle my says hi!\nLittle my says hi!\nLittle my says hi!\nLittle my says hi!\nLittle my says hi!\nLittle my says hi!\nLittle my says hi!\nLittle my says hi!\nLittle my says hi!\nLittle my says hi!\nLittle my says hi!\nLittle my says hi!\nLittle my says hi!\nLittle my says hi!\nLittle my says hi!\nLittle my says hi!\nLittle my says hi!\nLittle my says hi!\nLittle my says hi!\nLittle my says hi!\nLittle my says hi!\nLittle my says hi!\nLittle my says hi!\nLittle my says hi!\nLittle my says hi!\nLittle my says hi!\nLittle my says hi!\nLittle my says hi!\nLittle my says hi!\nLittle my says hi!\nLittle my says hi!\nLittle my says hi!\nLittle my says hi!\nLittle my says hi!\nLittle my says hi!\nLittle my says hi!\n The patient is looking good.  KPS: 100|
    And I go to the last encounter note edit page
    And I click within ".has_karnofsky_performance_status span.abstractor_abstraction_source_tooltip_img"
    Then I should see an "[style*='background-color: yellow;']" element
    When I click within ".has_karnofsky_performance_status span.abstractor_abstraction_source_tooltip_img"
    Then I should not see an "[style*='background-color: yellow;']" element
    When I click within ".has_karnofsky_performance_status span.abstractor_abstraction_source_tooltip_img"
    And ".abstractor_source_tab label" should contain text "Encounter Note: Note text"
    And ".abstractor_source_tab_content" should contain text "The patient is looking good.  KPS: 100"
    And ".abstractor_source_tab_content" should equal highlighted text "KPS: 100"
    And I wait 10 seconds