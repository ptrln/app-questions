require_relative 'model'

class Replies < Model
  attr_accessible :reply_body
  has_many(:replies, "question_replies", "parent_id") { |r| Replies.parse(r) }
  belongs_to(:parent, "question_replies") { |u| User.find(u['id']) }
  belongs_to(:question, "question_replies") { |q| Question.find(q['id']) }
  belongs_to(:author, "question_replies") { |u| User.find(u['id']) }

  def self.most_replied
    sql = <<-SQL
      SELECT b.*
        FROM question_replies a
        JOIN question_replies b
          ON a.parent_id = b.id
    GROUP BY a.parent_id
    ORDER BY COUNT(a.id) DESC
       LIMIT 1
    SQL
    Replies.parse(QuestionsDB.instance.get_first_row(sql))
  end
end