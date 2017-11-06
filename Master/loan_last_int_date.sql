
drop table mg_loan_last_int_date

create table mg_loan_last_int_date
as
  select loan_no, last_int_date, nepali_date as last_int_date_bs from
  (
  select loan_no, max(int_cal_date) last_int_date from
  FN_LOAN_INTEREST_LOG
  group by LOAN_NO
  ) y
  left join MS_DAILY_DATE z
  on y.last_int_date = z.ENGLISH_DATE;