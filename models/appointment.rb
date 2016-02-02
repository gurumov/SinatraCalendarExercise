

class Appointment

  attr_reader :id, :user_id, :group_id, :description, :start_time,
              :end_time, :date, :appointment_type, :db_start_time, :db_end_time


  def initialize(id, user_id, group_id, date, start_time, end_time, description, appointment_type)
    @user_id = user_id
    @group_id = group_id
    @date = date.to_s
    if start_time.is_a? String
      @start_time = start_time
      @end_time = end_time
    else
      @start_time =  start_time.to_s.split(/ /)[1]
      @end_time = end_time.to_s.split(/ /)[1]
    end
    @db_start_time = start_time
    @db_end_time = end_time
    @description = description
    @appointment_type = appointment_type
    @id = id

  end

  def create_new_appointment()
    db = SQLite3::Database.open("calendar.db")
    db.transaction do |dtb|
      dtb.execute( "insert into Appointments(user_id, group_id, date,
                    start_time, end_time, description, appointment_type)
                    values (:user_id, :group_id, :date, :start_time, :end_time,
                    :description, :appointment_type)",
                    "user_id" => @user_id,
                    "group_id" => @group_id,
                    "date" => @date,
                    "start_time" => @start_time,
                    "end_time" => @end_time,
                    "description" => @description,
                    "appointment_type" => @appointment_type)
      @id = dtb.last_insert_row_id
    end
    db.close
  end

end
