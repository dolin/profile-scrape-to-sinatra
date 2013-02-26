require 'rubygems'  
require 'sinatra' 
require 'open-uri'
require 'nokogiri'
require 'pp'
require 'sqlite3'

class Student
  attr_accessor :doc, :id, :name, :url, :bio, :aspirations, :interests, :work, :education, :misc

 @@db = SQLite3::Database.new('student18.db')

  def self.scrape_student_urls
    begin

    url = "http://students.flatironschool.com"
    homepage = Nokogiri::HTML(open("#{url}"))

    profile_name_selector = homepage.css("div.name-position h2")

    profile_name_selector.each do |h2|
      s = Student.new
      profile_name = h2.text
      profile_href = url + "/" + h2.parent.parent['href'].to_s
      s.name = profile_name
      s.url = profile_href
      s.full_scrape
      s.save
    end

  rescue
  end

  end

  def full_scrape
    begin
    self.doc =  Nokogiri::HTML(open("#{self.url}"))
    @bio = @doc.css("div.two_third.last h2 + p").text
    @aspirations = @doc.css("div.two_third.last h3:nth-child(4) + p").text
    @interests = @doc.css("div.two_third.last h3:nth-child(6) + p").text
    @work = @doc.css("section#former_life div.one_half:first-child ul.check_style").text
    @education = @doc.css("section#former_life div.one_half.last ul.check_style").text
    @misc = @doc.css("div.one_fourth").text.strip
  rescue
  end
  end

  def self.create_table
    @@db.execute("CREATE TABLE IF NOT EXISTS students (id INTEGER PRIMARY KEY, name TEXT, url TEXT, bio TEXT, aspirations TEXT, interests TEXT, work TEXT, education TEXT, misc TEXT)")
  end

  def save
    @@db.execute("INSERT INTO students (name, url, bio, aspirations, interests, work, education, misc)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?)", [@name, @url, @bio, @aspirations, @interests, @work, @education, @misc])
    @id = @@db.execute("SELECT id FROM students WHERE name = ?", @name).first.flatten

    # after saving the student
    # do a select for that student based on name or url
    # get their ID that was just created
    # populate @id (the student's id attriute with that value)
    # so further updates can reference that student
  end

  def self.find_by_name(student_name)
    rows = @@db.execute("SELECT * FROM students WHERE name = ?", student_name)
    rows.collect{|row| self.new_from_db(row)}.first
  end

  def self.find(student_id)
    rows = @@db.execute("SELECT * FROM students WHERE id = ?", student_id)
    rows.collect{|row| self.new_from_db(row)}.first
  end

  def self.all
    rows = @@db.execute("SELECT * FROM students")
    rows.collect{|row| self.new_from_db(row)}
  end

  def self.new_from_db(row)
    s = Student.new
    s.id = row[0]
    s.name = row[1]
    s.url = row[2]
    s.bio = row[3]
    s.aspirations = row[4]
    s.interests = row[5]
    s.work = row[6]
    s.education = row[7]
    s.misc = row[8]
    return s
  end

end

get '/' do  
  @students = Student.all  
  erb :home  
end

get '/:id' do
  @student = Student.find params[:id]
  erb :profile
end

# Commented out below is the CLI for SQL queries 

# Student.create_table
# Student.scrape_student_urls

# #Command Line User Interface starts here
# standard_menu = 
#   "*****************************************************
#    Please enter one of the following commands:
#    Note x represents the first & last names of the student you are looking up
#      FIND x
#        to retrieve all information about a student
#        Example: FIND John Smith
#      ID x
#        to retrieve a student's ID
#        Example: ID John Smith
#      EXIT
#        to exit
#   "

# puts "Welcome to the Flatiron School Student Database.\n" + standard_menu

# command = ""
# while command != "EXIT"
#   command = gets.strip
#   student_name_inquiry = command.split.drop(1).join(" ")
  
#   if command.split.shift == "FIND" 
#     puts Student.find_by_name(student_name_inquiry)
#   elsif command.split.shift == "ID"
#     student_id = Student.find_id(student_name_inquiry).fetch(0)
#     puts "The Student ID number is #{student_id}"
#   end
#   puts standard_menu
# end

# puts "goodbye!"

