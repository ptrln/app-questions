require_relative 'model'
class User < Model
  attr_accessible :fname, :lname, :is_instructor
  has_many(:replies, "question_replies", "author_id") { |r| Replies.parse_hash(r) }
  has_many(:questions, "questions", "author_id") { |q| Question.parse_hash(q) }
  
  def self.table_name
    "users"
  end

  def average_karma
    return 0.0 if self.id.nil?
    QuestionsDB.instance.get_first_value(<<-SQL, self.id, self.id)
        SELECT AVG(c) as average
          FROM
               (SELECT COUNT(*) AS c
                  FROM questions
                  JOIN question_likes
                    ON questions.id = question_id
                 WHERE author_id = ?
                 UNION
                SELECT 0.0 AS c
                  FROM questions
             LEFT JOIN question_likes
                    ON questions.id = question_id
                 WHERE author_id = ? AND question_likes.user_id IS NULL)
    SQL
  end
end