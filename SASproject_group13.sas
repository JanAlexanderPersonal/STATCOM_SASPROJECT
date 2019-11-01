* Group 13
*************************
Jan ALEXANDER
Ondrej SKACEL
Thiebe Sleeuwaert
*************************
*****SAS-Project ********
************************;
* C004077A - Statistical computing : 2019 - 2020
***********************************************;

* Set libname (Proj);
libname Proj 'H:/SAS/HW/';


*    1. Import the 3 data sets.;
%macro loadcsv(csvname, dataname);
      	PROC IMPORT DATAFILE=&csvname
		    OUT=WORK.&dataname
		    DBMS=CSV
		    REPLACE;
		RUN;
%mend loadcsv;

FILENAME CSV1 "H:/SAS/HW/pollution_us_2000_2016.csv" TERMSTR=LF;
FILENAME CSV2 "H:/SAS/HW/avg_max_temp.csv" TERMSTR=LF;
FILENAME CSV3 "H:/SAS/HW/us-state-ansi-fips.csv" TERMSTR=LF;
%loadcsv(csv1, pollution);
%loadcsv(csv2, climate);
%loadcsv(csv3, USstates);

* print a few lines of each data set: ;
proc print data=work.pollution (obs=5); run;
proc print data=work.climate (obs=5); run;
proc print data=work.USstates (obs=5); run;

*    2. Using the climate data, calculate the mean temperature value in each state and month and output the results. ;
proc means data=work.climate nway noprint;
	output out = work.meanTemp 
	(drop=_type_ _freq_ YRS_mean)
	mean= / autoname;
	class state_postal_abbr;
run;

proc print data=work.meanTemp (obs=5); run;

*    3. Starting from the output data from question 2, use an array statement to obtain the average monthly temperature 
		data from each state in a long format.;
		
data work.meanTempLong(keep = state_postal_abbr month mean);
	set work.meanTemp;
	array m{12} JAN_mean --  DEC_mean;
	do month = 1 to 12;
		mean = m{month};
		output;
	end;
run;

proc print data=work.meanTempLong (obs=5); run;

*    4. Merge the data table obtained in Question 3 with the FIPS code data set using stsups as by variable and outputting 
		only matching rows.;

proc sort data = work.USstates out = work.USstates;
	by stusps;
run;

proc sort data = work.meanTempLong out = work.meanTempLong;
	by state_postal_abbr month;
run;

data work.statesTemp;
	merge work.meanTempLong(rename = (state_postal_abbr = stusps) in = inTemp) work.USstates(in = inState);
	by stusps;
	if inTemp = 1 and inState = 1;
run;

proc print data=work.statesTemp (obs=5); run;
		
*    5. Merge the data table obtained in Question 4 with the pollution data. Hint: you’ll have to create a month variable 
		in the pollution data set first and then perform a merge by state and month. Output only matching rows. ;
		
*    6. Use an appropiate procedure for comparing the number of levels of county_code and county. What do you observe? 
		Write down your findings. Remedy the problem by creating a unique county code by concatenating state_code and
		county_code separated by an underscore. Search for a SAS function that can do this. ;
*    7. Using the data set obtained from question 6, create a permanent data set keeping all observations from the state 
		PA and the variables
        ◦ County
        ◦ County_Code
        ◦ Stname
        ◦ Stusps
        ◦ St
        ◦ Date_Local
        ◦ Month variable from question 5
        ◦ O3_units
        ◦ O3_mean
        ◦ O3_AQI
        ◦ Temperature variable from question 3;
        
*    8. Calculate average values of O3_mean and O3_AQI for each county and month and include the table in your report. 
		Use the tabulate procedure. Make use of the Date_local variable in combination with an appropiate format. 
		Report 3 decimals. Discuss.;
*    9. Plot the average concentration of O3 in different counties, using barplots, in descending order. Use appropiate 
		axis titles. In case you are trying the unicodes for subscripts, use labelattrs=(family='Times New Roman') 
		since the unicode will not work for the standard font. Include the graph in your report and discuss.;
		
*    10. Calculate the yearly average of the ozone concentration for each county and output these values to a SAS data set. 
		Hint: Use an appropiate format statement to achieve this. Using this outputted data set, use the HEATMAPPARM statement 
		in PROC SGPLOT to create a continuous heat map with Date_local in the x-axis, county in the Y-axis and the average 
		ozone concentration as response. You might want to have a look at the SAS blog from Rick Wicklin 
		https://blogs.sas.com/content/iml/2019/07/15/create-discrete-heat-map-sgplot.html. 
		Include the heatmap in your report and discuss.;
		
		
*    11. Using again the data set created in question 7, draw a lineplot that displays O3_AQI over the years for the 
		3 counties with highest concentration as concluded from question 9. When plotting, take monthly mean values 
		as the representative values by using an appropiate format for Date_local. The Y-axis limits should be 0 and 220. 
		Draw a reference line at 50, 100, 150 and 200 labeled good, moderate, unhealthy for some groups and unhealthy. 
		The following SAS paper covers this topic: http://support.sas.com/resources/papers/proceedings09/158-2009.pdf  
		Include the graph in your report and discuss.;


*    12. Subset the data: select the observations from the year 2015 and verify whether there is an association between 
		temperature and O3_AQI. Report and discuss your findings.;
		
		
*    13. Write a pdf report with the ODS system of max 5 pages containing the following:
    • Names of the group members with a mentioning of who did what.
    • A short introduction on the topic.
    • Answers to the questions with requested plots and tables inserted.
    • The name of the report should be as follows: SASproject_groupX.pdf. The code should be sent as a separate file 
    named SASproject_groupX.sas. This code is expected to be between 300 and 400 lines.;
