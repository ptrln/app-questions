require_relative 'model'

class Tags < Model
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