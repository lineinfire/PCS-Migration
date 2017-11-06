select * from fn_saving_deposit;

select sum(deposit_amount) from fn_saving_deposit
where account_no = ''
;

select * from fn_saving_withdrawal;

select sum(withdraw_amount) from fn_saving_withdrawal
where account_no = ''
;

select saving_product_type, saving_product_code, count(*), sum(current_balance) as total, sum(interest_booked) as int_booked, sum(unbooked_int) as unbook
from mg_saving_normal
group by saving_product_type, saving_product_code;





select * from mg_saving_normal;
 
 -- where old_account_no ='N00500060';

drop table mg_saving_normal;



create table mg_saving_normal
as
SELECT rownum as SN, xyz.CLIENT_NAME, xyz.CLIENT_CODE,saving_ACCOUNT_NO, xyz.OLD_ACCOUNT_NO, 
  xyz.ACCOUNT_OPEN_DATE, xyz.ACCOUNT_OPEN_DATE_AD, xyz.SAVING_PRODUCT_CODE, xyz.SAVING_PRODUCT_TYPE, xyz.ACCOUNT_STATUS,
  xyz.MIN_BALANCE, xyz.CURRENT_BALANCE, xyz.INTEREST_RATE, nvl(xyz.INTEREST_BOOKED,0) as INTEREST_BOOKED, nvl(xyz.Unbooked_int_dump,0) as UNBOOKED_INT, 
  xyz.INT_CAPITALIZATION_METHOD, xyz.INT_CAPITALIZATION_METHOD_DESC, xyz.LAST_INT_CAPITALIZATION_DATE,
  xyz.MATURITY_DATE, xyz.REFERENCE_ACCOUNT_NO, xyz.DEPOSIT_PERIOD
  FROM (  SELECT trim(MC.FNAME) || ' ' || trim(MC.LNAME) AS CLIENT_NAME,
                 --MC.OLD_MEMBER_CODE AS CLIENT_CODE
                  substr(MC.CLIENT_NO,-5) as CLIENT_CODE,
                 --SA.OLD_ACCOUNT_NO,
                 SA.saving_ACCOUNT_NO,
                 'N' || sa.SAVING_PRODUCT_CODE ||substr(SA.saving_ACCOUNT_NO,-5) as OLD_ACCOUNT_NO,
                 DATE_CONVERSION_PKG.F_ENG_TO_NEP_DAILY (Sa.ACCOUNT_OPEN_DATE)
                    AS ACCOUNT_OPEN_DATE,
                     to_char(Sa.ACCOUNT_OPEN_DATE,'YYYY-MM-DD') AS ACCOUNT_OPEN_DATE_AD,
                 SA.SAVING_PRODUCT_CODE,
                 FN_SAVING_UTILITY_PKG.F_SAVING_PRODUCT_NAME (
                    SA.SAVING_PRODUCT_CODE)
                    AS SAVING_PRODUCT_TYPE,
                 SA.ACCOUNT_STATUS,
                 (SELECT MIN_BALANCE
                    FROM FN_SAVING_PRODUCTS
                   WHERE product_Code = SA.SAVING_PRODUCT_CODE)
                    AS MIN_BALANCE,
                 --sa.current_balance + sa.received_interest_amount
                 nvl((select SUM (NVL (DEPOSIT_AMOUNT, 0)) from fn_saving_deposit
where account_no = SA.ACCOUNT_NO
),0) -
                  nvl((select 
                           -1 * SUM (
                                (  WITHDRAW_AMOUNT
                                 + NVL (CLOSING_CHARGE, 0)
                                 + NVL (OTHER_INCOME_EXP_AMOUNT, 0)))
                  from fn_saving_withdrawal
where account_no = SA.ACCOUNT_NO
),0)
                    AS CURRENT_BALANCE,
                 SA.INTEREST_RATE,
                   (SELECT SUM (INTEREST_AMOUNT)
                      FROM FN_SAVING_INTEREST_ACCURATE sia
                     WHERE sia.ACCOUNT_NO = sa.ACCOUNT_NO AND posted_Y_N = 'N')
                      AS INTEREST_BOOKED,
                   (SELECT NVL(SUM (interest_amount), 0)
                      FROM FN_SAVING_INTEREST sI
                     WHERE SI.ACCOUNT_NO = sa.ACCOUNT_NO AND NVL(posted_Y_N, 'N') = 'N')
                    AS Unbooked_int_dump,
                 SA.INT_CAPITALIZATION_METHOD,
                 DECODE (SA.INT_CAPITALIZATION_METHOD,
                         '1', 'Monthly',
                         '3', 'Quaterly',
                         '6', 'Semi',
                         'Annually')
                    AS INT_CAPITALIZATION_METHOD_DESC,
                 last_int_date_bs AS LAST_INT_CAPITALIZATION_DATE,
                 DATE_CONVERSION_PKG.F_ENG_TO_NEP_DAILY (sa.MATURITY_DATE)
                    AS MATURITY_DATE,
                 (SELECT 'N'||  sa.SAVING_PRODUCT_CODE ||substr(saving_ACCOUNT_NO,-5)
                    FROM FN_CLIENT_SAVING_ACCOUNT
                   WHERE ACCOUNT_NO = SA.REFERENCE_ACCOUNT_NO)
                    AS REFERENCE_ACCOUNT_NO,
                 DECODE (SA.DEPOSIT_PERIOD, '0', NULL, SA.DEPOSIT_PERIOD)
                    AS DEPOSIT_PERIOD
            FROM FN_CLIENT_SAVING_ACCOUNT sa left join FN_MEMBER_CLIENTS MC on SA.CLIENT_NO = MC.CLIENT_NO
            left join mg_saving_last_int_date ms on ms.ACCOUNT_NO = sa.ACCOUNT_NO
           WHERE 
           SA.ACCOUNT_STATUS='A' 
        ORDER BY SA.SAVING_ACCOUNT_NO) xyz,
       FN_SAVING_PRODUCTS sp
 WHERE sp.PRODUCT_CODE = xyz.saving_product_code AND PRODUCT_TYPE_CODE = '04'
 ;
 
 select *from FN_SAVING_PRODUCTS where PRODUCT_TYPE_CODE='04';

