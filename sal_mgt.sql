 create database salary_management;
 use salary_management;
 create table employee(EID int primary key auto_increment, EName varchar(20), Gender varchar(1), Email varchar(255), JoinDate date);
 
 create table Salary(SID int primary key auto_increment, Basic float, Allowance float);
 
 create table employee_salary(EID int, SID int, foreign key (EID) references employee(EID), foreign key (SID) references Salary(SID));
 
 create table Leave_(LID int primary key auto_increment, EID int, L_month int, L_days int, foreign key (EID) references employee(EID), reason varchar(255));
 
 create table transaction_(TID int primary key auto_increment, EID int, Amount float, T_Date date, S_month varchar(3), foreign key (EID) references employee(EID));
 
 create table Funds(FID int primary key auto_increment, Fund_Amount float);
 
 create table Fund_Audit(NewFund float, OldFund float, T_Date date);
 
 Create table EmpSalary_Audit(EID int primary key auto_increment, NewSID int, OldSID int, ChangingDate date);
 
 delimiter //
 
 create procedure view_details(in eids int)
 begin
      select employee.EID, employee.ename, employee.gender, employee.email, employee.joindate,
      salary.basic, salary.allowance, 
      transaction_.t_date, transaction_.s_month, transaction_.amount, transaction_.TID
      from salary 
      join employee_salary on salary.SID=employee_salary.SID 
      join transaction_ on employee_salary.EID=transaction_.EID 
      join employee on employee.EID=transaction_.EID 
      where EID=eids;
end // delimiter ;

call view_details();

delimiter //

select basic, allowance, generate_salary(basic) from salary;

delimiter //
create procedure transact_salary(in EIDs int, in sal_month varchar(7))
begin
     update transaction_ set amount=generate_salary(salary.basic), sal_month=salary.s_month, t_date=now(), EID=EIDs
     where EID=EIDs ;
end // delimiter ;

call transact_salary(eid,s_month);

delimiter //
create procedure add_fund(in fid int,in amount float)
begin
     update fund set fund_amount=fund_amount+amount 
     where FID=fid;
end // delimiter ;

call add_fund();

delimiter //
create procedure add_leave(in EID int, in L_month int, in L_days int, in reason varchar(255))
begin
     update leave_ set EID=EID, L_month= s_month, L_days=L_days, reason= reason
     where eid=eid;
end // delimiter ;

call add_leave();

delimiter //
create procedure TransactSalary(in fid int, in EID int, in amounnt float, in month varchar(3))
begin
     declare valid int;
     set valid = checkvalid(EID, month);
     if valid=1 then
     call add_fund(fid, amount);
     else
         select "invalid payment";
     end if ;
end  //  delimiter ;

call transactsalary();

delimiter //
create procedure updatefund(in fid int, in amount float)
begin
      update fund set amount = amount-amount where fid= fid;
end;
//
delimiter ; 

delimiter //
create function generate_salary(EID int, month varchar(3))
returns float
deterministic
reads sql data
begin
     declare result float;
     set result= basic+basic;
     return result ;
end // delimiter ;

delimiter // 
create function checkvalid( eid int, month varchar(3)) 
returns int
deterministic
reads sql data
begin
     declare result int ;
     select count(*)
     into result
     from transaction_ where eid=eid and s_month=month;
     if result>0 then
          return 2;
     else
         return 1;
	 end if ;
end // delimiter ;

delimiter //
create procedure addemployee(in Name varchar(50),in gender varchar(1),in email varchar(255),in joiningdate date, in SID int)
begin
     insert into employee(ename, gender, email, joindate)
     values(name, gender, email, joiningdate);
end // delimiter ;

call addemployee();

delimiter //
create procedure ChangeEmpPost(in EID int, in SID int)
begin
     update employee_salary set sid=sid where eid=eid;
end // delimiter ;

create table leave_audit(action_ varchar(255), perform_at timestamp);

drop trigger addleaves;
delimiter //
create trigger addleaves
after insert on leave_
for each row
begin
     insert into audit()
     values('leaves added according to month', now());
end; // delimiter ;

rename table leave_audit to audit;

delimiter //
create trigger assign_salary
after insert on employee_salary
for each row
begin
     insert into audit()
     values('salary assigned to the employee', now());
end; // delimiter ;

delimiter //
create trigger transact_salary
after insert on transaction_
for each row
begin
     insert into audit()
     values('one transaction completed', now());
end; // delimiter ;

delimiter //
create trigger addemp
after insert on employee
for each row
begin
     insert into audit()
     values('one employee added', now());
end; // delimiter ;

delimiter //
create trigger empsalary_audit
before update on employee_salary
for each row
begin
     declare v_date varchar(30);
     set v_date= now();
     insert into empsalary_audit(newsid, oldsid, changingdate)
     values(new.sid, old.sid, v_date);
     insert into audit()
     values('salary changed for new employee', now());
end; // delimiter ;

delimiter //
create trigger fund_audit
before update on funds
for each row
begin
     insert into fund_audit()
     values(new.fund_amount, old.fund_amount, now());
     insert into audit()
     values('new fund added', now());
end; // delimiter ;