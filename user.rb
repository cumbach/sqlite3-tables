require_relative 'questions_database'

class User
  def self.all
    results = QuestionsDatabase.instance.execute(<<-SQL)
      SELECT * FROM users
    SQL
    results.map { |result| User.new(result) }
  end

  def self.find_by_name(fname, lname)
    result = QuestionsDatabase.instance.get_first_row(<<-SQL, fname, lname)
      SELECT * FROM users WHERE users.fname = ? AND users.lname = ?
    SQL
    User.new(result)
  end

  attr_accessor :id, :fname, :lname

  def initialize(options = {})
    @id , @fname, @lname = options.values_at('id', 'fname', 'lname')
  end

  def create
    raise 'already saved!' if id

    QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
      INSERT INTO
        users (fname, lname)
      VALUES
        (?, ?)
    SQL

    self.id = QuestionsDatabase.instance.last_insert_row_id
  end




  def self.find_by_id(find_id)
    result = QuestionsDatabase.instance.get_first_row(<<-SQL, find_id: find_id)
      SELECT * FROM users WHERE users.id = :find_id
    SQL
    User.new(result)
  end


  def authored_questions
    Question.find_by_author_id(self.id)
  end

  def authored_replies
    Reply.find_by_user_id(self.id)
  end

  def followed_questions
    QuestionFollow.followed_questions_for_user_id(id)
  end

  def liked_questions
    QuestionLike.liked_questions_for_user_id(id)
  end

  def average_karma
    result = QuestionsDatabase.instance.execute(<<-SQL, self.id)
      SELECT CAST(COUNT(*) AS FLOAT) / COUNT(DISTINCT(questions.id))
      FROM questions
      LEFT OUTER JOIN
        question_likes ON questions.id = question_likes.question_id
      WHERE
        questions.author_id = ?
      GROUP BY questions.id

    SQL
  end

end
