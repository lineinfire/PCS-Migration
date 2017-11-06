drop table mg_saving_last_int_date;

create table mg_saving_last_int_date
as
select account_no, last_int_date_ad, nepali_date as last_int_date_bs from
(
    select account_no, max(transaction_date) as last_int_date_ad
    from FN_SAVING_INTEREST
    group by account_no
    ) y
    left join MS_DAILY_DATE z
    on y.last_int_date_ad = z.ENGLISH_DATE;
    
    -----------------------------------------------------------------------------------
    drop table mg_saving_last_int_booked_date;
    
    
    create table mg_saving_last_int_booked_date
    as
    select account_no, last_int_booked_date_ad, nepali_date as last_int_booked_date_bs from
    (
        select account_no, max(transaction_date) as last_int_booked_date_ad
        from FN_SAVING_INTEREST_ACCURATE
        group by account_no
    ) y
    left join ms_daily_date z
    on Z.ENGLISH_DATE = y.last_int_booked_date_ad;