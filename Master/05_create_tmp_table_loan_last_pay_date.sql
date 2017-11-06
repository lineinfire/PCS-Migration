
drop table tmp_view_last_payment;

create table tmp_view_last_payment 
as
select a.*, b.today_date, b.today_date - a.last_payment_date  as DayCount from (
select loan_no, last_payment_date, DATE_CONVERSION_PKG.F_ENG_TO_NEP_DAILY(last_payment_date) last_payment_bs from (
select loan_no, max(payment_date) last_payment_date from fn_loan_repayment lr
    group by loan_no ) xyz) a, (
    select * from sod_eod where length(tran_office_code) = 5
    ) b
    ;
    
    select * from tmp_view_last_payment where daycount is null;    
    
SELECT Y.loan_no,
  b.Today_Date - Y.LastPayDate AS DayCount
FROM
  (SELECT lm.*,
    NVL(lp.last_payment_date, lm.loan_date) AS LastPayDate
  FROM fn_loan_master lm
  LEFT JOIN tmp_view_last_payment lp
  ON lm.loan_no = lp.loan_no
  ) Y,
  ( SELECT * FROM sod_eod WHERE LENGTH(tran_office_code) = 5
  ) b ;
    
    select * from sod_eod where length(tran_office_code) = 5;
    
    
select * from fn_loan_master;