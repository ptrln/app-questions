require 'singleton'
require 'sqlite3'
require_relative 'question'
require_relative 'user'

class QuestionsDB < SQLite3::Database
  include Singleton

  def initialize
    super("questions.db")
    self.results_as_hash = true
    self.type_translation = true
  end
end

nick = User.find_by_id(2)
#nick.questions.first.do_action("reopen")
p nick.questions.first.action_history
#r = nick.questions.first.replies.first
#r.author_id = 5
#r.save
#p Replies.most_replied
#p User.new("","","", 2).average_karma


