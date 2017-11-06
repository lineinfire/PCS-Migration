SELECT
        rownum AS SN                                 ,
        xyz.CLIENT_NAME                              ,
        xyz.CLIENT_CODE                              ,
        saving_ACCOUNT_NO                            ,
        xyz.OLD_ACCOUNT_NO                           ,
        xyz.ACCOUNT_OPEN_DATE                        ,
        xyz.ACCOUNT_OPEN_DATE_AD                     ,
        xyz.SAVING_PRODUCT_CODE                      ,
        xyz.SAVING_PRODUCT_TYPE                      ,
        xyz.ACCOUNT_STATUS                           ,
        xyz.MIN_BALANCE                              ,
        NVL(xyz.CURRENT_BALANCE,0) AS CURRENT_BALANCE,
        xyz.INTEREST_RATE                            ,
        NVL(xyz.INTEREST_BOOKED,0)                                AS INTEREST_BOOKED,
        NVL(xyz.Unbooked_int_dump,0) - NVL(xyz.INTEREST_BOOKED,0) AS UNBOOKED_INT   ,
        xyz.INT_CAPITALIZATION_METHOD                                               ,
        xyz.INT_CAPITALIZATION_METHOD_DESC                                          ,
        xyz.LAST_INT_CAPITALIZATION_DATE                                            ,
        xyz.MATURITY_DATE                                                           ,
        xyz.REFERENCE_ACCOUNT_NO                                                    ,
        xyz.DEPOSIT_PERIOD
FROM
        (
                SELECT
                        trim(MC.FNAME)
                                || ' '
                                || trim(MC.LNAME) AS CLIENT_NAME,
                        --MC.OLD_MEMBER_CODE AS CLIENT_CODE
                        SUBSTR(MC.CLIENT_NO,-5) AS CLIENT_CODE,
                        --SA.OLD_ACCOUNT_NO,
                        SA.saving_ACCOUNT_NO,
                        'N'
                                || sa.SAVING_PRODUCT_CODE
                                ||SUBSTR(SA.saving_ACCOUNT_NO,-5)                     AS OLD_ACCOUNT_NO             ,
                        DATE_CONVERSION_PKG.F_ENG_TO_NEP_DAILY (Sa.ACCOUNT_OPEN_DATE) AS ACCOUNT_OPEN_DATE          ,
                        TO_CHAR(Sa.ACCOUNT_OPEN_DATE,'YYYY-MM-DD')                    AS ACCOUNT_OPEN_DATE_AD       ,
                        SA.SAVING_PRODUCT_CODE                                                                      ,
                        FN_SAVING_UTILITY_PKG.F_SAVING_PRODUCT_NAME ( SA.SAVING_PRODUCT_CODE) AS SAVING_PRODUCT_TYPE,
                        SA.ACCOUNT_STATUS                                                                           ,
                        (
                                SELECT
                                        MIN_BALANCE
                                FROM
                                        FN_SAVING_PRODUCTS
                                WHERE
                                        product_Code = SA.SAVING_PRODUCT_CODE) AS MIN_BALANCE,
                        --sa.current_balance + sa.received_interest_amount
                        (
                                SELECT
                                        SUM(deposit_amount)
                                FROM
                                        fn_saving_deposit
                                WHERE
                                        account_no = SA.ACCOUNT_NO ) -
                        (
                                SELECT
                                        SUM(withdraw_amount)
                                FROM
                                        fn_saving_withdrawal
                                WHERE
                                        account_no = SA.ACCOUNT_NO ) AS CURRENT_BALANCE,
                        SA.INTEREST_RATE                                               ,
                        (
                                SELECT
                                        SUM (INTEREST_AMOUNT)
                                FROM
                                        FN_SAVING_INTEREST_ACCURATE sia
                                WHERE
                                        sia.ACCOUNT_NO = sa.ACCOUNT_NO) - sa.received_interest_amount AS INTEREST_BOOKED,
                        (
                                SELECT
                                        SUM (INTEREST_AMOUNT)
                                FROM
                                        FN_SAVING_INTEREST sI
                                WHERE
                                        SI.ACCOUNT_NO = sa.ACCOUNT_NO) - sa.received_interest_amount AS Unbooked_int_dump                                ,
                        SA.INT_CAPITALIZATION_METHOD                                                                                                     ,
                        DECODE (SA.INT_CAPITALIZATION_METHOD, '1', 'Monthly', '3', 'Quaterly', '6', 'Semi', 'Annually') AS INT_CAPITALIZATION_METHOD_DESC,
                        last_int_date_bs                                                                                AS LAST_INT_CAPITALIZATION_DATE  ,
                        DATE_CONVERSION_PKG.F_ENG_TO_NEP_DAILY (sa.MATURITY_DATE)                                       AS MATURITY_DATE                 ,
                        (
                                SELECT
                                        'N'
                                                || sa.SAVING_PRODUCT_CODE
                                                ||SUBSTR(saving_ACCOUNT_NO,-5)
                                FROM
                                        FN_CLIENT_SAVING_ACCOUNT
                                WHERE
                                        ACCOUNT_NO = SA.REFERENCE_ACCOUNT_NO)    AS REFERENCE_ACCOUNT_NO,
                        DECODE (SA.DEPOSIT_PERIOD, '0', NULL, SA.DEPOSIT_PERIOD) AS DEPOSIT_PERIOD
                FROM
                        FN_CLIENT_SAVING_ACCOUNT sa
                LEFT JOIN
                        FN_MEMBER_CLIENTS MC
                ON
                        SA.CLIENT_NO = MC.CLIENT_NO
                LEFT JOIN
                        mg_saving_last_int_date ms
                ON
                        ms.ACCOUNT_NO = sa.ACCOUNT_NO
                WHERE
                        SA.ACCOUNT_STATUS='A'
                ORDER BY
                        SA.SAVING_ACCOUNT_NO) xyz,
        FN_SAVING_PRODUCTS                    sp
WHERE
        sp.PRODUCT_CODE        = xyz.saving_product_code
AND     PRODUCT_TYPE_CODE      = '05'
AND     xyz.saving_product_code='020';