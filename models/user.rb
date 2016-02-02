
class User

  attr_reader :id, :email, :password, :name, :account_type

  def initialize(id, email, password, name, account_type)
    @id = id
    @email = email
    @password = password
    @name = name
    @account_type = account_type
  end

  def create_new_user()
    db = SQLite3::Database.open("calendar.db")
    db.transaction do |dtb|
      dtb.execute( "insert into Users(email, password, name, account_type)
                    values (:email, :password, :name, :account_type)",
                    "email" => email,
                    "password" => password,
                    "name" => name,
                    "account_type" => account_type)
      @id = dtb.last_insert_row_id
    end
    db.close
  end


  def get_personal_appointments(date, appointment_type)
    result = []
    appointment_type == 0 ? query = "" : query = "and appointment_type = #{appointment_type}"
    db = SQLite3::Database.open("calendar.db")
    db.type_translation = true
    db_results = db.execute("select * from Appointments where user_id = :user_id
    					               and date = :date
                             #{query}
    					               ORDER BY date, start_time  ASC",
                            "date" => date,
                            "user_id" => @id)
    db_results.each do |a|
      result.push(Appointment.new(a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7]))
    end
    return result
  end

  def get_personal_appointments_for_week(date, appointment_type)
    result = []
    appointment_type == 0 ? query = "" : query = "and appointment_type = #{appointment_type}"
    db = SQLite3::Database.open("calendar.db")
    db.type_translation = true
    db_results = db.execute("select * from Appointments where user_id = :user_id
                            and (date BETWEEN :date and
                            (Select date(:date, '+7 days')))
                            #{query}
                            ORDER BY date, start_time  ASC",
                            "date" => date,
                            "user_id" => @id)
    db_results.each do |a|
      result.push(Appointment.new(a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7]))
    end
    return result
  end

  def get_personal_appointments_for_month(date, appointment_type)
    result = []
    appointment_type == 0 ? query = "" : query = "and appointment_type = #{appointment_type}"
    db = SQLite3::Database.open("calendar.db")
    db.type_translation = true
    db_results = db.execute("select * from Appointments where user_id = :user_id
                            and (date BETWEEN
                            (Select date(:date, 'start of month')) and
                            (Select date(:date, 'start of month', '+1 months')))
                            #{query}
     					              ORDER BY date, start_time  ASC",
                            "user_id" => @id,
                            "date" => date)

    db_results.each do |a|
      result.push(Appointment.new(a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7]))
    end
    return result
  end


  def get_group_appointments(date, appointment_type)
    result = []
    appointment_type == 0 ? query = "" : query = "and a.appointment_type = #{appointment_type}"
    db = SQLite3::Database.open("calendar.db")
    db.type_translation = true
    db_results = db.execute("select a.id, a.user_id, a.group_id, a.date,
                            a.start_time, a.end_time, a.description,
                            a.appointment_type from Appointments a join
                            GroupMembers gm on gm.group_id = a.group_id where
                            gm.user_id = :user_id	and a.date = :date
                            #{query}
                            ORDER BY a.date, a.start_time  ASC",
                            "user_id" => @id,
                            "date" => date)
    db_results.each do |a|
      result.push(Appointment.new(a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7]))
    end
    return result
  end

  def get_group_appointments_for_week(date, appointment_type)
    result = []
    appointment_type == 0 ? query = "" : query = "and a.appointment_type = #{appointment_type}"
    db = SQLite3::Database.open("calendar.db")
    db.type_translation = true
    db_results = db.execute("select  a.id, a.user_id, a.group_id, a.date,
                            a.start_time, a.end_time, a.description,
                            a.appointment_type from Appointments a join
                            GroupMembers gm on gm.group_id = a.group_id
                            where gm.user_id = :user_id and (a.date BETWEEN
                            :date and (Select date(:date, '+7 days')))
                            ORDER BY a.date, a.start_time  ASC",
                            "user_id" => @id,
                            "date" => date)
    db_results.each do |a|
      result.push(Appointment.new(a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7]))
    end
    return result
  end

  def get_group_appointments_for_month(date, appointment_type)
    result = []
    appointment_type == 0 ? query = "" : query = "and a.appointment_type = #{appointment_type}"
    db = SQLite3::Database.open("calendar.db")
    db.type_translation = true
    db_results = db.execute("select a.id, a.user_id, a.group_id, a.date,
                            a.start_time, a.end_time, a.description,
                            a.appointment_type from Appointments a join
                            GroupMembers gm on gm.group_id = a.group_id
                            where gm.user_id = :user_id and (a.date BETWEEN
                            (Select date(:date, 'start of month')) and
                            (Select date(:date, 'start of month', '+1 months')))
                            #{query}
                  					ORDER BY a.date, a.start_time  ASC",
                            "user_id" => @id,
                            "date" => date)
    db_results.each do |a|
      result.push(Appointment.new(a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7]))
    end
    return result
  end

  def get_mixed_appointments(date, appointment_type)
    result = []
    appointment_type == 0 ? query = "" : query = "and appointment_type = #{appointment_type}"
    db = SQLite3::Database.open("calendar.db")
    db.type_translation = true
    db_results = db.execute("select * from Appointments where
                            (user_id = :user_id	or group_id IN
                            (Select group_id from GroupMembers
                            where user_id = :user_id)) and date = :date
                            #{query}
                            ORDER BY date, start_time  ASC",
                            "user_id" => @id,
                            "date" => date)
    db_results.each do |a|
      result.push(Appointment.new(a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7]))
    end
    return result
  end

  def get_mixed_appointments_for_week(date, appointment_type)
    result = []
    appointment_type == 0 ? query = "" : query = "and appointment_type = #{appointment_type}"
    db = SQLite3::Database.open("calendar.db")
    db.type_translation = true
    db_results = db.execute("select * from Appointments where
                            (user_id = :user_id	or group_id IN
                            (Select group_id from GroupMembers
                            where user_id = :user_id)) and
                            (date BETWEEN :date and (Select date(:date, '+7 days')))
                            #{query}
                            ORDER BY date, start_time  ASC",
                            "user_id" => @id,
                            "date" => date)
    db_results.each do |a|
      result.push(Appointment.new(a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7]))
    end
    return result
  end

  def get_mixed_appointments_for_month(date, appointment_type)
    result = []
    appointment_type == 0 ? query = "" : query = "and appointment_type = #{appointment_type}"
    db = SQLite3::Database.open("calendar.db")
    db.type_translation = true
    db_results = db.execute("select * from Appointments where
                            (user_id = :user_id	or group_id IN
                            (Select group_id from GroupMembers
                            where user_id = :user_id)) and
                            (date BETWEEN
                            (Select date(:date, 'start of month')) and
                            (Select date(:date, 'start of month', '+1 months')))
                            #{query}
                            ORDER BY date, start_time  ASC",
                            "user_id" => @id,
                            "date" => date)
    db_results.each do |a|
      result.push(Appointment.new(a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7]))
    end
    return result
  end


  def self.login_user(email, password)
    db=SQLite3::Database.open("calendar.db")
    db.type_translation = true
    result = db.get_first_row("select * from Users where email = :email
                              and password = :password",
                              "email" => email,
                              "password" => password)

    result.empty? ? nil : User.new(result[0], result[1], result[2], result[3], result[4])
  end

  def get_groups
    result = []
    db=SQLite3::Database.open("calendar.db")
    db.type_translation = true
  	db_results = db.execute("select gr.id, gr.name, gr.description,
                            gr.admin_user_id from Groups gr join GroupMembers gm
                            on gm.group_id = gr.id where gm.user_id = :user_id
                            ORDER BY gr.name ASC",
  							            "user_id" => @id)
    db_results.each do |a|
      result.push(Group.new(a[0], a[1], a[2], a[3]))
    end
    return result
  end

  def self.get_users
    result = []
    db=SQLite3::Database.open("calendar.db")
    db.type_translation = true
    db_results = db.execute("select * from Users ORDER BY name ASC")

    db_results.each do |u|
      result.push(User.new(u[0], u[1], u[2], u[3], u[4]))
    end
    return result
  end

  def self.get_users_without(user_id)
    result = []
    db=SQLite3::Database.open("calendar.db")
    db.type_translation = true
    db_results = db.execute("select * from Users  where id != :id ORDER BY name ASC",
                            "id" => user_id)

    db_results.each do |u|
      result.push(User.new(u[0], u[1], u[2], u[3], u[4]))
    end
    return result
  end


  def self.find_user(user_id)
    db=SQLite3::Database.open("calendar.db")
    db.type_translation = true
    db_results = db.execute("select * from Users WHERE id = :user_id",
                            "user_id" => user_id)

    db_results.each do |u|
      result.push(User.new(u[0], u[1], u[2], u[3], u[4]))
    end
    return result
  end

end
