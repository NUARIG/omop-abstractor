Feature: Editing moomin
  User should be able to edit moomin information

  @javascript
  Scenario: editing a moomin with no sections setup
    Given moomin abstraction schemas are set with no sections
    And moomins with the following information exist
      | Note Text                                                             |
      | I like little my the best!\nfavorite moomin:\nThe groke is the bomb!  |
    When I go to the last moomin edit page
    Then I should see "Little My" anywhere within the first ".abstractor_suggestion_values"
    And I should see "The Groke" anywhere within the last ".abstractor_suggestion_values"
    When I click within first ".has_favorite_moomin span.abstractor_abstraction_source_tooltip_img"
    Then I should see a "[style*='background-color: yellow;']" element
    And ".abstractor_source_tab label" should contain text "Moomin: Note text"
    And ".abstractor_source_tab_content" should contain text "I like little my the best!favorite moomin:The groke is the bomb!"
    And ".abstractor_source_tab_content" should equal highlighted text "little my"
    And I click within last ".has_favorite_moomin span.abstractor_abstraction_source_tooltip_img"
    And ".abstractor_source_tab_content" should equal highlighted text "The groke"

  @javascript
  Scenario: editing a moomin with a section setup and a section name variant is mentioned
    Given moomin abstraction schemas are set with a section
    And moomins with the following information exist
      | Note Text                                                             |
      | I like little my the best!\nbeloved moomin:\nThe groke is the bomb!  |
    When I go to the last moomin edit page
    Then I should not see "Little My" anywhere within ".abstractor_suggestion_values"
    And I should see "The Groke" anywhere within ".abstractor_suggestion_values"
    When I click within first ".has_favorite_moomin span.abstractor_abstraction_source_tooltip_img"
    Then I should see an "[style*='background-color: yellow;']" element
    And ".abstractor_source_tab label" should contain text "Moomin: Note text"
    And ".abstractor_source_tab_content" should contain text "The groke is the bomb!"
    And ".abstractor_source_tab_content" should equal highlighted text "The groke"

  @javascript
  Scenario: editing a moomin with a section setup and more than one section name variant is mentioned
    Given moomin abstraction schemas are set with a section
    And moomins with the following information exist
      | Note Text                                                             |
      | I like little my the best!\nfavorite moomin:\nThe groke is the bomb!\nbeloved moomin:\nMoomintroll is the bomb!  |
    When I go to the last moomin edit page
    Then I should not see "Little My" anywhere within the first ".abstractor_suggestion_values"
    And I should see "The Groke" anywhere within the last ".abstractor_suggestion_values"
    When I click within first ".has_favorite_moomin span.abstractor_abstraction_source_tooltip_img"
    Then I should see an "[style*='background-color: yellow;']" element
    And ".abstractor_source_tab label" should contain text "Moomin: Note text"
    And ".abstractor_source_tab_content" should contain text "The groke is the bomb!"
    And ".abstractor_source_tab_content" should equal highlighted text "The groke"

  @javascript
  Scenario: editing a moomin with a section setup and return note on empty section is set to true
    Given moomin abstraction schemas are set with a section
    And moomin abstraction schemas have return note on empty section set to "true"
    And moomins with the following information exist
      | Note Text                                                             |
      | I like little my the best!\nWorse moomin:\nThe groke is terrible!     |
    When I go to the last moomin edit page
    Then I should see "Little My" anywhere within the first ".abstractor_suggestion_values"
    And I should see "The Groke" anywhere within the last ".abstractor_suggestion_values"
    When I click within first ".has_favorite_moomin span.abstractor_abstraction_source_tooltip_img"
    Then I should see an "[style*='background-color: yellow;']" element
    And ".abstractor_source_tab label" should contain text "Moomin: Note text"
    And ".abstractor_source_tab_content" should contain text "I like little my the best!Worse moomin:The groke is terrible!"
    And ".abstractor_source_tab_content" should equal highlighted text "little my"
    And I click within last ".has_favorite_moomin span.abstractor_abstraction_source_tooltip_img"
    Then I should see an "[style*='background-color: yellow;']" element
    And ".abstractor_source_tab_content" should equal highlighted text "The groke"

  @javascript
  Scenario: editing a moomin with a section setup and return note on empty section is set to false
    Given moomin abstraction schemas are set with a section
    And moomin abstraction schemas have return note on empty section set to "false"
    And moomins with the following information exist
      | Note Text                                                             |
      | I like little my the best!\nWorse moomin:\nThe groke is terrible!     |
    When I go to the last moomin edit page
    Then I should not see "Little My" anywhere within ".abstractor_suggestion_values"
    And I should not see "The Groke" anywhere within ".abstractor_suggestion_values"
    And I should not see "Unknown" anywhere within ".abstractor_suggestion_values"
    And I should see 0 "span.abstractor_abstraction_source_tooltip_img" within the first ".has_karnofsky_performance_status"
    And ".abstractor_source_tab label" should contain text "Moomin: Note text"
    And ".abstractor_source_tab_content" should contain text ""

  @javascript
  Scenario: editing a moomin with a custom section setup
    Given moomin abstraction schemas are set with a custom section
    And moomins with the following information exist
      | Note Text                                                             |
      | I like little my the best!\nCool moomin: The groke is the bomb!  |
    When I go to the last moomin edit page
    Then I should not see "Little My" anywhere within ".abstractor_suggestion_values"
    And I should see "The Groke" anywhere within ".abstractor_suggestion_values"
    When I click within first ".has_favorite_moomin span.abstractor_abstraction_source_tooltip_img"
    Then I should see an "[style*='background-color: yellow;']" element
    And ".abstractor_source_tab label" should contain text "Moomin: Note text"
    And ".abstractor_source_tab_content" should contain text "The groke is the bomb!"
    And ".abstractor_source_tab_content" should equal highlighted text "The groke"
