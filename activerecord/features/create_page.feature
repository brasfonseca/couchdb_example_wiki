Feature: wiki
  In order to learn more about the differences between woring with sql and couchdb
  As a scotland on rails speaker
  I want to implement a simple wiki
  
  
  Scenario: create first page
    When I go to the start page
    And I fill in "Page One" for "Title"
    And I fill in "this is page one" for "Body"
    And I press "Create Page"
    And I go to the start page
    Then I should see "this is page one"
    
  Scenario: create a second page
      Given a page "page one" with the body "this links to PageTwo"
      When I go to the start page
      And I follow "PageTwo"
      And I fill in "this is page two" for "Body"
      And I press "Create Page"
      And I go to the start page
      And I follow "PageTwo"
      Then I should see "this is page two"
    
  Scenario: update page
    Given a page "page one" with the body "this links to PageTwo"
    When I go to the start page
    And I follow "Edit Page"
    And I fill in "new page one" for "Body"
    And I press "Update Page"
    And I go to the start page
    Then I should see "new page one"
  
  Scenario: view previous versions of a page
    Given a page "page one" with the body "old page one"
    And "page one" has been updated with "new page one"
    When I go to the start page
    And I follow "Versions"
    And I follow "Version 1"
    Then I should see "old page one"
  
  Scenario: see list of pages
    Given a page "page one"
    And a page "page two"
    When I go to the start page
    And I follow "List of Pages"
    Then I should see "page one"
    And I should see "page two"
  
  Scenario: see word statistics
    Given a page "page one" with the body "old page one"
    And a page "page two" with the body "new page two"
    When I go to the start page
    And I follow "Statistics"
    Then I should see "old: 1"
    And I should see "new: 1"
    And I should see "page: 2"
    And I should see "one: 1"
    And I should see "two: 1"
      
      