SELECT SUM(interest_amount) FROM fn_saving_interest_accurate 
                WHERE posted_y_n='N' 
                AND account_no = :account_no 
                AND transaction_date <= NVL(:p_date, SYSDATE);
                
select * from fn_saving_interest_accurate where account_no='00128S650';

                
select * from fn_client_saving_account where saving_account_no='0020012806000066';