
def create_users_table
  db = SQLite3::Database.open("calendar.db")
  db.execute("CREATE TABLE IF NOT EXISTS Users(id INTEGER PRIMARY KEY, email TEXT, password TEXT, name TEXT, account_type INTEGER)")
  db.close
end

def create_appointments_table
  db = SQLite3::Database.open("calendar.db")
  db.execute("CREATE TABLE IF NOT EXISTS Appointments(id INTEGER PRIMARY KEY, user_id INTEGER DEFAULT 0, group_id INTEGER DEFAULT 0, date DATE, start_time TIME, end_time TIME, description TEXT, appointment_type INTEGER, FOREIGN KEY(user_id) REFERENCES users(id), FOREIGN KEY(group_id) REFERENCES groups(id))")
  db.close
end

def create_groups_table
  db = SQLite3::Database.open("calendar.db")
  db.execute("CREATE TABLE IF NOT EXISTS Groups(id INTEGER PRIMARY KEY, name TEXT, description TEXT, admin_user_id INTEGER, FOREIGN KEY(admin_user_id) references Users(id))")
  db.close
end

def create_group_members_table
  db = SQLite3::Database.open("calendar.db")
  db.execute("CREATE TABLE IF NOT EXISTS GroupMembers(user_id INTEGER, group_id INTEGER, FOREIGN KEY(user_id) REFERENCES Users(id), FOREIGN KEY(group_id) REFERENCES Groups(id), PRIMARY KEY (user_id, group_id))")
  db.close
end


def first_event_for_user(user_id)
  db=SQLite3::Database.open("calendar.db")
  db.get_first_row("select * from DailyAppointments where user_id = :user_id and
                  date >= (Select date('now')) and start_time >= (Select time('now'))
                  ORDER BY date, start_time ASC",
                  "user_id" => user_id)
end

def first_group_event_for_user(user_id)
  db=SQLite3::Database.open("calendar.db")
  db.get_first_row("select * from GroupAppointments ga join GroupMembers gm on gm.group_id = ga.group_id
                  where gm.user_id = :user_id and
                  ga.date >= (Select date('now')) and ga.start_time >= (Select time('now'))
                  ORDER BY ga.date, ga.start_time ASC",
                  "user_id" => user_id)
end
