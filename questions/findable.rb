#looks like you guys did an awesome refactor, couldn't really find anything to add. nice job integrating the module
# model and accounting for corner-cases

module Findable

  def self.find_by_table_and_id(classType, table, id)
    sql = <<-SQL
      SELECT *
        FROM #{table}
       WHERE id = #{id}
    SQL
    classType.parse_hash(QuestionsDB.instance.execute(sql).first)
  end
end