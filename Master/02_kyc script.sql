/* Formatted on 8/4/2016 1:34:27 PM (QP5 v5.227.12220.39754) */
drop table mg_kyc;

create table mg_kyc
as
SELECT                                     --C.OLD_MEMBER_CODE AS CLIENT_CODE,
      rownum as SN, SUBSTR (C.CLIENT_NO, -5) AS CLIENT_CODE,
       C.FNAME AS FIRST_NAME,
       C.LNAME AS LAST_NAME,
       DECODE (C.GENDER, 'M', 'Male', 'Female') AS GENDER,
       DATE_CONVERSION_PKG.F_ENG_TO_NEP_DAILY (C.MEMBERSHIP_DATE)
          AS MEMBERSHIP_DATE_BS,
      to_char(C.MEMBERSHIP_DATE,'YYYY-MM-DD') AS MEMBERSHIP_DATE_AD,
       DECODE (C.MEMBER_TYPE, 'I', 'Individual', 'Company') AS MEMBER_TYPE,
       DECODE (c.MARITAL_STATUS,
               'M', 'Married',
               'U', 'Un Married',
               'D', 'Divorced',
               'Widow')
          AS MARITAL_STATUS,
       c.SPOUSE_NAME,
       DECODE (C.ID_DOCUMENT_TYPE,
               'CITIZENSHIP', 'Citizenship Certificate',
               'PASSPORT', 'Passport Number',
               'VOTING', 'Voting ID Card',
               'MARRIAGE', 'Marriage Certificate',
               'BIRTH', 'Birth Certificate',
               'EWU', 'Elec./Water/Utility Card',
               'Others')
          AS IDENTITY_DOCUMENT_TYPE,
       C.ID_DOCUMENT_NO AS IDENTITY_DOC_NO,
       C.IDENTITY_OWN_BY AS CITIZENSHIP_OWNER,
       F_GET_DISTRICT_NAME (C.ID_ISSUE_DISTRICT_CODE)
          AS CITIZENSHIP_ISSUE_DISTRICT,
       DECODE (C.ACTIVE, 'Y', 'Active', 'Inactive') AS IS_ACTIVE,
       C.GRAND_FATHER_NAME,
       C.FATHER_NAME,
       F_GET_OCCUPATION_DESC (C.OCCUPATION_CODE) AS OCCUPATION,
       C.EMAIL_ADDRESS,
       DATE_CONVERSION_PKG.F_ENG_TO_NEP_DAILY (C.DOB) AS DOB,
        to_char(C.DOB,'YYYY-MM-DD') AS DOB_AD,
       C.ADDRESS AS PERMANENT_ADDRESS,
       'N/A' AS CONTACT_ADDRESS,
       c.ADDRESS_2_LINE1 AS Street_Address,
       0 AS Ward,
       'N/A' AS Municipality,
       F_GET_DISTRICT_NAME (C.ADDRESS_1_DISTRICT) AS District,
       substr(NVL (C.MOBILE_NO, C.TELEPHONE_NO),0, 10) AS MOBILE,
       EMPLOYEE_ID
  FROM fn_member_clients c;
