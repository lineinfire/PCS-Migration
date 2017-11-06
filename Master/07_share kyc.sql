drop table mg_share_kyc;

create table mg_share_kyc as
SELECT rownum as SN, FN_MEMBER_CLIENTS_PKG.F_CLIENT_NAME_FROM_CLIENT_NO (sa.CLIENT_NO)
            AS client_name,
        -- MC.OLD_MEMBER_CODE AS CLIENT_NO,
          substr(MC.CLIENT_NO,-5) as CLIENT_CODE,
         'S'||substr(SA.SHARE_HOLDER_NO,-5) as SHARE_HOLDER_NO,
         date_conversion_pkg.f_eng_to_nep_daily (SA.TRANS_DATE) AS TRANS_DATE,
          to_char(SA.TRANS_DATE,'YYYY-MM-DD') AS TRANS_DATE_AD, 
         SA.REFERENCE_ACCOUNT_NO,
         SA.NOM_NAME,
         DECODE (SA.CERT_TYPE,
                 'CITIZENSHIP', 'Citizenship Certificate',
                 'VOTING', 'Voting ID Card',
                 'MARRIAGE', 'Marriage Certificate',
                 'BIRTH', 'Birth Certificate',
                 'EWU', 'Elec./Water/Utility Card',
                 'OTH', 'Others',
                 NULL)
            AS CERT_TYPE,
         SA.CERT_NO,
         SA.TRANSFER_DIV_TO_REF_AC,
         SA.REMARKS AS P_REMARKS,
         SA.TRANS_OFFICE_CODE AS TRANS_OFFICE_CODE
    FROM FN_CLIENT_SHARE_ACCOUNT SA, FN_MEMBER_CLIENTS Mc
   WHERE SA.CLIENT_NO = MC.CLIENT_NO
ORDER BY SA.SHARE_HOLDER_NO;
