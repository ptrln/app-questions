require_relative 'model'

class Question < Model
  attr_accessible :title, :body
  has_many(:followers, "question_followers", "question_id") do |record| 
    User.find(record["follower_id"]) 
  end
  has_many(:likes, "question_likes", "question_id") do |record| 
    User.find(record["user_id"]) 
  end
  belongs_to(:author, 'users') { |hash| User.parse(hash) }

  def self.table_name
    'questions'
  end

  def self.most_liked(n)
    sql = <<-SQL
      SELECT questions.*
        FROM questions
   LEFT JOIN question_likes 
          ON question_id = questions.id
    GROUP BY question_id
    ORDER BY COUNT(*) DESC
       LIMIT (?)
    SQL
    QuestionsDB.instance.execute(sql, n).map { |q| Question.parse(q) }
  end

  def self.most_followed(n)
    sql = <<-SQL
      SELECT questions.*
        FROM question_followers
        JOIN questions
          ON question_id = questions.id
    GROUP BY question_id
    ORDER BY COUNT(*) DESC
       LIMIT (?)
    SQL
    QuestionsDB.instance.execute(sql, n).map { |q| Question.parse(q) }
  end

  # this cannot be replaced by has_many because we want to exclude 
  # non-root comments
  def replies 
    return [] if self.id.nil?
    sql = <<-SQL
      SELECT  *
        FROM  question_replies
       WHERE  question_id = ? AND parent_id IS NULL
    SQL

    QuestionsDB.instance.execute(sql, id).map { |qa| Replies.parse(qa) }
  end

  def asking_student
    author
  end

  def action_history
    return [] if self.id.nil?
    sql = <<-SQL
      SELECT qat.type, qa.time
        FROM question_actions as qa
        JOIN question_action_type as qat
          ON qa.type_id = qat.id
       WHERE qa.question_id = ? 
    SQL
    QuestionsDB.instance.execute(sql, self.id).map { |a| QuestionAction.parse(a) }
  end

  def do_action(type)
    raise "invalid action" unless QuestionAction::VALID_ACTIONS.include?(type)
    raise "question not in db" unless self.id

    sql = <<-SQL
      SELECT id
        FROM question_action_type
       WHERE type = ?
    SQL

    type_int = QuestionsDB.instance.get_first_value(sql, type)
    sql = <<-SQL
      INSERT INTO question_actions ('question_id', 'type_id')
      VALUES (?, ?)
    SQL

    QuestionsDB.instance.execute(sql, id, type_int)
  end
end