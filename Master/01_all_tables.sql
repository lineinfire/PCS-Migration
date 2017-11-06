select * from mg_kyc;

select * from mg_saving_normal

-- where client_name like '%Bir Krishna Maharjan%'
;

select sn, old_account_no, client_code, client_name, saving_product_type,
  current_balance, interest_booked, unbooked_int
from mg_saving_normal
where saving_product_code = '005'
order by client_code;


select 
  saving_product_code, saving_product_type, 
  sum(current_balance), sum(interest_booked) as Booked, sum(unbooked_int) as UnBooked 
from mg_saving_normal
group by saving_product_code, saving_product_type
order by saving_product_code;

select sn, old_account_no, client_code, client_name, saving_product_type,
  current_balance, interest_booked, unbooked_int
from mg_saving_recurring
order by client_code
;

select *
from mg_saving_recurring;

select 
  saving_product_code, saving_product_type, 
  sum(current_balance), sum(interest_booked) as Booked, sum(unbooked_int) as UnBooked 
from mg_saving_recurring
group by saving_product_code, saving_product_type
order by saving_product_code;


select * from mg_saving_fixed;

select * from mg_loan;

select * from mg_share_kyc;

select * from mg_share_tran;



select *from FN_SAVING_PRODUCTS



select *from fn_saving_deposit

select *from FN_CLIENT_SAVING_ACCOUNT where SAVING_ACCOUNT_NO='FIS0003806000019'

--00038S4245

select sum(interest_amount) from Fn_saving_interest_accurate where ACCOUNT_NO='00038S4245';

SELECT SUM (INTEREST_AMOUNT)
                    FROM FN_SAVING_INTEREST sI where account_no = '00038S4245';
                    
                    select * from FN_SAVING_INTEREST  where account_no = '00038S4245' and booked_Y_N='N' ;
                    ;
                    
                    select * from sod_eod;
                    
                    
                    
                    select account_no, max(transaction_date) as last_int_date_ad
    from FN_SAVING_INTEREST
    group by account_no;
    
    
    SELECT *FROM FN_SAVING_INTEREST_ACCURATE WHERE ACCOUNT_NO = '00038S4142';
-- yesko last transaction date is 07/15/2017


SELECT SUM (INTEREST_AMOUNT)
                    FROM FN_SAVING_INTEREST sI
                    left join mg_saving_last_int_booked_date mg1
                    on si.account_no = mg1.account_no
                   WHERE SI.ACCOUNT_NO = '00038S4142'
                   and si.transaction_date >mg1.last_int_booked_date_ad;