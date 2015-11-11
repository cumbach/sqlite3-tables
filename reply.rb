require_relative 'questions_database'

class Reply
  def self.all
    results = QuestionsDatabase.instance.execute(<<-SQL)
      SELECT * FROM replies
    SQL
    results.map { |result| Reply.new(result) }
  end

  def self.find_by_question_id(question_id)
    results = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT * FROM replies WHERE replies.question_id = ?
    SQL
    results.map { |result| Reply.new(result) }
  end

  def self.find_by_user_id(user_id)
    results = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT * FROM replies WHERE replies.user_id = ?
    SQL
    results.map { |result| Reply.new(result) }
  end

  attr_accessor :id, :question_id, :parent_reply_id, :user_id, :body

  def initialize(options = {})
    @id, @question_id, @parent_reply_id, @user_id, @body =
      options.values_at('id', 'question_id', 'parent_reply_id', 'user_id', 'body')
  end

  def create
    raise 'already saved!' if id

    QuestionsDatabase.instance.execute(<<-SQL, question_id, parent_reply_id, user_id, body)
      INSERT INTO
        replies (question_id, parent_reply_id, user_id, body)
      VALUES
        (?, ?, ?, ?)
    SQL

    self.id = QuestionsDatabase.instance.last_insert_row_id
  end

  def self.find_by_id(find_id)
    result = QuestionsDatabase.instance.get_first_row(<<-SQL, find_id: find_id)
      SELECT * FROM replies WHERE replies.id = :find_id
    SQL
    Reply.new(result)
  end

  def author
    result = QuestionsDatabase.instance.get_first_row(<<-SQL, user_id)
      SELECT * FROM users WHERE users.id = ?
    SQL
    User.new(result)
  end

  def question
    result = QuestionsDatabase.instance.get_first_row(<<-SQL, question_id)
      SELECT * FROM questions WHERE questions.id = ?
    SQL
    Question.new(result)
  end

  def parent_reply
    Reply.find_by_id(parent_reply_id)
  end

  def child_replies
    results = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT * FROM replies WHERE replies.parent_reply_id = ?
    SQL
    results.map {|result| Reply.new(result) }
  end



end
