require_relative 'questions_database'

class Question
  def self.all
    results = QuestionsDatabase.instance.execute(<<-SQL)
      SELECT * FROM questions
    SQL
    results.map { |result| Question.new(result) }
  end

  def self.find_by_author_id(author_id)
    results = QuestionsDatabase.instance.execute(<<-SQL, author_id)
      SELECT * FROM questions WHERE questions.author_id = ?
    SQL
    results.map { |result| Question.new(result) }
  end

  attr_accessor :id, :title, :body, :author_id

  def initialize(options = {})
    @id, @title, @body, @author_id = options.values_at('id', 'title', 'body', 'author_id')
  end

  def create
    raise 'already saved!' if id

    QuestionsDatabase.instance.execute(<<-SQL, title, body, author_id)
      INSERT INTO
        questions (title, body, author_id)
      VALUES
        (?, ?, ?)
    SQL

    self.id = QuestionsDatabase.instance.last_insert_row_id
  end

  def self.find_by_id(find_id)
    result = QuestionsDatabase.instance.get_first_row(<<-SQL, find_id: find_id)
      SELECT * FROM questions WHERE questions.id = :find_id
    SQL
    Question.new(result)
  end

  def author
    result = QuestionsDatabase.instance.get_first_row(<<-SQL, author_id)
      SELECT * FROM users WHERE users.id = ?
    SQL
    User.new(result)
  end

  def replies
    Reply.find_by_question_id(id)
  end

  def followers
    QuestionFollow.followers_for_question_id(id)
  end

  def self.most_followed(n)
    QuestionFollow.most_followed_questions(n)
  end

  def likers
    QuestionLike.likers_for_question_id(id)
  end

  def num_likes
    QuestionLike.num_likes_for_questions_id(id)
  end

  def self.most_liked(n)
    QuestionLike.most_liked_questions(n)
  end
end
