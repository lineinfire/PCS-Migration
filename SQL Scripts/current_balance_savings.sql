/* Formatted on 11/5/2017 12:03:26 PM (QP5 v5.227.12220.39754) */
SELECT SUM (SAVING_BALANCE) CURRENT_BALANCE
  FROM (  SELECT A.TRAN_OFFICE_CODE,
                 A.SAVING_PRODUCT_CODE,
                 A.SAVING_PRODUCT_NAME,
                 A.CLIENT_NO,
                 A.CLIENT_CODE,
                 A.ACCOUNT_NO,
                 A.SAVING_ACCOUNT_NO,
                 INITCAP (A.CLIENT_NAME) AS CLIENT_NAME,
                 A.SAVING_DEPO_AMOUNT,
                 B.SAVING_WITHDRAWAL_AMOUNT,
                   NVL (A.SAVING_DEPO_AMOUNT, 0)
                 + NVL (B.SAVING_WITHDRAWAL_AMOUNT, 0)
                    AS SAVING_BALANCE
            FROM (  SELECT MC.TRAN_OFFICE_CODE,
                           CSA.SAVING_PRODUCT_CODE,
                           SP.PRODUCT_NAME AS SAVING_PRODUCT_NAME,
                           CSA.CLIENT_NO,
                           MC.CLIENT_CODE,
                           CSA.ACCOUNT_NO,
                           CSA.SAVING_ACCOUNT_NO,
                           MC.FNAME || ' ' || MC.LNAME AS CLIENT_NAME,
                           SUM (NVL (SD.DEPOSIT_AMOUNT, 0)) AS SAVING_DEPO_AMOUNT
                      FROM FN_MEMBER_CLIENTS MC,
                           FN_CLIENT_SAVING_ACCOUNT CSA,
                           FN_SAVING_DEPOSIT SD,
                           FN_SAVING_PRODUCTS SP,
                           FN_SAVING_PRODUCT_TYPE PT,
                           MS_INSTITUTE G,
                           MS_INSTITUTE_MAP H
                     WHERE     CSA.ACCOUNT_NO = SD.ACCOUNT_NO
                           AND MC.CLIENT_NO = CSA.CLIENT_NO
                           AND SP.PRODUCT_CODE = :P_SAVING_PRODUCT_CODE -- csa.saving_product_code
                           AND SP.PRODUCT_TYPE_CODE = PT.PRODUCT_TYPE_CODE
                           AND CSA.ACCOUNT_STATUS <> 'C'
                           --AND pt.product_category_code = 'PU'
                           AND SD.VOUCHER_NO IS NOT NULL
                           AND NVL (SD.DEPOSIT_DATE, SD.DEPOSIT_DATE) <=
                                  NVL (:P_DATE, SYSDATE)
                           AND CSA.SAVING_PRODUCT_CODE LIKE
                                  NVL (:P_SAVING_PRODUCT_CODE, '%')
                           AND CSA.TRAN_OFFICE_CODE = G.INSTITUTE_CODE
                           AND G.INSTITUTE_CODE = H.INSTITUTE_CODE
                           AND SD.VOUCHER_NO IS NOT NULL
                           AND H.INSTITUTE_GRP_CODE = :P_OFFICE_CODE
                  GROUP BY MC.TRAN_OFFICE_CODE,
                           CSA.SAVING_PRODUCT_CODE,
                           SP.PRODUCT_NAME,
                           CSA.CLIENT_NO,
                           MC.CLIENT_CODE,
                           CSA.ACCOUNT_NO,
                           CSA.SAVING_ACCOUNT_NO,
                           MC.FNAME,
                           MC.LNAME) A,
                 (  SELECT MC.TRAN_OFFICE_CODE,
                           CSA.SAVING_PRODUCT_CODE,
                           SP.PRODUCT_NAME AS SAVING_PRODUCT_NAME,
                           CSA.CLIENT_NO,
                           MC.CLIENT_CODE,
                           CSA.ACCOUNT_NO,
                           CSA.SAVING_ACCOUNT_NO,
                           MC.FNAME || ' ' || MC.LNAME AS CLIENT_NAME,
                             -1
                           * SUM (
                                (  SD.WITHDRAW_AMOUNT
                                 + NVL (CLOSING_CHARGE, 0)
                                 + NVL (OTHER_INCOME_EXP_AMOUNT, 0)))
                              AS SAVING_WITHDRAWAL_AMOUNT
                      FROM FN_MEMBER_CLIENTS MC,
                           FN_CLIENT_SAVING_ACCOUNT CSA,
                           FN_SAVING_WITHDRAWAL SD,
                           FN_SAVING_PRODUCTS SP,
                           FN_SAVING_PRODUCT_TYPE PT,
                           MS_INSTITUTE G,
                           MS_INSTITUTE_MAP H
                     WHERE     CSA.ACCOUNT_NO = SD.ACCOUNT_NO
                           AND MC.CLIENT_NO = CSA.CLIENT_NO
                           AND SP.PRODUCT_CODE = CSA.SAVING_PRODUCT_CODE
                           AND SP.PRODUCT_TYPE_CODE = PT.PRODUCT_TYPE_CODE
                           --AND pt.product_category_code = 'PU'
                           AND NVL (SD.WITHDRAW_DATE, SD.WITHDRAW_DATE) <=
                                  NVL (:P_DATE, SYSDATE)
                           AND CSA.SAVING_PRODUCT_CODE LIKE
                                  NVL (:P_SAVING_PRODUCT_CODE, '%')
                           AND CSA.ACCOUNT_STATUS <> 'C'
                           AND CSA.TRAN_OFFICE_CODE = G.INSTITUTE_CODE
                           AND G.INSTITUTE_CODE = H.INSTITUTE_CODE
                           AND SD.VOUCHER_NO IS NOT NULL
                           AND H.INSTITUTE_GRP_CODE = :P_OFFICE_CODE
                  GROUP BY MC.TRAN_OFFICE_CODE,
                           CSA.SAVING_PRODUCT_CODE,
                           SP.PRODUCT_NAME,
                           CSA.CLIENT_NO,
                           MC.CLIENT_CODE,
                           CSA.ACCOUNT_NO,
                           CSA.SAVING_ACCOUNT_NO,
                           MC.FNAME,
                           MC.LNAME) B
           WHERE     A.TRAN_OFFICE_CODE = B.TRAN_OFFICE_CODE(+)
                 AND A.SAVING_PRODUCT_CODE = B.SAVING_PRODUCT_CODE(+)
                 AND A.ACCOUNT_NO = B.ACCOUNT_NO(+)
        ORDER BY A.SAVING_ACCOUNT_NO, A.SAVING_PRODUCT_CODE) XYZ;