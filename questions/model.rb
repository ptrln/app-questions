require 'singleton'
require 'sqlite3'

class Model
  class QuestionsDB < SQLite3::Database
    include Singleton

    def initialize
      super("questions.db")
      self.results_as_hash = true
      self.type_translation = true
    end
  end

  attr_reader :id
  DB = QuestionsDB.instance
  @@column_names = Hash.new { Array.new }
  
  def initialize(id = nil)
    @id = id
  end

  def self.table_name
    raise NotImplementedError
  end

  def self.find(id)
    sql = <<-SQL
         SELECT *
           FROM #{self.table_name}
          WHERE id = #{id}
    SQL
    self.parse_hash(DB.execute(sql).first)
  end

  def self.all
    sql = <<-SQL
        SELECT * FROM #{self.table_name}
    SQL
    DB.execute(sql).map { |h| self.parse_hash(h) }
  end

  def self.column_names
    @@column_names[self]
  end

  def self.parse_hash(hash)
    obj = self.new(hash['id'])
    hash.each do |column_name, value|
      if obj.class.column_names.include?(column_name.to_sym)
        obj.send("#{column_name}=", value)
      end
    end
    obj
   end

  def save  #TODO: SAVING DOES NOT WORK YET
    if id.nil?
        sql = <<-SQL
          INSERT INTO #{self.table_name}
          VALUES SOMETHING
        SQL
        DB.execute(sql, title, body, author_id)
        @id = DB.last_insert_row_id
      else
        sql = <<-SQL
          UPDATE #{self.table_name}
          SET    SOMETHING
          WHERE  id = ?
        SQL
        DB.execute(sql, title, body, author_id, id)
      end 
  end

  protected
  def self.attr_accessible(*column_names)
    column_names.each do |column_name|
      @@column_names[self] <<= column_name
      set_instance_variables(column_name)
      set_find_by_column_names(column_name)
    end
  end

  def self.set_find_by_column_names(column_name)
    self.class.send(:define_method, "find_by_#{column_name}") do |value|
      sql = <<-SQL
        SELECT *
          FROM #{self.table_name}
         WHERE #{column_name} = ?
      SQL
      DB.execute(sql, value).map { |h| self.parse_hash(h) }
    end
  end

  def self.set_instance_variables(column_name)
    self.send(:define_method, "#{column_name}") do
      self.instance_variable_get("@#{column_name}")
    end
    self.send(:define_method, "#{column_name}=") do |value|
      self.instance_variable_set("@#{column_name}", value)
    end
  end

  def self.has_many(other, table_name, my_key, &proc)
    body = Proc.new do
          return [] unless self.send(:id)
        sql = <<-SQL
          SELECT *
            FROM #{table_name}
           WHERE #{my_key} = ?
        SQL
        DB.execute(sql, self.send(:id)).map { |h| proc.call(h) }
      end
      self.send(:define_method, other, &body)
  end

  def self.belongs_to(other) #TODO: BELONGS TO DOESN'T WORK YET
  end

end

