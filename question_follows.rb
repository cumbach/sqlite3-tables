class QuestionFollow
  def self.all
    results = QuestionsDatabase.instance.execute(<<-SQL)
      SELECT * FROM question_follows
    SQL
    results.map { |result| QuestionFollow.new(result) }
  end

  attr_accessor :id, :user_id, :question_id

  def initialize(options = {})
    @id, @user_id, @question_id, = options.values_at('id', 'user_id', 'question_id')
  end

  def create
    raise 'already saved!' if id

    QuestionsDatabase.instance.execute(<<-SQL, user_id, question_id)
      INSERT INTO
        question_follows (user_id, question_id)
      VALUES
        (?, ?)
    SQL

    self.id = QuestionsDatabase.instance.last_insert_row_id
  end

  def self.find_by_id(find_id)

    result = QuestionsDatabase.instance.get_first_row(<<-SQL, find_id: find_id)
      SELECT * FROM question_follows WHERE question_follows.id = :find_id
    SQL
    QuestionFollow.new(result)
  end

  def self.followers_for_question_id(question_id)
    results = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT users.id, users.fname, users.lname FROM users
      JOIN question_follows ON users.id = question_follows.user_id
      WHERE
        question_follows.question_id = ?
    SQL
    results.map { |result| User.new(result) }
  end

  def self.followed_questions_for_user_id(user_id)
    results = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT questions.* FROM questions
      JOIN question_follows ON questions.id = question_follows.question_id
      WHERE
        question_follows.user_id = ?
    SQL
    results.map { |result| Question.new(result) }
  end

  def self.most_followed_questions(n)
    results = QuestionsDatabase.instance.execute(<<-SQL, n)
      SELECT
        questions.*
      FROM
        questions
      JOIN
        question_follows ON questions.id = question_follows.question_id
      GROUP BY questions.title
      ORDER BY COUNT(question_follows.user_id) DESC
      LIMIT ?
    SQL
    results.map {|result| Question.new(result)}
  end

  

end
