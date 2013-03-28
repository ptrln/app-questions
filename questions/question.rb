require_relative 'findable'

class Question

  attr_reader :id
  attr_accessor :title, :body, :author_id

  def initialize(title, body, author_id, id = nil)
    @title = title
    @body = body
    @author_id = author_id
    @id = id
  end

  def self.find_by_id(id)
    Findable.find_by_table_and_id(Question, 'questions', id)
  end

  def num_likes
    return 0 if self.id.nil?
    sql = <<-SQL
    SELECT COUNT(user_id)
      FROM question_likes
     WHERE question_id = (?)
    SQL
    QuestionsDB.instance.execute(sql, self.id)
  end

  def self.most_liked(n)
    sql = <<-SQL
      SELECT questions.*
        FROM question_likes 
        JOIN questions
          ON question_id = questions.id
    GROUP BY question_id
    ORDER BY COUNT(*) DESC
       LIMIT (?)
    SQL
    QuestionsDB.instance.execute(sql, n).map { |q| Question.parse_hash(q) }
  end

  def followers
    return 0 if self.id.nil?
    sql = <<-SQL
      SELECT users.*
        FROM users
        JOIN question_followers
          ON follower_id = users.id
       WHERE question_id = (?)
    SQL

    QuestionsDB.instance.execute(sql, id).map { |u| User.parse_hash(u) }
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
    QuestionsDB.instance.execute(sql, n).map { |q| Question.parse_hash(q) }
  end

  def self.parse_hash(hash)
    Question.new(hash['title'], hash['body'], hash['author_id'], hash['id'])
  end

  def replies
    return [] if self.id.nil?
    sql = <<-SQL
      SELECT  *
        FROM  question_replies
       WHERE  question_id = ? AND parent_id IS NULL
    SQL

    QuestionsDB.instance.execute(sql, id).map { |qa| Replies.parse_hash(qa) }
  end

  def asking_student
    return nil if self.id.nil?
    sql = <<-SQL
      SELECT u.*
        FROM questions q
        JOIN users u
          ON q.author_id = u.id
       WHERE q.id = ?
    SQL
    User.parse_hash(QuestionsDB.instance.execute(sql, self.id).first)
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
    QuestionsDB.instance.execute(sql, self.id).map { |a| QuestionAction.parse_hash(a) }
  end

  def save
    if id.nil?
      sql = <<-SQL
        INSERT INTO questions 
        VALUES (NULL, ?, ?, ?)
      SQL
      QuestionsDB.instance.execute(sql, title, body, author_id)
      @id = QuestionsDB.instance.last_insert_row_id
    else
      sql = <<-SQL
        UPDATE questions 
        SET    title = ?, body = ?, author_id = ?
        WHERE  id = ?
      SQL
      QuestionsDB.instance.execute(sql, title, body, author_id, id)
    end 
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

class Replies
  attr_reader :id
  attr_accessor :reply_body, :parent_id, :question_id, :author_id

  def initialize(parent_id, question_id, reply_body, author_id, id)
    @parent_id, @question_id = parent_id, question_id
    @reply_body, @author_id, @id = reply_body, author_id, id

  end

  def self.find_by_id(id)
    Findable.find_by_table_and_id(Replies, 'question_replies', id)
  end

  def replies
    return [] if self.id.nil?
    sql = <<-SQL
      SELECT  *
        FROM  question_replies
       WHERE  parent_id = ?
    SQL
    QuestionsDB.instance.execute(sql, id).map { |qa| Replies.parse_hash(qa) }
  end

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
    Replies.parse_hash(QuestionsDB.instance.execute(sql).first)
  end

  def self.parse_hash(hash)
    Replies.new(hash['parent_id'], hash['question_id'], 
      hash['reply_body'], hash['author_id'], hash['id'])       
  end

  def save
    if id.nil?
      sql = <<-SQL
        INSERT INTO question_replies
        VALUES (NULL, ?, ?, ?, ?)
      SQL
      QuestionsDB.instance.execute(sql, parent_id, question_id, reply_body, author_id)
      @id = QuestionsDB.instance.last_insert_row_id
    else
      sql = <<-SQL
        UPDATE question_replies
        SET    parent_id = ?, question_id = ?, reply_body = ?, author_id = ?
        WHERE  id = ?
      SQL
      QuestionsDB.instance.execute(sql, parent_id, question_id, reply_body, author_id, id)
    end 
  end
end

class QuestionAction
  VALID_ACTIONS = ['retract', 'close', 'reopen']

  def initialize(type, time)
    @type = type
    @time = time
  end

  def self.parse_hash(hash)
    QuestionAction.new(hash['type'], hash['time'])
  end
end