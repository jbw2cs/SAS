/*SAVE LOG (add extra 'run;' to end of file)*/
proc printto log="C:\Users\tr875f\Documents\SAS\savedLog.log";

proc sql;
	select Model,Type FROM sashelp.cars(obs=5);
quit;

proc sql;
 SELECT * FROM SASHELP.CARS(obs=5);
 quit;

proc sql;
	SELECT TYPE, INVOICE, WEIGHT FROM SASHELP.CARS(obs=5)
	WHERE TYPE = 'SUV' AND WEIGHT >=5000;
QUIT;

PROC SQL;
SELECT TYPE, count(TYPE) AS NUMBER_OF_UNIT, sum(INVOICE) AS TOTAL_INVOICE, sum(WEIGHT) as TOTAL_WEIGHT
FROM SASHELP.CARS
/*WHERE WEIGHT>5000*/
GROUP BY TYPE
HAVING NUMBER_OF_UNIT <= 50
ORDER BY TOTAL_INVOICE DESC;
QUIT;

PROC SQL;
SELECT *
		,CASE WHEN AGE<=12 THEN 'kid'
			 WHEN AGE BETWEEN 13 AND 19 THEN 'teenager'
			 ELSE 'young'
			END AS category
		,CASE WHEN AGE BETWEEN 0 AND 13 THEN 'short'
			 ELSE 'normal'
			END AS HEIGHT
		FROM SASHELP.CLASS;
QUIT;

PROC SQL;
SELECT TYPE
		,COUNT(*) AS COUNT_OF_OBS
		,FREQ(TYPE) AS FREQ_OF_OBS
		,N(TYPE) AS N_OF_OBS
		,NMISS(TYPE) AS N_OF_MISSING_OBS
		,MIN(INVOICE) AS MIN_INVOICE
		,MAX(INVOICE) AS MAX_INVOICE
		,AVG(INVOICE) AS AVG_INVOICE
/*		,MEAN(INVOICE) AS MEAN_INVOICE*/
		,RANGE(INVOICE) AS RANGE_INVOICE
		,STD(INVOICE) AS STD_INVOICE
		,SUM(INVOICE) AS SUM_INVOICE
	FROM SASHELP.CARS
	GROUP BY TYPE;
QUIT;

PROC IMPORT OUT= work.personalInfo
            DATAFILE= "C:\Users\tr875f\Documents\SAS\Students.xlsx" 
            DBMS=xlsx REPLACE;
     		sheet="Personal_info";
RUN;
PROC IMPORT OUT= work.physicalInfo
            DATAFILE= "C:\Users\tr875f\Documents\SAS\Students.xlsx" 
            DBMS=xlsx REPLACE;
     		sheet="Physical_Info";
RUN;
PROC IMPORT OUT= work.studentsDetails 
            DATAFILE= "C:\Users\tr875f\Documents\SAS\Students.xlsx" 
            DBMS=xlsx REPLACE;
     		sheet="Students_Details";
RUN;

/*LEFT JOIN*/
proc sql;
select a.*,
/*	  ,a.name*/
/*	  ,a.sex*/
/*	  ,a.age*/
	  b.height
	  ,b.weight
from work.personalInfo as a
left join work.physicalInfo as b
	on a.name=b.students_name;
quit;

/*RIGHT JOIN*/
proc sql;
select a.*
	  ,b.height
	  ,b.weight
from work.personalInfo as a
right join work.physicalInfo as b
	on a.name=b.students_name;
quit;

/*INNER JOIN*/
proc sql;
select a.*
	  ,b.height
	  ,b.weight
from work.personalInfo as a
inner join work.physicalInfo as b
	on a.name=b.students_name;
quit;

/*FULL JOIN*/
proc sql;
create table fullJoined as
select a.*
	  ,b.height
	  ,b.weight
from work.personalInfo as a
full join work.physicalInfo as b
	on a.name=b.students_name;
quit;

proc print data=fullJoined;
run;

/*proc sql;*/
/*select a.**/
/*	  ,b.height*/
/*from work.personalInfo as a*/
/*cross join work.physicalInfo as b;*/
/*quit;*/

data counter_table;
do counter = 0 to 100 by 10;
output;
end;
proc print data=counter_table;
run;

data newClass;
set sashelp.class;
format stay category $30.;

if age <=12 then do;
	fee="15k";
	stay="allowed";
	category="kid";
	end;
else do;
	fee="25k";
	stay="not allowed";
	category="teenager";
	end;
run;
proc print data=newClass;
run;

/*MACRO FUNCTION*/
%MACRO TYPE_SUMMARY_AUTOMATION(car_type);
proc sql;
create table &car_type._summary as
select	type
		,origin
		,count(*) as no_of_units
		,sum(msrp) as total_msrp
		,sum(invoice) as total_of_invoice
	from sashelp.cars
	where upcase(type)="&car_type."
	group by 1,2;
quit;
proc print data=work.&car_type._summary; run;
%MEND;

%TYPE_SUMMARY_AUTOMATION(SUV);
%TYPE_SUMMARY_AUTOMATION(SEDAN);
%TYPE_SUMMARY_AUTOMATION(SPORTS);

/*%LET MACRO CREATION*/
%let first_number=773;
%let second_number=276;
%put &first_number.;
data testing;
sum = &first_number. + &second_number.;
put sum=;
run;

proc sql;
create table carsSummary as
select	type
		,origin
		,count(*) as no_of_units
		,sum(msrp) as total_msrp
		,sum(invoice) as total_of_invoice
	from sashelp.cars
	group by 1,2;
quit;

/*INTO MACRO CREATION*/
proc sql;
select no_of_units into: units separated by ','
from work.Sports_summary;
quit;
%Put &units.;
data testing;
set carsSummary;
where no_of_units in (&units.);
proc print data=testing;
run;

/*CALL SYMPUT MACRO CREATION*/
data _NULL_;
call symput('units', 94);
run;
%put &units.;
data testing;
set carsSummary;
where no_of_units in (&units.);
proc print data=testing;
run;

/*%STR*/
%let what = %str(learnerea%'s video);
%put &what.=;

%let x = %str(proc means; run;);
%put &x.;

%let x = %str(  			a  );
%put &x.;

/*%EVAL*/
%let a = 10;
%let b = 3;
%let z = %EVAL(&a. * &b.);
%put &z.;

/*%SYSFUNC*/
%let name = learnerea;
%let first_name = %sysfunc(substr(&name., 1, 5));
%put &first_name.;

/*%MACRO DEBUGGING*/
options MLOGIC;
%MACRO auto_report(cars_type);

%IF &cars_type. = "HYBRID" %THEN %DO;
	proc sql;
		create table hybrid_category as 
		select	type
				,count(*) as number_of_units
				,avg(cylinders) as avg_no_of_cylinders
			from sashelp.cars
				where upcase(type) = &cars_type.
				group by 1;
	quit;
	proc print data=hybrid_category;run;
	%END;
%ELSE %DO;
	proc sql;
		create table normal_category as
		select type
				,count(*) as number_of_units
				,avg(horsepower) as avg_horsepower
			from sashelp.cars
				where upcase(type) = &cars_type.
				group by 1;
	quit;
	proc print data=normal_category; run;
%END;
%MEND;
%auto_report("HYBRID");
%auto_report("SUV");

options symbolgen;
%macro check_freq(type, var);
proc freq data=sashelp.cars;
tables &var.;
where upcase(type) = "&type.";
run;
%mend;
%check_freq(SUV, origin)

PROC IMPORT OUT= ordersCounter
            DATAFILE= "C:\Users\tr875f\Documents\My SAS Files\9.4\Excel_Files-master\Orders.xlsx" 
            DBMS=xlsx REPLACE;
			sheet="Orders";
run;

proc sort data=ordersCounter; 
	by EmployeeID;
run;

/*COUNTING ORDERS*/
data counter;
set ordersCounter;
by employeeID;
if first.employeeID then counter = 1; else counter+1;
run;
proc print data=counter;
run;

/*EVERY THIRD ORDER*/
data subsetnth;
set ordersCounter;
by employeeID;
if first.employeeID then counter = 1; else counter +1;
if counter = 3 then output;
proc print data=subsetnth;
run;

/*CUMULATIVE SUM*/
data cumSum;
set ordersCounter;
by employeeID;
if first.employeeID then cumSum = price;
else cumSum + price;
proc print data=cumSum;
run;

/*ONLY CUMSUM MOST*/
data cumSumMax;
set ordersCounter;
by employeeID;
if first.employeeID then cumSum = price;
else cumSum + price;
if last.employeeID then output;
proc print data=cumSumMax;
run;

/*COMPARING*/
proc compare base=carsSummary compare = sports_summary; run;

proc compare base=sashelp.prdsale maxprint=20;
	var actual;
	with predict;
	run;

/*MEANS*/
proc means data=sashelp.cars CLM CSS CV KURT maxdec=2;
var MSRP Invoice Weight;
class origin;
run;

/*OUTPUTTING TO DS*/
proc means data=sashelp.cars sum n nmiss mean stddev maxdec=2;
class origin;
output out=carsMeanSummary;
run;

proc means data=sashelp.cars maxdec=2 noprint;
class origin;
output out=carsMeanSummaryLimited median=median_report sum=sum_report;
run;

proc means data=sashelp.cars maxdec=2 noprint;
output out=meansMSRP median(msrp)= sum(msrp)= range(msrp)=/autoname;
run;

proc means data=sashelp.cars maxdec=2;
class origin;
output out=_type_test mean(msrp)= std(msrp)=/autoname;
run;

/*EXPORT*/
ods pdf file="C:\Users\tr875f\Documents\SAS\testExport.pdf";
proc compare base=normal_category compare=hybrid_category;
run;
ods pdf close;

/*MANIPULATION*/
data reversed;
set carssummary(keep=type);
reversed=reverse(type);
proc print data=reversed;
run;

data diffCost (drop=next_amount);
set carssummary(keep=type total_of_invoice);
next_amount = lag(total_of_invoice);
diff=total_of_invoice-next_amount;
proc print data=diffCost;
run;

data lastTwoLetters;
set diffCost;
lengths=length(type);
length2=lengths-1;
/*rights_car=substr(type, length2, lengths);*/
rights_car=substr(type, length(type)-1, 2); 
proc print data=lastTwoLetters;
run;

/*DELETE FULLY BLANK ROWS*/
data deleteBlanks;
set studentsdetails;
missing_flag=missing(cats(of _all_));
if missing_flag=1 then delete;
run;
proc print data=deleteBlanks; run;

/*ADD LEADING ZEROS*/
data leadZeros;
input id;
cards;
24351
345
1
6531112
345
;
run;

data leadingZeros;
set leadZeros;
id2=put(id,z7.);
run;
proc print data=leadingZeros; run;

/*GET COUNTD*/
proc sql;
select count(model) as model, count(cylinders) as cylinders
from sashelp.cars;
quit;
run;

/*REORDER VARIABLES*/
data reorderedVar;
retain origin _FREQ_ median_report sum_report _TYPE_;
set carsmeansummarylimited;
run;
proc print data=reorderedVar;
run;

run;
