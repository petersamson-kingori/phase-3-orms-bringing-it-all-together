class Dog
  attr_accessor :id, :name, :breed

  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE IF EXISTS dogs")
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed) VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end

  def update
    sql = <<-SQL
      UPDATE dogs SET name = ?, breed = ? WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def self.create(name:, breed:)
    dog = Dog.new(name: name, breed: breed)
    dog.save
  end

  def self.new_from_db(row)
    id = row[0]
    name = row[1]
    breed = row[2]
    Dog.new(id: id, name: name, breed: breed)
  end

  def self.all
    sql = <<-SQL
      SELECT * FROM dogs
    SQL
    rows = DB[:conn].execute(sql)
    rows.map { |row| new_from_db(row) }
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ?
    SQL
    row = DB[:conn].execute(sql, name).first
    if row
      new_from_db(row)
    else
      nil
    end
  end

  def self.find(id)
    sql = <<-SQL
      SELECT * FROM dogs WHERE id = ?
    SQL
    row = DB[:conn].execute(sql, id).first
    if row
      new_from_db(row)
    else
      nil
    end
  end
end
