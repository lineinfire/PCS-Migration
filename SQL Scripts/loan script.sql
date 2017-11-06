/* Formatted on 11/5/2017 4:11:53 PM (QP5 v5.227.12220.39754) */
DROP TABLE mg_loan;

SELECT * FROM fn_loan_master;

SELECT * FROM mg_loan;

--where daycount > 35;
--where loan_dno = 'L00040I0065000502';

--where LOAN_DNO='L00039I00029501';

CREATE TABLE mg_loan
AS
     SELECT ROWNUM AS SN,
            FN_MEMBER_CLIENTS_PKG.F_CLIENT_NAME_FROM_CLIENT_NO (LM.CLIENT_NO)
               AS client_name,
            -- MC.OLD_MEMBER_CODE AS CLIENT_CODE,
            SUBSTR (MC.CLIENT_NO, -5) AS CLIENT_CODE,
            --LM.OLD_LOAN_NO AS LOAN_ACCOUNT_NO,
            LM.LOAN_DNO,
            'L' || SUBSTR (LM.LOAN_NO, -5) AS LOAN_ACCOUNT_NO,
            date_conversion_pkg.f_eng_to_nep_daily (LM.LOAN_DATE) LOAN_DATE,
            TO_CHAR (LM.LOAN_DATE, 'YYYY-MM-DD') AS LOAN_DATE_AD,
            LP.LOAN_PRODUCT_NAME AS LOAN_PRODCT_TYPE,
            LM.LOAN_PRODUCT_CODE AS LOAN_PRODUCT_CODE,
            date_conversion_pkg.f_eng_to_nep_daily (LM.LOAN_MATURITY_DATE)
               LOAN_MATURITY_DATE,
            TO_CHAR (LM.LOAN_MATURITY_DATE, 'YYYY-MM-DD')
               AS LOAN_MATURITY_DATE_AD,
            LM.APPROVED_LOAN_AMOUNT,
            LM.APPROVED_LOAN_AMOUNT AS VALUATION_AMOUNT,
            LM.TOTAL_LOAN_AMOUNT,
            LM.LOAN_PERIOD_TYPE,
            LM.LOAN_PERIOD,
            LM.TOTAL_PRINCIPAL_OUTSTANDING TOTAL_OUTSTANDING,
            NVL (LM.TOTAL_INTEREST, 0) AS TOTAL_INTEREST,
            Lm.INTEREST_RATE,
            NVL (LM.TOTAL_PENALTY, 0) AS TOTAL_PENALTY,
            LM.INTEREST_CALC_METHOD,
            NVL (LM.TOTAL_PRINCIPAL_PAID, 0) AS TOTAL_PRINC_PAID,
            NVL (LM.Total_interest_paid, 0) AS TOTAL_INTEREST_PAID,
            NVL (LM.TOTAL_PENALTY_PAID, 0) AS TOTAL_PENALTY_PAID,
            LM.INSTALLMENT_PERIOD_TYPE,
            LM.INSTALLMENT_PERIOD,
            LM.INSTALLMENT_AMOUNT,
            NVL (LM.FIXED_INTEREST_AMOUNT, 0) AS FIXED_INTEREST_AMOUNT,
            LM.FIXED_PRINCIPAL_AMOUNT,
            LM.NO_OF_INSTALLMENT,
            NVL (tmp.last_payment_bs,
                 date_conversion_pkg.f_eng_to_nep_daily (LM.LOAN_DATE))
               AS Last_PAYMENT_DATE,
            (SELECT    'F'
                    || SAVING_PRODUCT_CODE
                    || SUBSTR (SA.saving_account_no, -5)
               FROM FN_CLIENT_SAVING_ACCOUNT SA
              WHERE SA.ACCOUNT_NO = LM.LOAN_AGAINST_SAVING_NO)
               AS REF_ACCOUNT_NO,
            DC.DAYCOUNT,
            ROUND (
                 (  (LM.TOTAL_PRINCIPAL_OUTSTANDING * LM.Interest_rate / 100)
                  / 365)
               * DC.DayCount,
               0)
               AS DUE_INTEREST,
            CASE
               WHEN dc.daycount > 365
               THEN
                  ROUND (
                     (  DC.DayCount
                      * lp.Penalty_calc_value
                      * LM.TOTAL_PRINCIPAL_OUTSTANDING
                      / 100
                      / 365),
                     0)
               ELSE
                  0
            END
               AS DUE_PENALTY
       FROM fn_loan_master lm
            LEFT JOIN fn_loan_products lp
               ON LM.LOAN_PRODUCT_CODE = lp.LOAN_PRODUCT_CODE
            LEFT JOIN FN_MEMBER_CLIENTS MC ON MC.CLIENT_NO = LM.CLIENT_NO
            LEFT JOIN tmp_view_last_payment tmp ON tmp.loan_no = lm.loan_no
            INNER JOIN
            (SELECT Y.loan_no, b.Today_Date - Y.LastPayDate AS DayCount
               FROM (SELECT lm.*,
                            NVL (lp.last_payment_date, lm.loan_date)
                               AS LastPayDate
                       FROM fn_loan_master lm
                            LEFT JOIN tmp_view_last_payment lp
                               ON lm.loan_no = lp.loan_no) Y,
                    (SELECT *
                       FROM sod_eod
                      WHERE LENGTH (tran_office_code) = 5) b) DC
               ON DC.loan_no = LM.loan_no
      WHERE LM.LOAN_STATUS <> 'C'
        AND LM.TOTAL_PRINCIPAL_OUTSTANDING >= 0
   ORDER BY LM.LOAN_PRODUCT_CODE, LM.CLIENT_NO;

  SELECT LOAN_PRODCT_TYPE,
         loan_product_code,
         COUNT (*) AS cnt,
         SUM (TOTAL_OUTSTANDING) AS total_loan_amt,
         SUM (Total_interest - TOTAL_INTEREST_PAID) AS Total_interest,
         SUM (Due_Interest) AS total_int,
         SUM (Due_Penalty) AS total_penalty
    FROM mg_loan
GROUP BY LOAN_PRODCT_TYPE, loan_product_code;

SELECT *
  FROM fn_loan_products
 WHERE loan_product_code = 3;