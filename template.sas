*    13. Write a pdf report with the ODS system of max 5 pages containing the following:
    ? Names of the group members with a mentioning of who did what.
    ? A short introduction on the topic.
    ? Answers to the questions with requested plots and tables inserted.
    ? The name of the report should be as follows: SASproject_groupX.pdf. The code should be sent as a separate file 
     named SASproject_groupX.sas. This code is expected to be between 300 and 400 lines.;

* %let path = H:/ac 2019-2020/SC/SAS/project; /* path Thiebe */
* %let path = H:/SAS/HW/;  /* path Ondrej */
%let path = /folders/myfolders/Project/STATCOM_SASPROJECT/; /* path Jan */
* %let path = H:/Statistical-Computing/SAS/Project/Data/;  /* path Emiel */
* %let path = H:/ac 2019-2020/SC/SAS/project; /* libname Thiebe */

options papersize=a4 orientation = portrait 
                     bottommargin = 2cm 
                     topmargin=2cm 
                     leftmargin=1.5cm 
                     rightmargin=1.5cm; /* settings for page */
ods pdf file = "&path.SASproject_group13.pdf" startpage =never style=sasweb; /* startpage = never plots everyrhing on one page */ 
ods graphics / reset=all width=30cm height=20cm ; /* settings for graph, i hope to find something similar for the table Q8*/
/* introduction */
title 'Introduction';
proc odstext;

p 'Ever since the industrialization of the world and the enormous increase in the global human population it brought with it,
 pollution has increasingly become a problem. The rising industrial and energy production relied on the burning
 of fossil fuels and biomass to operate and made use of environmentally toxic chemicals that were released in the
 air and gravely deteriorate the quality of the air we breath. The expansion of towns and cities, and the dramatic
 increase in traffic only aggravated the air pollution problem. Realizing the problem, governments all over the world,
 both individually and together, vouched to create standards, start monitoring and increase air quality in, for example,
 the Clean Air Act (CAA) by the US, the Montreal Protocol by the United Nations,
 and the Convention on Long-range Transboundary Air Pollution (Air Convention) by the European Commission.' /
 style = [color=black fontsize=11pt];

p 'According to the World Health Organisation (WHO), 9 out of 10 people breathe air containing high levels of pollutants and this
 air pollution kills an estimated seven million people worldwide every year. The causes of these premature deaths are strokes,
 hearth diseases, lung cancer and both chronic and acute respiratory diseases. The WHO offers global guidance on thresholds and
 limits for key pollutants that pose health risks under their 2005 WHO Air quality guidelines, with a revision expected to be published in 2020.
 These guidelines are based on expert evaluation of current scientific evidence for: particulate matter (PM), ozone (O3), nitrogen dioxide (NO2),
 sulphur dioxide (SO2) and carbon monoxide (CO). The Environmental Protection Agency (EPA) has developed an Air Quality Index (AQI) based on these pollutants.
 It is an index for reporting the daily air quality and is divided in six categories indicating levels of health concern,
 ranging from good (0-50) to hazardous (301 � 500) air quality conditions.'/ 
 style = [color=black fontsize=11pt];

p 'Ground-level ozone, not to be confused with atmospheric ozone, and airborne particulate matter pose the greatest threat to human health in the US.
 Ozone at ground level is one of the major constituents of photochemical smog. It is formed by the reaction with sunlight (photochemical reaction)
 of pollutants such as nitrogen oxides (NOx) and volatile organic compounds (VOCs) emitted by vehicles, solvents and industry. As a result, the highest
 levels of ozone pollution occur during periods of sunny weather. Excessive ozone in the air can have a marked effect on human health.
 It can cause breathing problems, trigger asthma, reduce lung function and cause lung diseases. 
 In this project we focus on the ozone levels in the state of Pennsylvania (PA) in the US between the years 2000 and 2016.'/
 style = [color=black fontsize=11pt];
run;
proc odstext;
p 'Sources:' /  style = [color=black fontsize=11pt];
list ;
    item 'https://ec.europa.eu/environment/air/index_en.htm' /  style = [color=black fontsize=11pt];
    item 'https://www.unece.org/env/lrtap/welcome.html.html' /  style = [color=black fontsize=11pt];
    item 'https://www.epa.gov/laws-regulations/summary-clean-air-act' /  style = [color=black fontsize=11pt];
    item 'https://www.unenvironment.org/ozonaction/who-we-are/about-montreal-protocol' /  style = [color=black fontsize=11pt];
    item 'https://www.who.int/news-room/fact-sheets/detail/ambient-(outdoor)-air-quality-and-health' / style = [color=black fontsize=11pt];
    item 'https://airnow.gov/index.cfm?action=aqibasics.aqi' /  style = [color=black fontsize=11pt];
    end;
run; /* i have no idea why this resetted the page */

* Set libname (Proj);
libname Proj "&path";

*    1. Import the 3 data sets.;
%macro loadcsv(csvname, dataname);
				PROC IMPORT DATAFILE=&csvname
					OUT = WORK.&dataname
					DBMS = CSV REPLACE;
				RUN;
%mend loadcsv;

FILENAME csv1 "&path.pollution_us_2000_2016.csv" TERMSTR=LF;
FILENAME csv2 "&path.avg_max_temp.csv" TERMSTR=LF;
FILENAME csv3 "&path.us-state-ansi-fips.csv" TERMSTR=LF;
%loadcsv(csv1, pollution);
%loadcsv(csv2, climate);
%loadcsv(csv3, USstates);

proc odstext;
p 'The pollution data was obtained from https://www.kaggle.com/ksaulakh/r-analysis-pollution-data, 
 the climate data downloaded from https://www.ncdc.noaa.gov/ghcn/comparative-climatic-data and
 the data file us-state-ansi-fips.csv, further referred to as USstates, has provided the state names, 
 state name FIPS codes (st) and postal abbreviations (stusps).' /  style = [color=black fontsize=12pt];
run;

proc odstext;
p 'Using the climate data, the mean temperature in each month was computed for every state. The results for the (alphabetically) first 5 states are shown in the following table.';
run;

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

ods select none;
proc print data=work.meanTempLong (obs=25)noobs;
	format 	Temperature_Mean 6.2
			month mnthfmt.; 
run;
ods select all;
title;


*    4. Merge the data table obtained in Question 3 with the FIPS code data set using stsups as by variable and outputting 
		only matching rows.;
proc sort data = work.USstates out = work.USstates;
	by stusps;
run;
* proc print data = work.USstates;run;
proc sort data = work.meanTempLong out = work.meanTempLong;
	by state_postal_abbr month;
run;
* proc print data = work.meanTempLong;run;
data work.statesTemp;
	merge work.meanTempLong(rename = (state_postal_abbr = stusps) in = inTemp) work.USstates(in = inState);
	by stusps;
	if inTemp = 1 and inState = 1;
	
run;
ods select none;
proc print data=work.statesTemp (obs=5)noobs; 
	format 	Temperature_Mean 6.2
			month mnthfmt.;
run;
ods select all;

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
ods select none;
proc print data=work.pollutionTemp (obs=15);
	format 	Temperature_Mean 6.2
			month mnthfmt.;
run;
ods select all;
*    6. Use an appropiate procedure for comparing the number of levels of county_code and county. What do you observe? 
		Write down your findings. Remedy the problem by creating a unique county code by concatenating state_code and
		county_code separated by an underscore. Search for a SAS function that can do this. ;

proc odstext;
p 'The monthly average temperatures for each state were merged with the USstates 
dataset containing additional details about each state.
 Subsequently, the results were merged with the pollution dataset. 
 The Country_Code variable contained in the final result does not uniquely specify each county 
 - there exist different counties with the same code. However, within each state, the Country_Codes are unique. 
 Thus an unique country identifier of the form StateCode_CountryCode was made.'/  style = [color=black fontsize=12pt];
run;

ods select none;

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
ods select all;

ods select none;
/* Thiebe: Did this for checking, although it's better, now we seemingly have too much county_id's*/
proc freq data = work.pollutionTemp nlevels;
	tables County county_id / noprint;
run;

/* Still some counties with multiple id's */ 
proc sql;
	select * from
		(select *, count(County) as count
			from (select distinct State, County, county_id
				from work.pollutionTemp)
		group by County)
	where count > 1;
run;
ods select all;

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
/*proc print data=Proj.pollutionTemp (obs=15); 
	format month mnthfmt.;
run;*/

proc odstext;
p 'For further analysis, only the observations from Pennsylvania(PA) were considered. 
In the table below, the average values of O3_mean and O3_AQI are shown for each month and county.'
/  style = [color=black fontsize=12pt];
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

proc odstext;
p 'The results show that in the summer months for several counties even the mean O3_AQI is not in the good range (<50).'/ 
 style = [color=black fontsize=11pt];
run;
proc odstext;
p 'The average concentrations of O3 by county are plotted, showing that he pollution is quite uniform over the counties
(at least in the average).'/ 
 style = [color=black fontsize=11pt];
run;

*    9. Plot the average concentration of O3 in different counties, using barplots, in descending order. Use appropiate 
		axis titles. In case you are trying the unicodes for subscripts, use labelattrs=(family='Times New Roman') 
		since the unicode will not work for the standard font. Include the graph in your report and discuss.;
proc sgplot data=work.meansO3;
	vbar County / stat=mean response=O3_Mean_Mean
	categoryorder=respdesc;
	yaxis label = 'Average Concentration O3';
run;

proc odstext;
p 'The yearly averages of O3 concentration are displayed in the following heatmap. 
The (O3 - related) air quality seems to be typically slightly improving
 - notably in Erie, York and Cambria.'/ 
 style = [color=black fontsize=11pt];
run;

*    10. Calculate the yearly average of the ozone concentration for each county and output these values to a SAS data set. 
		Hint: Use an appropiate format statement to achieve this. Using this outputted data set, use the HEATMAPPARM statement 
		in PROC SGPLOT to create a continuous heat map with Date_local in the x-axis, county in the Y-axis and the average 
		ozone concentration as response. You might want to have a look at the SAS blog from Rick Wicklin 
		https://blogs.sas.com/content/iml/2019/07/15/create-discrete-heat-map-sgplot.html. 
		Include the heatmap in your report and discuss.;
	
title 'Yearly average O3 concentration for each county';
ods select none;
proc tabulate data=Proj.pollutionTemp format=8.3 out=work.yearmeans03;
	class County Date_Local;
	var O3_Mean;
	table County,Date_Local*O3_Mean*mean;
	label Date_Local = 'Year' 
		  O3_Mean = 'O3 Concentration';
	format Date_Local YEAR4.;
run;
ods select all;
/* *Was getting errors that O3_Means didn't exist but this showed that it was saved as O3_Mean_Mean;
proc contents data = work.yearmeans03;  
run;
*/

proc sort data = work.yearmeans03;
	by Date_Local O3_Mean_Mean;
run;

/*title "Continuous Heat Map option 1";
title2 "Mean O3 concentration per county per year";
proc sgplot data=work.yearmeans03; 
	heatmapparm x=Date_Local y=County colorresponse=O3_Mean_Mean / colormodel=TwoColorRamp outline discretex;
	label O3_Mean_Mean = "Average O3 concentration";
	gradlegend;
run;
title;
*/
title "Continuous Heat Map option 2";
title2 "Mean O3 concentration per county per year";
proc sgplot data=work.yearmeans03;
	heatmapparm x=Date_Local y=County colorresponse=O3_Mean_Mean / 
	colormodel=(CX3288BD CX99D594 CXE6F598 CXFEE08B CXFC8D59 CXD53E4F)
	outline discretex;
	label O3_Mean_Mean = "Average O3 concentration";
	gradlegend;
run;
title;
/*
title "Continuous Heat Map option 3";
title2 "Mean O3 concentration per county per year"; 
proc sgplot data=work.yearmeans03;
	heatmapparm x=Date_Local y=County colorresponse=O3_Mean_Mean / 
	colormodel=(White Orange)
	label O3_Mean_Mean = "Average O3 concentration";
	gradlegend;
run;
title;
*/
/*COMMENT: years in right order, 
ideally the county names should have longer length (possible with lenght county $ desiredlength )*/

proc odstext;
p 'The Adams, Erie and Lancaste counties are the three counties with the highest average O3 concentration 
(see the barplot above). The O3_AQI over time there is plotted below.
 From the results, it seems that at least the maxima of O3 concentration are getting smaller.'/  style = [color=black fontsize=12pt];
run;

*    11. Using again the data set created in question 7, draw a lineplot that displays O3_AQI over the years for the 
		3 counties with highest concentration as concluded from question 9. When plotting, take monthly mean values 
		as the representative values by using an appropiate format for Date_local. The Y-axis limits should be 0 and 220. 
		Draw a reference line at 50, 100, 150 and 200 labeled good, moderate, unhealthy for some groups and unhealthy. 
		The following SAS paper covers this topic: http://support.sas.com/resources/papers/proceedings09/158-2009.pdf  
		Include the graph in your report and discuss.;
title 'Yearly average O3 Air Quality Index for the top 3 countries with highest O3 concentration';
ods select none;
proc tabulate data=Proj.pollutionTemp format=8.3 out=work.monthyearmeans03;
	class County Date_Local;
	var O3_AQI;
	table County*Date_Local, O3_AQI*mean;
	label Date_Local = 'Month_Year' 
		  O3_Mean = 'O3 Concentration';
	format Date_Local MONYY5.;
run;
ods select all;

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

proc odstext;
p 'The O3 concentration in the plot above shows a strong seasonal dependence. It is natural to ask whether it depends on the temperature.
 As the data from 2015 show, there is a positive correlation.' /  style = [color=black fontsize=12pt];
run;

*    12. Subset the data: select the observations from the year 2015 and verify whether there is an association between 
		temperature and O3_AQI. Report and discuss your findings.;
title "association between temperature and O3_AQI";
ods select none;
proc tabulate data=Proj.pollutionTemp format=8.3 out=Proj.pollutionTemp2015;
	class County Date_Local;
	var O3_AQI Temperature_Mean;
	table Date_Local, county*(O3_AQI*mean Temperature_Mean*mean);
	label Date_Local = 'Month' 
		  O3_Mean = 'O3 Concentration';
	format Date_Local MONTH.;
	where year(Date_Local) = 2015;
run;
ods select all;

proc sgplot data=Proj.pollutionTemp2015;
	reg x=O3_AQI_Mean y=Temperature_Mean_Mean /cli clm ;
	yaxis label = "Average O3 Air Quality Index" Min = 0 Max = 220;
	xaxis label = "Average temperature";
	refline 50 100 150 200 / 
		label = ('Good' 'Moderate' 'Unhealthy for some groups' 'Unhealthy');
run;

ods select none;
proc corr data=Proj.pollutionTemp2015 ;
   var O3_AQI_Mean;
   with Temperature_Mean_Mean;
run;
ods select all;

/* when we don't group by month we get this graph,
	more chaos, but same conclusion.
	grouping by month is logical, since we took 
	the average temperature per month in the beginning of the project */

/*proc sgplot data=Proj.pollutionTemp;
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
title;*/

ods pdf close;
