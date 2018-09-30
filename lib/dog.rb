class Dog
 attr_accessor :name, :breed, :id

    @@all = []

  def initialize(name:, breed:, id=nil)
    @@all << self
    @name = name
    @breed = breed
    @id = id
  end


 def self.create_table

   sql = <<-SQL
   CREATE TABLE dogs ()

   SQL
 end



end
