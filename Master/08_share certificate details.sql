drop table mg_share_tran;

create table mg_share_tran
as
  SELECT  rownum as SN,                        --SA.OLD_SHARE_HOLDER_NO AS SHARE_HOLDER_NO,
         'S'||substr(SA.SHARE_HOLDER_NO,-5) as SHARE_HOLDER_NO,
        -- SA.SHARE_HOLDER_NO,
         ST.SHARE_TYPE_CODE AS SHARE_TYPE,
         ST.SHARE_TYPE_DESC,
    date_conversion_pkg.f_eng_to_nep_daily (SA.TRANS_DATE)
            AS TRANS_DATE,
            to_char(SA.TRANS_DATE,'YYYY-MM-DD') AS TRANS_DATE_AD,
          XY.SHARE_PICS AS NO_OF_SHARE_QTY,
         XY.AMOUNT AS AMOUNT
    FROM FN_CLIENT_SHARE_ACCOUNT sa,
         FN_SHARE_TYPE ST,
         (  SELECT SHARE_HOLDER_NO,
                   SHARE_TYPE,
                   SUM (SHARE_PICS) AS SHARE_PICS,
                   SUM (AMOUNT) AS AMOUNT
              FROM (SELECT ST.SHARE_HOLDER_NO,
                           ST.SHARE_TYPE,
                           ST.SHARE_PICS,
                           ST.AMOUNT,
                           ST.IS_RETURN
                      FROM FN_CLIENT_SHARE_TRXN st
                     WHERE ST.IS_RETURN = 0 AND VOUCHER_NO IS NOT NULL
                     --and  ST.tran_office_code='00024002'
                    -- AND ST.TRANSACTION_DATE < '16-jul-2017'
                    --BETWEEN :p_start_date AND :p_end_date
                    UNION ALL
                    SELECT ST.SHARE_HOLDER_NO,
                           ST.SHARE_TYPE,
                           -ST.SHARE_PICS,
                           -ST.AMOUNT,
                           ST.IS_RETURN
                      FROM FN_CLIENT_SHARE_TRXN st
                     WHERE ST.IS_RETURN = 1 AND VOUCHER_NO IS NOT NULL -- AND ST.TRANSACTION_DATE < '16-jul-2017'
                                                                      --BETWEEN :p_start_date AND :p_end_date
                     -- AND ST.tran_office_code='00024001'                                                
                   ) STX
          GROUP BY SHARE_HOLDER_NO, SHARE_TYPE) XY
   WHERE     SA.SHARE_HOLDER_NO = XY.SHARE_HOLDER_NO
         AND XY.SHARE_TYPE = ST.SHARE_TYPE_CODe
          -- AND SA.TRANS_DATE <'16-jul-2017'
         AND SA.SHARE_HOLDER_NO = XY.SHARE_HOLDER_NO
        ORDER BY SHARE_TYPE, share_holder_no

