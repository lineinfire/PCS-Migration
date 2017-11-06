declare 
vpprincipalamount   NUMBER(17,2);
vcprincipalamount   NUMBER(17,2);
vpinterestamount    NUMBER(17,2);
vcinterestamount    NUMBER(17,2);
vpenalty            NUMBER(17,2);
vtotinst            NUMBER(17,2);
v_out_penalty_balance   NUMBER(17,2);
begin
    loan_transaction_pkg.p_generate_installment_info (:p_office_code, :loan_no, :p_date, vpprincipalamount, vcprincipalamount,
                                                        vpinterestamount, vcinterestamount, vpenalty, vtotinst);
    v_out_penalty_balance := NVL (vpenalty, 0);
    dbms_output.put_line(v_out_penalty_balance);
end;
/

select * from fn_loan_master where loan_dno='L00040I0002000501';
-- 000400000001