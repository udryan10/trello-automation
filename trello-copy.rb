require 'trello'
require 'trollop'
require 'yaml'


config =  YAML.load(File.open('tokens.yml'))

if config['member_token'].empty? or config['member_token'].nil?
  puts "Error: Please put your member key in tokens.yml"
  puts "If you need to generate one, visit https://trello.com/1/authorize?key=#{config['developer_key']}&scope=read%2Cwrite&name=Trello+Automation&expiration=never&response_type=token"
  exit 1
end

# setup options
opts = Trollop::options do
  opt :from, "The name of the board to copy from", :type => :string  
  opt :to, "The name of the new board that will be created", :type => :string
  opt :copy_backlog, "Whether we should attempt to copy backlog items from source board", :default => true
end

Trollop::die :from, "You must specify the name of a board to copy from" unless opts[:from]
Trollop::die :to, "You must specify the name of the board that will be created" unless opts[:to]

Trello.configure do |c|
  c.developer_public_key = config['developer_key'] 
  c.member_token = config['member_token']
end

me = Trello::Member.find("me")

source_board = nil
me.boards.each do |board|
  if board.name.downcase == opts[:from].downcase
    source_board = board
  end
end

if source_board.nil?
  puts "board with name:#{opts[:from]} - not found"
  exit 1
end

puts "found board #{source_board.name}, copying to new board with name: #{opts[:to]}"

fields = {
  :name => opts[:to],
  :organization_id => source_board.organization_id
}

# create new board
new_board = Trello::Board.create(fields)

# create backlog list in new board
new_backlog_list = Trello::List.create({:name => 'backlog', :board_id => new_board.id})



if opts[:copy_backlog]

  backlog_list = nil
  # find the backlog list in our source_board
  source_board.lists.each do |list|
    if list.name.downcase == "backlog"
      backlog_list = list
    end
  end
  
  if backlog_list.nil?
    puts "no backlog list found in #{opts[:from]} not copying to new board #{opts[:to]}"
  end
  
  move_count = 0
  # will move all cards listed as open to the new boards backlog list
  backlog_list.cards.each do |backlog_card|
    backlog_card.move_to_board(new_board,new_backlog_list)
    move_count += 1
  end rescue nil
  
  puts "moved #{move_count} backlog items to new backlog list on board #{new_board.name}"
end
puts "Successfully created board: #{new_board.url}"
