class Dog
  require 'pry'

attr_accessor :name, :breed
attr_reader :id

def initialize(name:, breed:, id: nil)
  @name=name
  @breed=breed
  @id=id
end

def self.create_table
  sql= <<-SQL
  CREATE TABLE dogs (
    id INTEGER PRIMARY KEY,
    name TEXT,
    breed TEXT
  )
  SQL
  DB[:conn].execute(sql)
end

def self.drop_table
  sql= <<-SQL
  DROP TABLE dogs
  SQL

  DB[:conn].execute(sql)
  end

def save
  sql= <<-SQL
  INSERT INTO dogs (name,breed) VALUES (?,?)
  SQL

  DB[:conn].execute(sql,self.name,self.breed)
  @id=DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
  self
end

def self.create(name:,breed:)
  dog=Dog.new(name: name,breed: breed)
  dog.save
  dog
end

def self.new_from_db(row)
id=row[0]
name=row[1]
breed=row[2]

dog=Dog.new(name:name,breed:breed,id:id)
dog
end

def self.find_by_id(argId)
  sql= <<-SQL
  SELECT * FROM dogs WHERE id=?
  SQL

  DB[:conn].execute(sql,argId).map do |row|

  self.new_from_db(row)
end.first
end

def self.find_or_create_by(name:,breed:)
  dog=DB[:conn].execute("SELECT * FROM dogs WHERE name=? AND breed=?",name,breed)

  if !dog.empty?
    data=dog[0]
    dog=Dog.new(name:data[1],breed:data[2],id:data[0])
  else
    dog=self.create(name: name,breed: breed)
  end
end

def self.find_by_name(argName)
  sql= <<-SQL
  SELECT * FROM dogs WHERE name=?
  SQL

  DB[:conn].execute(sql,argName).map do |row|

  self.new_from_db(row)
end.first
end

def update
  sql= <<-SQL
  UPDATE dogs SET name=?,breed=? WHERE id =?
  SQL
  DB[:conn].execute(sql,self.name,self.breed,self.id)
end
end
