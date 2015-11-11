require_relative 'questions_database'

class QuestionLike
  def self.all
    results = QuestionsDatabase.instance.execute(<<-SQL)
      SELECT * FROM question_likes
    SQL
    results.map { |result| QuestionLike.new(result) }
  end

  attr_accessor :id, :question_id, :user_id

  def initialize(options = {})
    @id, @question_id, @user_id=
      options.values_at('id', 'question_id', 'user_id')
  end

  def create
    raise 'already saved!' if id

    QuestionsDatabase.instance.execute(<<-SQL, question_id, user_id)
      INSERT INTO
        question_likes (question_id, user_id)
      VALUES
        (?, ?)
    SQL

    self.id = QuestionsDatabase.instance.last_insert_row_id
  end

  def self.find_by_id(find_id)
    result = QuestionsDatabase.instance.get_first_row(<<-SQL, find_id: find_id)
      SELECT * FROM question_likes WHERE question_likes.id = :find_id
    SQL
    QuestionLike.new(result)
  end

  def self.likers_for_question_id(question_id)
    results = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT users.* FROM users
      JOIN question_likes ON question_likes.user_id = users.id
      WHERE question_likes.question_id = ?
      SQL
    results.map{|result| User.new(result)}
  end

  def self.num_likes_for_questions_id(question_id)
    result = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT COUNT(*) FROM question_likes
      WHERE question_likes.question_id = ?
    SQL
    result.first.values.first
  end

  def self.liked_questions_for_user_id(user_id)
    results = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT questions.* FROM questions
      JOIN question_likes ON questions.id = question_likes.question_id
      WHERE question_likes.user_id = ?
    SQL
    results.map { |result| Question.new(result) }
  end

  def self.most_liked_questions(n)
    results = QuestionsDatabase.instance.execute(<<-SQL, n)
      SELECT questions.* from questions
      JOIN question_likes on questions.id = question_likes.question_id
      GROUP BY questions.id
      ORDER BY COUNT(*) DESC
      LIMIT ?
    SQL
    results.map{|result| Question.new(result)}
  end
  
end
