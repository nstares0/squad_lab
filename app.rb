require 'sinatra'
require  'better_errors'
require 'pry'
require 'pg'

configure :development do 
  use BetterErrors::Middleware
  BetterErrors.application_root = __dir__
end

set :conn, PG.connect(dbname: 'squad_lab')

before do 
  @conn = settings.conn

end


# REDIRECT MAIN PAGE

get '/' do
  redirect '/squads'
end
# SHOW SQUADS PAGE
get '/squads' do
squads = []
 @conn.exec("SELECT * FROM squad") do |result|
    result.each do |squad|
      squads << squad
    end
  end
    @squads = squads
erb :squads
end

get '/squads/new' do
erb :new_squad
  end

  post '/squads' do
@conn.exec("INSERT INTO squad (name) VALUES ($1)",[params[:name]])
redirect '/squads'
  end



get '/squads/:id' do
  #not sure if this does anything?
  id = params[:id].to_i
   squad =  @conn.exec("SELECT * FROM squad WHERE id=$1", [id])
   @squad = squad[0]
   erb :squad
 end

get '/squads/:id/edit' do
  id = params[:id].to_i
   squad =  @conn.exec("SELECT * FROM squad WHERE id=$1", [id])
   @squad = squad[0]
   erb :edit_squad
end

put '/squads/:id' do
  id = params[:id].to_i
  name = params[:name]
  mascot = params[:mascot]
  @conn.exec("UPDATE squad SET name=$1 WHERE id=$2", [name, id])
  @conn.exec("UPDATE squad SET mascot=$1 WHERE id=$2", [mascot, id])
  redirect '/'
  end

get '/squads/:id/students' do
  students = []
id = params[:id].to_i
@conn.exec("SELECT * FROM students WHERE squad_id=$1", [id]) do |result|
  result.each do |student|
    students << student
  end
end
@students = students
  erb :students  
end

get '/squads/:id/students/:student_id' do
student_id = params[:student_id].to_i 
student = @conn.exec("SELECT * FROM students WHERE id=$1", [student_id])
@student = student[0]
erb :student
end

get '/squads/:id/students/:student_id/edit' do
student_id = params[:student_id].to_i
student = @conn.exec("SELECT * FROM students where id=$1", [student_id])
@student = student[0] 
erb :edit_student
end

# post '/squads/:id/students' do 
# @conn.exec("INSERT INTO students (name) VALUES ($1)",[params[:name]])
# redirect '/squads/:id/students'
# end

put '/squads/:id/students/:student_id' do
student_id = params[:student_id].to_i
id = params[:id].to_i
name = params[:name]
age = params[:age].to_i
spirit_animal = params[:spirit_animal]
@conn.exec("UPDATE students SET (name,age,spirit_animal) = ($1,$2,$3) WHERE squad_id = $4 AND id = $5",[name,age,spirit_animal,id,student_id])
redirect "/squads/#{id}/students/#{student_id}"
# erb :student
end



