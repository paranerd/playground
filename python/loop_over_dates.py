from datetime import date, timedelta

sdate = date(2020, 1, 1)
edate = date(2020, 12, 31)
delta = edate - sdate

for i in range(delta.days + 1):
  day = sdate + timedelta(days=i)
  print(day)
