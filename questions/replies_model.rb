require_relative 'model'

class Replies < Model
  attr_accessible :reply_body, :parent_id, :question_id, :author_id
  has_many(:replies, "question_replies", "parent_id") { |r| Replies.parse_hash(r) }

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
    Replies.parse_hash(QuestionsDB.instance.get_first_row(sql))
  end
end