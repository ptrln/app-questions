require_relative 'findable'

class User
  attr_reader :id
  attr_accessor :fname, :lname, :instructor

  alias_method :instructor?, :instructor # REV: good use of an alias

  def initialize(fname,lname,instructor,id=nil) # REV: You should pass in a single hash here
    @fname = fname
    @lname = lname
    @instructor = instructor
    @id = id
  end

  def average_karma
    return 0.0 if self.id.nil? # REV this is a clean use of a sub-query
    sql = <<-SQL
        SELECT AVG(c) as average
          FROM
               (SELECT COUNT(*) AS c
                  FROM questions
                  JOIN question_likes
                    ON questions.id = question_id
                 WHERE author_id = ?
              GROUP BY question_id)
    SQL
    QuestionsDB.instance.execute(sql, self.id).first['average']
  end

  def self.find_by_id(id)
    Findable.find_by_table_and_id(User, 'users', id)
  end

  def self.parse_hash(hash) # REV: I am not sure what this is doing
    User.new(hash['fname'], hash['lname'], hash['is_instructor'] == 1, hash['id'])
  end

  def questions
    return [] if self.id.nil?
    sql = <<-SQL
      SELECT *
        FROM questions
       WHERE author_id = ?
    SQL
    QuestionsDB.instance.execute(sql, self.id).map { |q| Question.parse_hash(q) }
  end

  def replies
    return [] if self.id.nil?
    sql = <<-SQL
      SELECT *
        FROM question_replies
       WHERE author_id = ?
    SQL
    QuestionsDB.instance.execute(sql, self.id).map { |q| Replies.parse_hash(q) }
  end

  def save
    if id.nil?
      sql = <<-SQL
        INSERT INTO users 
        VALUES (NULL, ?, ?, ?)
      SQL
      QuestionsDB.instance.execute(sql, fname, lname, instructor? ? 1 : 0)
      @id = QuestionsDB.instance.last_insert_row_id
    # REV: You could make a seperate update method, to simplify this
    else 
      sql = <<-SQL
        UPDATE users
        SET    fname = ?, lname = ?, is_instructor = ?
        WHERE  id = ?
      SQL
      QuestionsDB.instance.execute(sql, fname, lname, instructor? ? 1 : 0, id)
    end 
  end

end