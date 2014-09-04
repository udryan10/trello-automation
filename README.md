utilities for automating common trello tasks. 

# trello-copy.rb
Creates a new board and moves the backlog cards from a source board to the newley created board

### Install
    git clone https://github.com/udryan10/trello-automation.git
    bundle install
### running
    # help 
    ruby trello-copy.rb --help
    
    # created new board and copy backlog items from source
    ruby trello-copy.rb --from "source board name" --to "new board name"
