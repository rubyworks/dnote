Feature: Showing notes

  Scenario: Simple case
    Given a file named "i_have_notes.rb" with:
    """
    # TODO: Really do stuff
    #
    # NOTE: Not done
    def do_stuff
      # nothing
    end
    """
    When I run `dnote`
    Then the output should contain:
    """
    Developer's Notes
    
    TODO
    
       1. Really do stuff (i_have_notes.rb:1)
    
    NOTE
    
       1. Not done (i_have_notes.rb:3)
    
    (1 TODOs, 1 NOTEs)
    """
