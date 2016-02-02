

class Group
  attr_reader :name, :id, :description, :admin_user_id
  attr_writer :id

  def initialize(id, name, description, admin_user_id)
    @name = name
    @description = description
    @admin_user_id = admin_user_id
    @id = id
  end

  def create_group()

    db = SQLite3::Database.open("calendar.db")
    group_id = -1
    db.transaction do |dtb|
      dtb.execute( "insert into Groups(name, description, admin_user_id)
                    values (:name, :description, :admin_user_id)",
                    "name" => @name,
                    "description" => @description,
                    "admin_user_id" => @admin_user_id)
      @id = dtb.last_insert_row_id
    end
    db.close
    add_user(@admin_user_id)
  end

  def add_user(user_id)
    db = SQLite3::Database.open("calendar.db")
    db.transaction do |dtb|
      dtb.execute("insert into GroupMembers(user_id, group_id) values (:user_id, :group_id)",
                  "user_id" => user_id,
                  "group_id" => @id)
    end
    db.close
  end


  def get_appointments_for_date(date, appointment_type)
    result = []
    appointment_type == 0 ? query = "" : query = "and appointment_type = #{appointment_type}"
    db = SQLite3::Database.open("calendar.db")
    db.type_translation = true
    db_results = db.execute("select * from Appointments where group_id =
                            :group_id and date = :date
                            #{query}
    					              ORDER BY date, start_time  ASC",
                            "group_id" => @id,
                            "date" => date)

    db_results.each do |a|
      result.push(Appointment.new(a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7]))
    end
    return result
  end


  def get_weekly_appointments(date, appointment_type)
    result = []
    appointment_type == 0 ? query = "" : query = "and appointment_type = #{appointment_type}"
    db = SQLite3::Database.open("calendar.db")
    db.type_translation = true
    db_results = db.execute("select * from Appointments where group_id =
                            :group_id and (date BETWEEN :date and
                            (Select date(:date, '+7 days')))
                            #{query}
                             ORDER BY date, start_time  ASC",
                            "group_id" => @id,
                            "date" => date)

    db_results.each do |a|
      result.push(Appointment.new(a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7]))
    end
    return result
  end

  def get_monthly_appointments(date, appointment_type)
    result = []
    appointment_type == 0 ? query = "" : query = "and appointment_type = #{appointment_type}"
    #  appointment_type = :appointment_type
    #"appointment_type" => appointment_type
    db = SQLite3::Database.open("calendar.db")
    db.type_translation = true
    db_results = db.execute("select * from Appointments where group_id =
                            :group_id and (date BETWEEN
                            (Select date(:date, 'start of month')) and
                            (Select date(:date, 'start of month', '+1 months')))
                            #{query}
                          ORDER BY date, start_time  ASC",
                            "group_id" => @id,
                            "date" => date)

    db_results.each do |a|
      result.push(Appointment.new(a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7]))
    end
    return result
  end

  def self.find_group(group_id)
  	db = SQLite3::Database.open("calendar.db")
    db.type_translation = true
  	result = db.get_first_row("select * from Groups where id = :group_id",
  										          "group_id" => group_id)

    (result.nil? or result.empty?) ? nil : Group.new(result[0], result[1], result[2], result[3])
  end

  def get_members
    result = []
    db = SQLite3::Database.open("calendar.db")
    db.type_translation = true
    db_results = db.execute("select u.id, u.email, u.password, u.name, u.account_type
                            FROM Users u join GroupMembers gm on gm.user_id = u.id
                            WHERE gm.group_id = :group_id and
                            gm.user_id != :group_admin ORDER BY u.name ASC",
                            "group_id" => @id,
                            "group_admin" => @admin_user_id)
    db_results.each do |u|
      result.push(User.new(u[0], u[1], u[2], u[3], u[4]))
    end
    return result
  end
end
