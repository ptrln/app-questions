require_relative 'findable'

class Replies
  attr_reader :id
  attr_accessor :reply_body, :parent_id, :question_id, :author_id

  def initialize(parent_id, question_id, reply_body, author_id, id) # REV: Again, you should use an options hash
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

class Tags  # REV: Awsome! We didn't get to this part
  def self.most_popular
    sql = <<-SQL
      SELECT t.type as tag, q.*
        FROM tags t
   LEFT JOIN question_tags q_tags
          ON q_tags.type_id = t.id
   LEFT JOIN questions q
          ON q_tags.question_id = q.id
       WHERE q.id IN (
              SELECT qt.question_id
                FROM question_tags qt
                JOIN question_likes ql
                  ON ql.question_id = qt.question_id
               WHERE qt.type_id = q_tags.type_id
            GROUP BY ql.question_id
            ORDER BY COUNT(ql.user_id) DESC
               LIMIT 5) 
    SQL
    most_popular = Hash.new { Array.new }
    QuestionsDB.instance.execute(sql).each do |thingy|
      most_popular[thingy['tag']] <<= Question.parse_hash(thingy)
    end
    most_popular
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