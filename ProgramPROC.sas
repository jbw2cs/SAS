data Personal.first_data;
input employee $7. salary;
datalines;
sameer 1232
rohan 1232
michael 2132
james 098098
;
run;

proc import datafile="C:\Users\tr875f\Documents\SAS\Categories.xlsx"
	out = Personal.categories
	dbms = xlsx replace;
	sheet="categories";
	run;

data test; 
SET Personal.Categories;
RENAME CategoryName=Category;
DROP Column_1;
run;

/*Example Statements*/
/*data ____;*/
/*set ____;*/
/*if transaction_amount < 500 then category = "Below Average";*/
/*else if transaction_amount >=500 and transaction_amount < 699 then category = "Premium";*/
/*else category = "Elite";*/
/*run;*/

data keeps(keep=model type msrp);
set sashelp.cars;
run;
/*or set sashelp.cars(keep=model type msrp)*/

data drops(drop=msrp);
set sashelp.cars;
run;

/* split into two tables */
data price(keep=model type msrp) features(drop=model type msrp);
set sashelp.cars;
if msrp<19000 then output price;
else output features;
run;

/*select specific lines*/
data line_number;
set price;
if _N_ >=10 AND _N_ < 20;
run;

/*select first obs lines*/
data obss;
set price(obs=15);
run;

/*select first obs lines but start from FIRSTOBS (will print 9 obs here)*/
data firstobss;
set price(OBS=15 FIRSTOBS=7);
run;

/*SORT OPTIONS: https://documentation.sas.com/doc/en/proc/3.2/p1nd17xr6wof4sn19zkmid81p926.htm*/
proc sort data=sashelp.cars nodup out=sortedcars;
by descending msrp;
run; 
/*nodup (removes duplicates if all fields are same) (only adjacent rows) use 'by _all_' to remove all rows that are dups)*/
/*nodupkey (remove duplicate if key (by ____) is same)*/
/*dupout (saves the duplicates)*/

/*PRINT OPTIONS: https://documentation.sas.com/doc/en/proc/3.2/p10fu4xl7luy9dn1ea3nsgjm4rls.htm*/
proc print data=sortedcars (obs=15);
VAR make model msrp invoice;
title "Cars from sashelp.cars";
/*by make;*/
sum msrp;
where origin='Europe';
footnote '15 Most Expensive European Cars';
run;

proc freq data = sashelp.cars;
/*tables origin/nopercent nocum;*/
tables origin * type/nopercent norow nocol;
title;
footnote;
/*where msrp > 30000;*/
run;

/* Transposing */

proc import datafile="C:\Users\tr875f\Documents\SAS\Locations.xlsx" 
	out = Personal.locations
	dbms = xlsx replace;
	sheet = Sheet1;
run;
proc sort data=Personal.locations out=locations;
by city country;
run;
proc transpose data = locations out = transposed_local(drop=_:);
	by city;
	id country;
	var transaction_amount;
	run;
proc print data=transposed_local;

proc import datafile="C:\Users\tr875f\Documents\SAS\Locations.xlsx" 
	out = Personal.namedLocal
	dbms = xlsx replace;
	sheet = Sheet2;
run;
proc sort data=Personal.namedLocal out=named_locations;
by contactname Country city;
run;
proc transpose data=named_locations out=transposed_named_local(drop=_:);
by ContactName;
id country city;
var transaction_amount;
run;
proc print data=transposed_named_local;
run;
proc contents data=sashelp.cars;
run;
/*Character Functions*/

data compressCompbl;
name="Thomas 	Cruise		 Mapothe";
len = length(name);
compress=compress(name);
len_1 = length(compress);
compbl = compbl(name);
len_2 = length(compbl);
new_value=compress(compbl, "othe");
run;
proc print data=compressCompbl;
run;

data compressArg;
value="asvl;AAAA238579#(*$&%#";
noAs=compress(value, 'a', 'i');
onlyNums=compress(value, '','ak');
onlyAlph=compress(value, '','kd');
noPunc=compress(value, '', 'p');
onlyPunc=compress(value, '', 'ad');
proc print data=compressArg;
run;

/*Concatenation*/
data concatenation;
first_name="Thomas";
middle_name="Cruise";
last_name="Mapother";
full_name_manual=first_name||" "||middle_name||" "||last_name;
full_name_cat=cat(first_name,middle_name,last_name);
full_name_catx=catx(' ',first_name,middle_name,last_name);
proc print data=concatenation;
run;

data card_info;
input card_number $ 1-50;
datalines;
4444333322211111
9878677245322223
8976453276767864
6754901234657829
9878973921709723
1292783948793287
;
run;
data last4;
set card_info;
last_digits=substr(card_number,12,4);
substr(card_number,5,8)="********";
run;
proc print data=last4;
run;

data sample;
input name $ 1-25;
cards;
thomas
mapother
cruise
john
ROMAN
MAGGY
;
run;

data changed_case;
set sample;
CAPITALS=upcase(name);
small=lowcase(name);
sentence=propcase(capitals);
run;
proc print data=changed_case;
run;

/* Replace part of string */
data tranwrd;
name="Thomas Cruise Mapother";
ex2="John is a good boy. That boy is naughty";
changed=tranwrd(name, "Mapother", "Cruise");
changed2=tranwrd(ex2, "boy", "girl");
run;
proc print data=tranwrd;
run;

data genders;
input name $ 1-25;
input gender $ 1;
cards;
Ms. Rajeev
M
Mr. Jully
F
Ms. Malhotra
F
Mr. Kartik
M
Ms. Sinha
F
Ms. Diva
F
;
run;
data genderCorrect;
set genders;
if upcase(gender)='M' then name2=tranwrd(name, "Ms.", "Mr.");
else if upcase(gender)='F' then name2=tranwrd(name, "Mr.", "Ms.");
else name2=name;
run;
proc print data=genderCorrect;
run;

data translateT;
name='sameer';
name2=TRANSLATE(name, 'ix', 'am');
put name2=;
run;
proc print data=translateT;
run;

/*data comIndex;*/
/*exists=index(remarks, '.com');*/
/*run;*/
/*data comFind;*/
/*exists=find(remarks, '.com', 'i'); /*i ignores cases */*/
/*run;*/
/**/
/*data prxmatch;*/
/*flag=prxmatch("/^s|^f/i", remarks);*/
/*run;*/
/*data mobileSearch;*/
/*mobile_number=substr(comments, prxmatch("/\d{10}/", comments), 10);*/
/*run;

proc import datafile="C:\Users\tr875f\Documents\SAS\Excel_Files-master\ACCOUNT_INFO.xlsx"
	out = Tutfiles.acc_info
	dbms = xlsx replace;
	sheet="Sheet1";
	run;

	proc import datafile="C:\Users\tr875f\Documents\SAS\Excel_Files-master"
	out = Tutfiles
	dbms = xlsx replace;
	sheet="Sheet1";
	run;
data inputOutput;
set Tutfiles.acc_info;
acc_number=put(account_number,best.);
acc_number2=input(acc_number,12.);
proc contents data=inputOutput;
run;
proc contents data=inputOutput;
run;

data dates;
format current_date mdy date9.;
current_date=today();
day=day(current_date);
dayofweek=weekday(current_date); /* 1=Sunday, 7=Saturday */
month=month(current_date);
year=year(current_date);
mdy=mdy(06, 30, 2025);
put current_date=;
put day=;
put dayofweek=;
put month=;
put year=;
put mdy=;
run;

data test;
input date ddmmyy10.;
format date ddmmyy10.;
cards;
01/01/1960
;
run;
proc print data=test;
run;

data datesintck;
format admission_date discharge_date application_date current_date start_date end_date date9.;
admission_date="10jan2020"d;
discharge_date="30jan2020"d;
Hospitalization_dys=intck('day', admission_date, discharge_date);
application_date = "31jan2020"d;
current_date=today();
months_on_book=intck('month', application_date, current_date);
start_date="31dec2019"d;
end_date="01jan2020"d;
diffDiscrete=intck('month', start_date, end_date);
diffContinuous=intck('month', start_date, end_date, 'C');
proc print data=datesintck;run;

data datesintnx;
format first_visit second_visit third_visit fourth_visit date9.;
first_visit = '10oct2020'd;
second_visit = intnx('day', first_visit, 20);
third_visit = intnx('day', second_visit, 20);
fourth_visit=intnx('day', third_visit, 20);
run;
proc print data=datesintnx;run;

data datesalignment;
format start_date end_date END_DATE_BEGINNING END_DATE_MIDDLE END_DATE_END END_DATE_SAMEDAY DATE9.;
start_date = '25oct2020'd;
end_date = intnx('month', start_date, 3);
END_DATE_BEGINNING=intnx('month', start_date, 3, 'b');
END_DATE_MIDDLE=intnx('month', start_date, 3, 'm');
END_DATE_END=intnx('month', start_date, 3, 'e');
END_DATE_SAMEDAY=intnx('month', start_date, 3, 's');
run;
proc print data=datesalignment;
run;

/*XLSX format*/
proc export data=datesalignment
	outfile = "C:\Users\tr875f\Documents\SAS\Dates"
	dbms = xlsx replace;
	sheet="DatesAlignment";
run;
/*CSV format*/
proc export data=datesalignment
	outfile = "C:\Users\tr875f\Documents\SAS\Dates"
	dbms=csv replace;
run;

proc export data=datesalignment
	outfile = "C:\Users\tr875f\Documents\SAS\Dates"
	dbms = xlsx replace;
	sheet="DatesINTNX";
run;

proc import datafile="C:\Users\tr875f\Documents\SAS\Combining Tables.xlsx"
	out = Work.Cust1
	dbms = xlsx replace;
	sheet="Cust1";
	run;

proc import datafile="C:\Users\tr875f\Documents\SAS\Combining Tables.xlsx"
	out = Work.Cust2
	dbms = xlsx replace;
	sheet="Cust2";
	run;

proc import datafile="C:\Users\tr875f\Documents\SAS\Combining Tables.xlsx"
	out = Work.Cust3
	dbms = xlsx replace;
	sheet="Cust3";
	run;

proc import datafile="C:\Users\tr875f\Documents\SAS\Combining Tables.xlsx"
	out = Work.Cust4
	dbms = xlsx replace;
	sheet="Cust4";
	run;

data combined;
set work.cust1;
set work.cust2;
proc print data=combined;
run;

data combined;
set work.cust1
	work.cust3;
proc print data=combined;
run;

proc sort data=work.cust1; by contactname; run;
proc sort data=work.cust3; by contactname; run;

data combined;
merge work.cust1(in=a)
	  work.cust3(in=b);
	  by contactname;
/*	  if a;*/
/*	  if b;*/
/*	  if a and b;*/
	  if a or b;
proc print data=combined;
run;

data mergeHost;
set work.cust1;
run;

proc append base=mergeHost data=work.cust4 FORCE; run;
proc print data=mergeHost;
run;

data combined_all;
set work.cust:;
proc print data=combined_all;
run;
