class Dog
 attr_accessor :name, :breed, :id

    @@all = []

  def initialize(name:, breed:, id: nil)
    @@all << self
    @name = name
    @breed = breed
    @id = id
  end

     #CREATE
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

     #DROP
     def self.drop_table
      DB[:conn].execute("DROP TABLE IF EXISTS dogs;")
     end

     #SAVE
     def save
        Dog.new(name: self.name, breed: self.breed)
        sql = <<-SQL
          INSERT INTO dogs (name, breed)
          VALUES (?, ?);
        SQL
        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs;")[0][0]
        self
      end

      #CREATE
      def self.create(name: , breed:)
        new_dog = Dog.new(name: name, breed: breed)
        new_dog.save
        new_dog
      end

      #NEW FROM DB
      def self.new_from_db(row)
        id = row[0]
        name = row[1]
        breed = row[2]
        self.new(id: id, name: name, breed: breed)
      end

      #FIND BY NAME
      def self.find_by_name(name)
          sql = "SELECT * FROM dogs WHERE name = ? LIMIT 1;"
          DB[:conn].execute(sql, name).map do |row|
          self.new_from_db(row)
          end.first
      end

      # FIND BY ID
      # returns a new dog object by id (FAILED - 1)
      def self.find_by_id(id)
        sql = "SELECT * FROM dogs WHERE id = ? LIMIT 1;"
        DB[:conn].execute(sql, id).map do |row|
        self.new(id: row[0], name: row[1], breed: row[2])
        end.first
      end

      #UPDATE
      def update
        sql = "UPDATE dogs SET name = ?, breed = ?  WHERE id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
      end

      # .FIND || CREATE BY
      #     creates an instance of a dog if it does not already exist (FAILED - 1)
      #     when two dogs have the same name and different breed, it returns the correct dog (FAILED - 2)
      #     when creating a new dog with the same name as persisted dogs, it returns the correct dog (FAILED - 3)

      def self.find_or_create_by(name:, breed:)
          target = DB[:conn].execute("SELECT * FROM dogs WHERE name = '#{name}' AND breed = '#{breed}'")
           if !target.empty?
             row = target[0]
             dog = self.new(id: row[0], name: row[1], breed: row[2]) # if doesnt exist create
           elsif target.empty?
             dog = self.create(name: name, breed: breed)# else return the one matching name && breed
           end
         else puts "404"
         dog
      end

end
