require 'rubygems'
require 'sinatra'
require 'sqlite3'
require './web_helpers.rb'
require './models.rb'
require 'date'

enable :sessions

# Index Page
#---------------------------------

get '/' do
  erb :indexPage
end

get '/registration' do
  erb :registrationPage
end

get '/login' do

  erb :login
end

get '/dailyView/?:type?' do
  @compact_view = true
	if params[:type].nil?
		@appointments = mixed_daily_appointments_of_type(APPOINTMENT_TYPE[:all])
	else
		@appointments = mixed_daily_appointments_of_type(params[:type])
	end

  @aggregated_appointments = agregate_events_hourly(@appointments)

  @date = session[:shown_date]

	erb :dailyView
end

get '/weeklyView/?:type?' do
  @compact_view = true
	if params[:type].nil? or params[:type].empty?
		@appointments = agregate_events_for_week(mixed_weekly_appointments_of_type(APPOINTMENT_TYPE[:all]))
    puts @appointments
	else
		@appointments  = agregate_events_for_week(mixed_weekly_appointments_of_type(params[:type]))
	end

  if params[:CompactView].nil? or params[:CompactView].empty?
    @checked_compact = ""
  else
    @checked_compact = "on"
  end
    @date = session[:shown_date]
	erb :weeklyView
end

get '/monthlyView/?:type?' do
	if params[:type].nil?
    puts 'alalalaa'
    ev = mixed_monthly_appointments_of_type(APPOINTMENT_TYPE[:all])
    puts ev.size
		@appointments = agregate_events(ev, days_in_month())
    puts " kor" if @appointments.nil?
	else
		@appointments = agregate_events(mixed_monthly_appointments_of_type(params[:type]), days_in_month())
	end
  @date = session[:shown_date]
	erb :monthlyView
end

get '/groupsView/?:group_id?' do
  @date = session[:shown_date]
  @user = session[:user]

	if params[:group_id].nil?

		@group_appointments = agregate_events(@user.get_group_appointments_for_month(@date.to_s, APPOINTMENT_TYPE[:all]), days_in_month())
		@group_name = "All groups"
	else

    puts params[:group_id]
    @group = Group.find_group(params[:group_id])
    days =  days_in_month()
    app = @group.get_monthly_appointments(@date.to_s, APPOINTMENT_TYPE[:all])
		@group_appointments = agregate_events(app, days)

    @group_appointments.keys.each do |k|
      puts @group_appointments[k]
    end
	end
	@user_groups = @user.get_groups
	erb :groupsView
end

get '/setupDB' do
  create_users_table
  create_groups_table
  create_appointments_table
  create_group_members_table
  admin = User.new(0, 'gurumov92@gmail.com', '12345' , 'georgi', 3)
  admin.create_new_user()
  redirect '/'
end

get '/nm' do
  session[:shown_date] = session[:shown_date].next_month
  redirect '/monthlyView'
end


get '/pm' do
  session[:shown_date] = session[:shown_date].prev_month
  redirect '/monthlyView'
end

get '/nw' do
  session[:shown_date] = session[:shown_date]  + 7
  redirect '/weeklyView'
end

get '/pw' do
  session[:shown_date] = session[:shown_date] - 7
  redirect '/weeklyView'
end

get '/nd' do
  session[:shown_date] = session[:shown_date] + 1
  redirect '/dailyView'
end

get '/pd' do
  session[:shown_date] = session[:shown_date] - 1
  redirect '/dailyView'
end

get '/ng/?:group_id?' do
  session[:shown_date] = session[:shown_date].next_month
  redirect "/groupsView/#{params[:group_id]}"
end

get '/pg/?:group_id?' do
session[:shown_date] = session[:shown_date].prev_month
redirect "/groupsView/#{params[:group_id]}"
end

get '/logout' do
  session.clear
  redirect '/'
end

post '/login' do
	email = params[:email]
  password = params[:password]

  user = User.login_user(email, password)

  redirect '/', error: 'There is no such point in the database' if user.nil?

	session[:user] = user
  session[:shown_date] = Date.today

	redirect '/dailyView'
end

post '/registration' do
	#validate
  email = params[:email]
  password = params[:password]
  password_confirm = params[:password_repeated]
  username = params[:username]
  account_type = params[:account_type]

  user = User.new(0,email, password, username, account_type)
  user.create_new_user
  #confirmation ?
  redirect '/'
end

post '/createGroup' do
	user = session[:user]
	group_name = params[:groupName]
	group_description = params[:description]
  group_members = params[:membersSelect]
	group = Group.new(0, group_name, group_description, user.id)
  group.create_group
  puts  params[:membersSelect].size
   params[:membersSelect].each do |m|
    group.add_user(m.to_i)
  end
	redirect "/groupsView/#{group.id}"
end

post '/createAppointment' do
	user = session[:user]
	date = params[:event_date]
	start_time = params[:start_time]
  end_time = params[:end_time]
	description = params[:description]
	appointment_type = params[:appointment_type]
	group_id = params[:group_id]

  appointment = Appointment.new(0, user.id, group_id, date, start_time, end_time, description, appointment_type)
  appointment.create_new_appointment

	if not group_id.eql? "0"
		redirect "/groupsView/#{group_id}"
	else
		redirect '/weeklyView'
	end
end
