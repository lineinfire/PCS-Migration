drop table mg_loan;

select * from fn_loan_master;

select * from mg_loan ;

--where daycount > 35;
--where loan_dno = 'L00040I0065000502'; 

--where LOAN_DNO='L00039I00029501';

create table mg_loan
as
SELECT rownum as SN, FN_MEMBER_CLIENTS_PKG.F_CLIENT_NAME_FROM_CLIENT_NO (LM.CLIENT_NO)
            AS client_name,
        -- MC.OLD_MEMBER_CODE AS CLIENT_CODE,
        substr(MC.CLIENT_NO,-5) as CLIENT_CODE,
         --LM.OLD_LOAN_NO AS LOAN_ACCOUNT_NO,
         LM.LOAN_DNO,
         'L'||substr(LM.LOAN_NO,-5) as LOAN_ACCOUNT_NO,
         date_conversion_pkg.f_eng_to_nep_daily (LM.LOAN_DATE) LOAN_DATE,
          to_char(LM.LOAN_DATE,'YYYY-MM-DD') AS LOAN_DATE_AD, 
         LP.LOAN_PRODUCT_NAME AS LOAN_PRODCT_TYPE,
         LM.LOAN_PRODUCT_CODE AS LOAN_PRODUCT_CODE,
         date_conversion_pkg.f_eng_to_nep_daily (LM.LOAN_MATURITY_DATE)
            LOAN_MATURITY_DATE,
              to_char(LM.LOAN_MATURITY_DATE,'YYYY-MM-DD') AS LOAN_MATURITY_DATE_AD, 
         LM.APPROVED_LOAN_AMOUNT,
         LM.APPROVED_LOAN_AMOUNT AS VALUATION_AMOUNT,
         LM.TOTAL_LOAN_AMOUNT,
         LM.LOAN_PERIOD_TYPE,
         LM.LOAN_PERIOD,
         LM.TOTAL_PRINCIPAL_OUTSTANDING TOTAL_OUTSTANDING,
         nvl(LM.TOTAL_INTEREST,0) as TOTAL_INTEREST,
         Lm.INTEREST_RATE,
         nvl(LM.TOTAL_PENALTY,0) as TOTAL_PENALTY,
         LM.INTEREST_CALC_METHOD,
         nvl(LM.TOTAL_PRINCIPAL_PAID,0) AS TOTAL_PRINC_PAID,
         nvl(LM.Total_interest_paid,0) as TOTAL_INTEREST_PAID,
         nvl(LM.TOTAL_PENALTY_PAID,0) as TOTAL_PENALTY_PAID,
         LM.INSTALLMENT_PERIOD_TYPE,
         LM.INSTALLMENT_PERIOD,
         LM.INSTALLMENT_AMOUNT,
         nvl(LM.FIXED_INTEREST_AMOUNT,0) as FIXED_INTEREST_AMOUNT,
         LM.FIXED_PRINCIPAL_AMOUNT,
         LM.NO_OF_INSTALLMENT,
         nvl(tmp.last_payment_bs,date_conversion_pkg.f_eng_to_nep_daily (LM.LOAN_DATE)) AS Last_PAYMENT_DATE,
         (SELECT 'F'|| SAVING_PRODUCT_CODE || substr(SA.saving_account_no,-5)
            FROM FN_CLIENT_SAVING_ACCOUNT SA
           WHERE SA.ACCOUNT_NO = LM.LOAN_AGAINST_SAVING_NO)
            AS REF_ACCOUNT_NO,
            DC.DAYCOUNT,
            round(((LM.TOTAL_PRINCIPAL_OUTSTANDING * LM.Interest_rate/100)/365)*DC.DayCount,0) as DUE_INTEREST,
            CASE 
  WHEN dc.daycount>365 THEN round( (DC.DayCount * lp.Penalty_calc_value * LM.TOTAL_PRINCIPAL_OUTSTANDING/100/365) ,0)
  ELSE 0
END as DUE_PENALTY
    FROM fn_loan_master lm left join fn_loan_products lp on LM.LOAN_PRODUCT_CODE = lp.LOAN_PRODUCT_CODE
	left join FN_MEMBER_CLIENTS MC on MC.CLIENT_NO = LM.CLIENT_NO
	left join tmp_view_last_payment tmp on tmp.loan_no = lm.loan_no
  inner join (
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
    ) b
  ) DC on DC.loan_no = LM.loan_no
	WHERE     
        LM.LOAN_STATUS<>'C'
ORDER BY LM.LOAN_PRODUCT_CODE, LM.CLIENT_NO;

select LOAN_PRODCT_TYPE, loan_product_code, count(*) as cnt, 
  sum(TOTAL_OUTSTANDING) as total_loan_amt,
  sum(Total_interest - TOTAL_INTEREST_PAID) as Total_interest,
  sum(Due_Interest) as total_int,
  sum(Due_Penalty) as total_penalty
from mg_loan group by LOAN_PRODCT_TYPE, loan_product_code
;

select * from fn_loan_products where loan_product_code = 3;

