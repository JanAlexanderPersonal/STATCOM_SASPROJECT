* Group 13
*************************
Jan ALEXANDER
Ondrej SKACEL
Thiebe Sleeuwaert
Emiel PLATJOUW
*************************
*****SAS-Project ********
************************;
* C004077A - Statistical computing : 2019 - 2020
***********************************************;

* Set libname (Proj);
libname Proj "H:/ac 2019-2020/SC/SAS/project"; /* libname Thiebe */

*    1. Import the 3 data sets.;
%macro loadcsv(csvname, dataname);
				PROC IMPORT DATAFILE=&csvname
					OUT = WORK.&dataname
					DBMS = CSV REPLACE;
				RUN;
%mend loadcsv;

FILENAME csv1 "H:/ac 2019-2020/SC/SAS/project/pollution_us_2000_2016.csv" TERMSTR=LF;
FILENAME csv2 "H:/ac 2019-2020/SC/SAS/project/avg_max_temp.csv" TERMSTR=LF;
FILENAME csv3 "H:/ac 2019-2020/SC/SAS/project/us-state-ansi-fips.csv" TERMSTR=LF;
%loadcsv(csv1, pollution);
%loadcsv(csv2, climate);
%loadcsv(csv3, USstates);

* print a few lines of each data set: ;
proc print data=work.pollution (obs=20)noobs; run;
proc print data=work.climate (obs=20) noobs; run;
proc print data=work.USstates noobs; run;

*    2. Using the climate data, calculate the mean temperature value in each state and month and output the results. ;
title 'Average temperature per month in each state';
proc means data=work.climate nway noprint;
	var JAN -- DEC;
	class state_postal_abbr;
	output out = work.meanTemp (drop=_type_ _freq_ ) mean= / autoname;
run;
proc print data=work.meanTemp (obs=5) noobs;
	format JAN_mean --  DEC_mean 6.2;
run;
title;

*    3. Starting from the output data from question 2, 
		use an array statement to obtain the average monthly temperature data from each state in a long format.;
title 'Average temperature per month in each state'; 
data work.meanTempLong(keep = state_postal_abbr month mean Temperature_mean);
	set work.meanTemp;
	array m{12} JAN_mean --  DEC_mean;
	do month = 1 to 12;
		mean = m{month};
		output;
	end;
run;
data work.meanTempLong (drop = mean);
	set work.meanTempLong;
	Temperature_Mean = mean;
run;
proc format;
	value mnthfmt 	1 = 'JAN' 2 = 'FEB' 3 = 'MAR'
					4 = 'APR' 5 = 'MAY' 6 = 'JUN'
					7 = 'JUL' 8 = 'AUG' 9 = 'SEP'
					10 = 'OCT' 11 = 'NOV' 12 = 'DEC'
					. = 'MISSING';
run;

proc print data=work.meanTempLong (obs=25)noobs;
	format 	Temperature_Mean 6.2
			month mnthfmt.; 
run;
title;


*    4. Merge the data table obtained in Question 3 with the FIPS code data set using stsups as by variable and outputting 
		only matching rows.;
proc sort data = work.USstates out = work.USstates;
	by stusps;
run;
proc print data = work.USstates;run;
proc sort data = work.meanTempLong out = work.meanTempLong;
	by state_postal_abbr month;
run;
proc print data = work.meanTempLong;run;
data work.statesTemp;
	merge work.meanTempLong(rename = (state_postal_abbr = stusps) in = inTemp) work.USstates(in = inState);
	by stusps;
	if inTemp = 1 and inState = 1;
	
run;
proc print data=work.statesTemp (obs=5)noobs; 
	format 	Temperature_Mean 6.2
			month mnthfmt.;
run;

*    5. Merge the data table obtained in Question 4 with the pollution data. Hint: you’ll have to create a month variable 
in the pollution data set first and then perform a merge by state and month. Output only matching rows. ;
data work.pollutionM;
	set work.pollution;
	month = month(Date_Local);
run;
proc sort data = work.pollutionM out = work.pollutionM;
	by State month;
run;
proc sort data = work.statesTemp out = work.statesTemp;
	by stname month;
run;
data work.pollutionTemp;
	merge work.pollutionM(in = inPoll) work.statesTemp(rename = (stname = State) in = inTemp);
	by State month;
	if inPoll = 1 and inTemp = 1;
run;
proc print data=work.pollutionTemp (obs=15);
	format 	Temperature_Mean 6.2
			month mnthfmt.;
run;
*    6. Use an appropiate procedure for comparing the number of levels of county_code and county. What do you observe? 
		Write down your findings. Remedy the problem by creating a unique county code by concatenating state_code and
		county_code separated by an underscore. Search for a SAS function that can do this. ;

*There's a different number of county codes and countys;
proc freq data = work.pollutionTemp nlevels;
	tables County County_Code / noprint;
run;


*However, state by state, the number is the same. The conclusion is that different states use the same county codes.;
proc freq data = work.pollutionTemp nlevels;
	tables County County_Code / noprint;
	by State;
run;
data work.pollutionTemp;
	set work.pollutionTemp;
	county_id = catx('_', State_Code, County_Code);
run;
proc print data=work.pollutionTemp (obs=15); run;


/* Thiebe: Did this for checking, although it's better, now we seemingly have too much county_id's*/
proc freq data = work.pollutionTemp nlevels;
	tables County county_id / noprint;
run;


*    7. Using the data set obtained from question 6, create a permanent data set keeping all observations from the state 
		PA and the variables
        ? County
        ? County_Code
        ? Stname
        ? Stusps
        ? St
        ? Date_Local
        ? Month variable from question 5
        ? O3_units
        ? O3_mean
        ? O3_AQI
        ? Temperature variable from question 3;

data Proj.pollutionTemp(keep = County County_code State stusps st Date_Local month O3_Units O3_mean O3_AQI Temperature_Mean);
	set work.pollutionTemp;
	where stusps = 'PA';
run;
proc print data=Proj.pollutionTemp (obs=15); 
	format month mnthfmt.;
run;

*    8. Calculate average values of O3_mean and O3_AQI for each county and month and include the table in your report. 
		Use the tabulate procedure. Make use of the Date_local variable in combination with an appropiate format. 
		Report 3 decimals. Discuss.;
	** Version with tabulate, proper format and use of Date_Local and the saved pollutionTemp data ;
	** Missing months still present but just not there in the original data maybe?;
title 'Monthly averages of O3 data for each county';
proc tabulate data=Proj.pollutionTemp format = 8.3 out = work.meansO3;
	class County Date_Local;
	var O3_Mean O3_AQI;
	table County, Date_Local*(O3_Mean*mean O3_AQI*mean);
	label Date_Local = 'Month';
	format Date_Local MONTH12.; /* ideally we should be able to get this as.character (JAN, FEB, ...) */
run;
title;

*    9. Plot the average concentration of O3 in different counties, using barplots, in descending order. Use appropiate 
		axis titles. In case you are trying the unicodes for subscripts, use labelattrs=(family='Times New Roman') 
		since the unicode will not work for the standard font. Include the graph in your report and discuss.;
proc sgplot data=work.meansO3;
	vbar County / stat=mean response=O3_Mean_Mean
	categoryorder=respdesc;
	yaxis label = 'Average Concentration O3';
run;

*    10. Calculate the yearly average of the ozone concentration for each county and output these values to a SAS data set. 
		Hint: Use an appropiate format statement to achieve this. Using this outputted data set, use the HEATMAPPARM statement 
		in PROC SGPLOT to create a continuous heat map with Date_local in the x-axis, county in the Y-axis and the average 
		ozone concentration as response. You might want to have a look at the SAS blog from Rick Wicklin 
		https://blogs.sas.com/content/iml/2019/07/15/create-discrete-heat-map-sgplot.html. 
		Include the heatmap in your report and discuss.;
title 'Yearly average O3 concentration for each county';

proc tabulate data=Proj.pollutionTemp format=8.3 out=work.yearmeans03;
	class County Date_Local;
	var O3_Mean;
	table County,Date_Local*O3_Mean*mean;
	label Date_Local = 'Year' 
		  O3_Mean = 'O3 Concentration';
	format Date_Local YEAR4.;
run;

/* *Was getting errors that O3_Means didn't exist but this showed that it was saved as O3_Mean_Mean;
proc contents data = work.yearmeans03;  
run;
*/

title "Continuous Heat Map";
title2 "Mean O3 concentration per county per year";
proc sgplot data=work.yearmeans03;
	heatmapparm x=Date_Local y=County colorresponse=O3_Mean_Mean / colormodel=(blue yellow red) outline discretex;
	label O3_Mean_Mean = "Average O3 concentration";
	gradlegend;
run;
title;

/*COMMENT: years in right order, 
ideally the county names should have longer length (possible with lenght county $ desiredlength )*/

*    11. Using again the data set created in question 7, draw a lineplot that displays O3_AQI over the years for the 
		3 counties with highest concentration as concluded from question 9. When plotting, take monthly mean values 
		as the representative values by using an appropiate format for Date_local. The Y-axis limits should be 0 and 220. 
		Draw a reference line at 50, 100, 150 and 200 labeled good, moderate, unhealthy for some groups and unhealthy. 
		The following SAS paper covers this topic: http://support.sas.com/resources/papers/proceedings09/158-2009.pdf  
		Include the graph in your report and discuss.;
title 'Yearly average O3 Air Quality Index for the top 3 countries with highest O3 concentration';
proc tabulate data=Proj.pollutionTemp format=8.3 out=work.monthyearmeans03;
	class County Date_Local;
	var O3_AQI;
	table County*Date_Local, O3_AQI*mean;
	label Date_Local = 'Month_Year' 
		  O3_Mean = 'O3 Concentration';
	format Date_Local MONYY5.;
run;

proc sgplot data=work.monthyearmeans03;
	where County in ('Adams', 'Erie', 'Lancaste');
	series x=Date_Local y=O3_AQI_Mean / group=County ;
	format Date_Local MONYY5.;
	refline 50 100 150 200 / 
		label = ('Good' 'Moderate' 'Unhealthy for some groups' 'Unhealthy');
	yaxis label = "Average O3 Air Quality Index" Min = 0 Max = 220;
	xaxis label = "Years";
run;
title;


/*COMMENT: would maybe be better if we split them over different graphs? (Think: facet_wrap(.~county) if it was in R)
it is in the course how to do this*/


*    12. Subset the data: select the observations from the year 2015 and verify whether there is an association between 
		temperature and O3_AQI. Report and discuss your findings.;
title "association between temperature and O3_AQI";
proc tabulate data=Proj.pollutionTemp format=8.3 out=Proj.pollutionTemp2015;
	class County Date_Local;
	var O3_AQI Temperature_Mean;
	table Date_Local, county*(O3_AQI*mean Temperature_Mean*mean);
	label Date_Local = 'Month' 
		  O3_Mean = 'O3 Concentration';
	format Date_Local MONTH.;
	where year(Date_Local) = 2015;
run;


proc sgplot data=Proj.pollutionTemp2015;
	reg x=O3_AQI_Mean y=Temperature_Mean_Mean /cli clm ;
	yaxis label = "Average O3 Air Quality Index" Min = 0 Max = 220;
	xaxis label = "Average temperature";
	refline 50 100 150 200 / 
		label = ('Good' 'Moderate' 'Unhealthy for some groups' 'Unhealthy');
run;

proc corr data=Proj.pollutionTemp2015 ;
   var O3_AQI_Mean;
   with Temperature_Mean_Mean;
run;

/* when we don't group by month we get this graph,
	more chaos, but same conclusion.
	grouping by month is logical, since we took 
	the average temperature per month in the beginning of the project */

proc sgplot data=Proj.pollutionTemp;
	where year(date_local) = 2015;
	reg x=O3_AQI y=Temperature_Mean /cli clm ;
	yaxis label = "Average O3 Air Quality Index" Min = 0 Max = 220;
	xaxis label = "Average temperature";
	refline 50 100 150 200 / 
		label = ('Good' 'Moderate' 'Unhealthy for some groups' 'Unhealthy');
run;

proc corr data=Proj.pollutionTemp ;
   var O3_AQI ;
   with Temperature_Mean;
   where year(date_local) = 2015;
run;
title;

*    13. Write a pdf report with the ODS system of max 5 pages containing the following:
    • Names of the group members with a mentioning of who did what.
    • A short introduction on the topic.
    • Answers to the questions with requested plots and tables inserted.
    • The name of the report should be as follows: SASproject_groupX.pdf. The code should be sent as a separate file 
     named SASproject_groupX.sas. This code is expected to be between 300 and 400 lines.;