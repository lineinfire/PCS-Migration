declare 
penalty number(17,2);
begin
    penalty := loan_transaction_pkg.f_get_penalty_amount(:p_office_code, :loan_no, :p_date);
    dbms_output.put_line(penalty);
end;
/

select * from fn_loan_master where loan_dno='L00112I0074800101';




declare 
    v_out_past_prin_amount              NUMBER(17,2);
    v_out_curr_prin_amount              NUMBER(17,2);
    v_out_past_int_amount               NUMBER(17,2);
    v_out_curr_int_amount               NUMBER(17,2);
    v_out_penalty                       NUMBER(17,2);
    v_out_total_installment_amount      NUMBER(17,2);
begin
    loan_transaction_pkg.p_generate_installment_info(:p_office_code, :loan_no, 
        :p_date, 
        v_out_past_prin_amount, 
        v_out_curr_prin_amount,
        v_out_past_int_amount,
        v_out_curr_int_amount,
        v_out_penalty,
        v_out_total_installment_amount
    );     
    dbms_output.put_line('Past Int. Due    ' || v_out_past_int_amount);
    dbms_output.put_line('Int. Due    ' || v_out_curr_int_amount);
    dbms_output.put_line('Penalty Due    ' || v_out_penalty);
end;
/


select loan_transaction_pkg.p_generate_installment_info(:p_office_code, :loan_no, 
        :p_date, 
        v_out_past_prin_amount, 
        v_out_curr_prin_amount,
        v_out_past_int_amount,
        v_out_curr_int_amount,
        v_out_penalty,
        v_out_total_installment_amount
    ) from dual;