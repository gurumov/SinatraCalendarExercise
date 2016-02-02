helpers do

APPOINTMENT_TYPE = Hash[:all => 0, :todo => 1, :meeting => 2, :university => 3, :work => 4, :urgent => 5, :other => 6]
WEEKDAYS = Hash[1 => "Monday" , 2 => "Tuesday", 3 => "Wednesday", 4 => "Thursday", 5 => "Friday", 6 => "Saturday" ,0 => "Sunday" ]
MONTH_DAYS = Hash[1 => 31, 2 => 28, 3 => 31, 4 => 30, 5 => 31, 6 => 30, 7 => 31, 8 => 31, 9 => 30, 10 => 31, 11 => 30, 12 => 31]

  def logged?
    not session[:user].nil?
  end


	def mixed_daily_appointments_of_type(type)
  	user = session[:user]
    date = session[:shown_date].to_s
		events = user.get_mixed_appointments(date, type)
	end

	def mixed_weekly_appointments_of_type(type)
  	user = session[:user]
    date = session[:shown_date].to_s
		events =	user.get_mixed_appointments_for_week(date, type)
	end

	def mixed_monthly_appointments_of_type(type)
  	user = session[:user]
    date = session[:shown_date].to_s

		events =	user.get_mixed_appointments_for_month(date, type)

	end

	def user_groups
		user = session[:user]
		user.get_groups
	end


  def types_hash
    APPOINTMENT_TYPE
  end

  def week_days
    WEEKDAYS
  end

  def get_date(week, day)
    d = session[:shown_date]
    first_of_month = (d - d.mday + 1)
    first_monday = first_of_month - (first_of_month.wday - 1) % 7
    return (first_monday + (7 * week + day))
  end

  def days_in_month
    d = session[:shown_date]
    (d.month == 2 and d.leap?) ?  29 :  MONTH_DAYS[d.month]
  end

  def weeks_in_month
    d = session[:shown_date]
    if d.month != 2

      if MONTH_DAYS[d.month] == 30
        return 5
      else
        first_of_month = (d - d.mday + 1)
        (first_of_month.sunday? or first_of_month.saturday?) ? 6 : 5
      end
    else
      d.leap? ? 5 : 4
    end
  end

  def agregate_events(events, days)
    agregat = Hash.new
    (1..days).each do |d|
      agregat[d] = []
      events.each do |e|
        event_day = Date.parse(e.date.to_s).mday
        if event_day > d
          break
        elsif event_day == d
          agregat[d].push(e)
        end
      end
    end
    return agregat
  end

  def agregate_events_for_week(events)
    agregat = Hash.new
    (1..7).each do |d|
      agregat[d] = []
      day = (session[:shown_date] + d - 1).mday
      events.each do |e|
        event_day = Date.parse(e.date.to_s).mday
        if event_day > day
          break
        elsif event_day == day
          agregat[d].push(e)
        end
      end
    end
    return agregat
  end

  def agregate_events_hourly(events)
    agregat = Hash.new
    (1..24).each do |h|
      agregat[h] = []
      events.each do |e|
        if e.db_start_time.hour > h
          break
        elsif e.db_start_time.hour <= h and e.db_start_time.hour > h - 1
          agregat[h].push(e)
        end
      end
    end
    return agregat
  end

  def weekend?(date)
    (date.sunday? or date.saturday?) ? "weekend" : ""
  end

  def past?(date)
    date < Date.today
  end

  def tday?(date)
    today = Date.today
    (today.to_s.eql? date.to_s) ? "today" : ""
  end
end
