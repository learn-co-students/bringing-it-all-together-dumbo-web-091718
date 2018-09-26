class Dog
  attr_accessor :name, :breed, :id

  @@all = []
  def initialize(attributes)
    attributes.each {|key, value| self.send(("#{key}="), value)}
    @@all << self
  end

  def self.all
    @@all
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
    DROP TABLE dogs
    SQL

    DB[:conn].execute(sql)
  end

  def self.create(attributes)
    dog = Dog.new(attributes)
    dog.save
  end

  def self.find_by_id(id)
    sql = <<-SQL
    SELECT *
    FROM dogs
    WHERE id = ?
    SQL

    result = DB[:conn].execute(sql, id)
    Dog.new(name: result[0][1], breed: result[0][2], id: result[0][0])
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT *
    From dogs
    WHERE name = ?
    SQL

    result = DB[:conn].execute(sql, name)
    Dog.new(name: result[0][1], breed: result[0][2], id: result[0][0])
  end

  def self.find_or_create_by(name:, breed:)
    maybe_dog = DB[:conn].execute("SELECT * FROM dogs where name = ? AND breed = ?", name, breed)
    if !maybe_dog.empty?
      dog_info = maybe_dog[0]
      dog = Dog.new(id: dog_info[0], name: dog_info[1], breed: dog_info[2])
    else
      dog = self.create(name: name, breed: breed)
    end
    dog
  end

  def self.new_from_db(row)
    new_dog = self.new(name: row[1], breed: row[2])
    new_dog.id = row[0][0]
    new_dog
  end

  def save
    sql = <<-SQL
    INSERT INTO dogs
    VALUES (?, ?, ?)
    SQL

    DB[:conn].execute(sql, self.id, self.name, self.breed)

    new_dog_info = DB[:conn].execute("SELECT * FROM dogs ORDER BY id DESC LIMIT 1")
    new_dog = Dog.new(name: new_dog_info[0][1], id: new_dog_info[0][0], breed: new_dog_info[0][2])
    self.id = new_dog.id
    return new_dog
  end

  def update
    sql = <<-SQL
    UPDATE dogs
    SET name = ?, breed = ?
    WHERE id = ?
    SQL

    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
end
