require 'sinatra'
require 'sinatra/flash'
require 'sinatra/reloader' if development?
require 'dm-core'
require 'dm-migrations'

# For Development, Use Local Database
configure :development do
    DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/application.db")
end

# For Production, Use the Database on the Server
configure :production do
    DataMapper.setup(:default, ENV['DATABASE_URL'])
end

# Create Students Table
class Student
    include DataMapper::Resource
    property :id, Serial
    property :firstname, String
    property :lastname, String
    property :gender, String
    property :birthday, String
    property :address, Text
    property :email, String
    property :phonenumber, String
    property :gpa, Numeric
end

# Create Comments Table
class Comment
    include DataMapper::Resource
    property :id, Serial
    property :title, String
    property :author, String
    property :content, Text
    property :createtime, DateTime  # This is created_at
end

DataMapper.finalize

# Only When we create Database, we create these two Tables: Students and Comments
if !File::exists?("./application.db")
    DataMapper.auto_migrate!
end

# Display all the Students
get '/students' do
    @title = "Student Infos"
    @students = Student.all
    erb :students
end

# Create a new Student Information
get '/students/new' do
    @title = "Create Student Info"
    erb :new_student
end

# Save the new Student Information
post '/students' do
    # Check if the User Logon
    if session[:login]
        # Check if All Required Information Fill in Correctly
        if Student.find(params[:id].to_i)
            flash[:error] = "Student ID is already in the Database, please Check again!"
            redirect '/students/new'
        end
        if params[:id] =~ /^\d{7}$/ && params[:firstname] != "" && params[:lastname] != "" && (params[:gender] == "Male" || params[:gender] == "Female") && params[:birthday] =~ /^\d{2}\/\d{2}\/\d{4}$/ && params[:address] != "" && params[:email] =~ /^\w+@\w+\.(com|edu)$/ && params[:phonenumber] =~ /^\d{3}-\d{3,4}-\d{4}$/
            @student = Student.new
            @student.id = params[:id].to_i
            @student.firstname = params[:firstname]
            @student.lastname = params[:lastname]
            @student.gender = params[:gender]
            @student.birthday = params[:birthday]
            @student.address = params[:address]
            @student.email = params[:email]
            @student.phonenumber = params[:phonenumber]
            if params[:gpa] =~ /^\d\.\d$/
                @student.gpa = params[:gpa].to_f
            elsif params[:gpa] !~ /^\d\.\d$/ && params[:gpa] != ""
                flash[:error] = "All Required Information Needs to be Filled In Correctly!"
                redirect '/students/new'
            end
            @student.save
            redirect '/students'
        else
            flash[:error] = "All Required Information Needs to be Filled In Correctly!"
            redirect '/students/new'
        end
    else
        flash[:error] = "Only When You Logon, You Can Create Student Information!"
        redirect '/login'
    end
end

# Show a Specific Student Information
get '/students/:id' do
    @title = "Show Student Info"
    @student = Student.get(params[:id])
    erb :show_student
end

# Delete a Specific Student Information
delete '/students/:id' do
    # Check if the User Logon
    if session[:login]
        @student = Student.get(params[:id])
        @student.destroy
        redirect '/students'
    else
        flash[:error] = "Only When You Logon, You Can Delete Student Information!"
        redirect '/login'
    end
end

# Edit a Specific Student Information
get '/students/:id/edit' do
    @title = "Edit Student Info"
    @student = Student.get(params[:id])
    erb :edit_student
end

# Save the Edited Student Information
put '/students/:id' do
    # Check if the User Logon
    if session[:login]
        @student = Student.get(params[:id])
        # Check if All Required Information Fill in Correctly
        if params[:firstname] != "" && params[:lastname] != "" && (params[:gender] == "Male" || params[:gender] == "Female") && params[:birthday] =~ /^\d{2}\/\d{2}\/\d{4}$/ && params[:address] != "" && params[:email] =~ /^\w+@\w+\.(com|edu)$/ && params[:phonenumber] =~ /^\d{3}-\d{3,4}-\d{4}$/
            @student.update(firstname: params[:firstname])
            @student.update(lastname: params[:lastname])
            @student.update(gender: params[:gender])
            @student.update(birthday: params[:birthday])
            @student.update(address: params[:address])
            @student.update(email: params[:email])
            @student.update(phonenumber: params[:phonenumber])
            if params[:gpa] =~ /^\d\.\d$/
                @student.update(gpa: params[:gpa].to_f)
            elsif params[:gpa] !~ /^\d\.\d$/ && params[:gpa] != ""
                flash[:error] = "All Required Information Needs to be Filled In Correctly!"
                redirect '/students/' << @student.id.to_s << '/edit'
            else
                @student.update(gpa: nil)
            end
            redirect '/students/' << @student.id.to_s
        else
            flash[:error] = "All Required Information Needs to be Filled In Correctly!"
            redirect '/students/' << @student.id.to_s << '/edit'
        end
    else
        flash[:error] = "Only When You Logon, You Can Edit Student Information!"
        redirect '/login'
    end
end

# Display all the Comment
get '/comments' do
    @title = "Comments"
    @comments = Comment.all
    erb :comments
end

# Create a new Comment
get '/comments/new' do
    @title = "Create Comment"
    erb :new_comment
end

# Save the new Comment
post '/comments' do
    if params[:title] != "" && params[:content] != ""
        @comment = Comment.new
        @comment.title = params[:title]
        if params[:author] != ""
            @comment.author = params[:author]
        end
        @comment.content = params[:content]
        @comment.createtime = Time.now
        @comment.save
        redirect '/comments'
    else
        flash[:error] = "All Required Information Needs to be Filled In Correctly!"
        redirect '/comments/new'
    end
end

# Show a Specific Comment
get '/comments/:id' do
    @title = "Show Comment"
    @comment = Comment.get(params[:id])
    erb :show_comment
end