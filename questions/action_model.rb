require_relative 'model'

class QuestionAction < Model
  attr_accessible :type, :time
  VALID_ACTIONS = ['retract', 'close', 'reopen']

  def initialize(type, time)
    @type = type
    @time = time
  end

  def self.parse_hash(hash)
    QuestionAction.new(hash['type'], hash['time'])
  end
end