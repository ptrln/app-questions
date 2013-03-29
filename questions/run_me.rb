require 'singleton'
require 'sqlite3'
require_relative 'question'
require_relative 'user'
require_relative 'misc'

class QuestionsDB < SQLite3::Database
  include Singleton

  def initialize
    super("questions.db")
    self.results_as_hash = true
    self.type_translation = true
  end
end


User.find_by_id(1).average_karma

p Question.most_liked(5).first.most_replies(2)
p Tags.most_popular
nick = User.find_by_id(2)
nick.questions.first.do_action("close")
nick.questions.first.do_action("reopen")
p nick.questions.first.action_history

p Replies.most_replied
p User.find_by_id(2).questions
p User.find_by_id(2).average_karma
p Replies.most_replied.replies
p nick.replies