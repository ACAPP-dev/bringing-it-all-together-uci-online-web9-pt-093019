class Dog
  attr_accessor :id, :name, :breed

  def initialize(id: nil, name:, breed:)
    @id, @name, @breed = id, name, breed
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE dogs(id INTEGER PRIMARY KEY, name TEXT, breed TEXT)
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE IF EXISTS dogs")
  end

  def save
    sql = <<-SQL
      INSERT INTO dogs(name, breed) VALUES (?, ?)
    SQL
    DB[:conn].execute(sql, self.name, self.breed)
    self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def self.create(attributes)
    dog = Dog.new(:name => attributes[:name], :breed => attributes[:breed])
    dog.save
  end

  def self.new_from_db(row)
    #binding.pry
    dog = Dog.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_by_id(id)
    row = DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", id)[0]
    self.new_from_db(row)
  end

  def self.find_or_create_by(name:, breed:)
    #binding.pry
    row = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)[0]
    if !row.empty?
      self.new_from_db(row)
      #self.update(row[0])
    else
      self.create(:name => name, :breed => breed)
    end
  end

  def update(row)
    sql = <<-SQL
      UPDATE dogs SET name = ?, breed = ? WHERE id = ?
    SQL
    DB[:conn].execute(sql, row[1], row[2], row[0])
    self.find_by_id(row[0])
  end

  def self.find_by_name(name)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name)[0]
    self.new_from_db(dog)
  end
end
