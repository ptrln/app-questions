module Findable
   # REV: Hopefully we can solve this with metaprogramming! 
  def self.find_by_table_and_id(classType, table, id)
    sql = <<-SQL
      SELECT *
        FROM #{table}
       WHERE id = #{id}
    SQL
    classType.parse_hash(QuestionsDB.instance.execute(sql).first)
  end
end