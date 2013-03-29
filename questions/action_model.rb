require_relative 'model'

class QuestionAction < Model
  attr_accessible :type, :time
  VALID_ACTIONS = ['retract', 'close', 'reopen']
end