declare 
vpprincipalamount   NUMBER(17,2);
vcprincipalamount   NUMBER(17,2);
vpinterestamount    NUMBER(17,2);
vcinterestamount    NUMBER(17,2);
vpenalty            NUMBER(17,2);
vtotinst            NUMBER(17,2);
begin
    loan_transaction_pkg.p_gen_installment_info_tillnow (:p_office_code, :loan_no, :p_date, vpprincipalamount, vcprincipalamount,
                                                        vpinterestamount, vcinterestamount, vpenalty, vtotinst);
    dbms_output.put_line(vpinterestamount);
end;
/

select * from fn_loan_master where loan_dno='L00128I0016300101';