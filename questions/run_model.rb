require_relative 'question_model'
require_relative 'user_model'
require_relative 'replies_model'
require_relative 'action_model'
require_relative 'tag_model'

p User.find(1).average_karma

p Question.most_liked(5)

p Tags.most_popular

nick = User.find(2)
nick.questions.first.do_action("close")
nick.questions.first.do_action("reopen")

p nick.questions.first.action_history

p Replies.most_replied

p User.find(2).questions

p User.column_names

p User.find_by_fname("Ned")

p Replies.most_replied.replies

p nick.replies

nick = User.find(2)
nick.questions.first.followers
nick.questions.first.likes