clear all
set obs 10

//============================================================================//
// RFE on Math scores (short-term)
// data is coming from regression tables
//============================================================================//

gen treat=1 in 1
	replace treat=1 in 2 
	replace treat=1 in 3
	replace treat=1 in 4
	replace treat=1 in 5
	replace treat=2 in 6
	replace treat=2 in 7
	replace treat=2 in 8
	replace treat=2 in 9 
	replace treat=2 in 10	
	
gen group = "All Students" in 1
	replace group = "Above-median" in 2
	replace group = "Below-median" in 3
	replace group = "Female" in 4
	replace group = "Male" in 5
	replace group = "All Students" in 6
	replace group = "Above-median" in 7
	replace group = "Below-median" in 8
	replace group = "Female" in 9
	replace group = "Male" in 10
	
	
// adjusting the location of the bars in the graph
gen num=treat if group=="All Students"
	replace num=treat+3 if group=="Above-median"
	replace num=treat+6 if group=="Below-median"
	replace num=treat+9 if group=="Female"
	replace num=treat+12 if group=="Male"
	
	
// adding coef. from ddml (short-term)
gen coef=0.018 if treat==1 & group=="All Students"
	replace coef=0.009 if treat==1 & group=="Above-median"
	replace coef=0.022 if treat==1 & group=="Below-median"
	replace coef=0.019 if treat==1 & group=="Female"
	replace coef=0.015 if treat==1 & group=="Male"
	
	replace coef=0.022 if treat==2 & group=="All Students"
	replace coef=0.083 if treat==2 & group=="Above-median"
	replace coef=-0.002 if treat==2 & group=="Below-median"
	replace coef=0.017 if treat==2 & group=="Female"
	replace coef=0.033 if treat==2 & group=="Male"
	
	
// adding SE
gen se=0.010 if treat==1 & group=="All Students" 
	replace se=0.020 if treat==1 & group=="Above-median"
	replace se=0.009 if treat==1 & group=="Below-median"
	replace se=0.011 if treat==1 & group=="Female"
	replace se=0.011 if treat==1 & group=="Male"
	
	replace se=0.015 if treat==2 & group=="All Students"
	replace se=0.034 if treat==2 & group=="Above-median"
	replace se=0.012 if treat==2 & group=="Below-median"
	replace se=0.015 if treat==2 & group=="Female"
	replace se=0.015 if treat==2 & group=="Male"



// pval 
gen tstat = coef/se

gen df=178606 if group=="All Students"
	replace df=68976 if group=="Above-median"
	replace df=109629 if group=="Below-median"
	replace df=91949 if group=="Female"
	replace df=86656 if group=="Male"
	
gen pval = 2 * ttail(df, abs(tstat))


// CIs
gen hi = coef + (1.96*se)
gen lo = coef - (1.96*se)


// short-term graph 
sort num 
list pval coef num 

graph twoway (bar coef num if treat==1) ///
(bar coef num if treat==2) || ///
(rcap hi lo num), ///
xlabel(1.5 "All Students" 4.5 "Above-median" 7.5 "Below-median" 10.5 "Female" 13.5 "Male", noticks) ///
text(0.018 1 "*", place(ne) size(small) color(black)) ///
text(0.022 2 "", place(ne) size(small) color(black)) ///
text(0.009 4 "", place(ne) size(small) color(black)) ///
text(0.083 5 "**", place(ne) size(small) color(black)) ///
text(0.022 7 "**", place(ne) size(small) color(black)) ///
text(-0.002 8 "", place(ne) size(small) color(black)) ///
text(0.019 10 "", place(ne) size(small) color(black)) ///
text(0.017 11 "", place(ne) size(small) color(black)) ///
text(0.015 13 "", place(ne) size(small) color(black)) ///
text(0.033 14 "**", place(ne) size(small) color(black)) ///
ytitle("Average Math Score") graphregion(color(white)) xtitle("") title("Short-term Effects") ///
legend(label(1 "ATEMA") label(2 "ATEMA + Parental Engagement"))

graph export "D:\SECURE\data 2024\analysis\atema\output\graphs\math score (short-term).png", as(png) replace






//============================================================================//
// RFE on Math scores (long-term)
// data is coming fromo regression tables
//============================================================================//

clear all
set obs 10



gen treat=1 in 1
	replace treat=1 in 2 
	replace treat=1 in 3
	replace treat=1 in 4
	replace treat=1 in 5
	replace treat=2 in 6
	replace treat=2 in 7
	replace treat=2 in 8
	replace treat=2 in 9 
	replace treat=2 in 10	
	
gen group = "All Students" in 1
	replace group = "Above-median" in 2
	replace group = "Below-median" in 3
	replace group = "Female" in 4
	replace group = "Male" in 5
	replace group = "All Students" in 6
	replace group = "Above-median" in 7
	replace group = "Below-median" in 8
	replace group = "Female" in 9
	replace group = "Male" in 10
	
	
// adjusting the location of the bars in the graph
gen num=treat if group=="All Students"
	replace num=treat+3 if group=="Above-median"
	replace num=treat+6 if group=="Below-median"
	replace num=treat+9 if group=="Female"
	replace num=treat+12 if group=="Male"
	
	
// adding coef. from ddml (short-term)
gen coef=-0.044 if treat==1 & group=="All Students"
	replace coef=-0.002 if treat==1 & group=="Above-median"
	replace coef=-0.009 if treat==1 & group=="Below-median"
	replace coef=-0.006 if treat==1 & group=="Female"
	replace coef=-0.005 if treat==1 & group=="Male"
	
	replace coef=0.04 if treat==2 & group=="All Students"
	replace coef=0.038 if treat==2 & group=="Above-median"
	replace coef=0.043 if treat==2 & group=="Below-median"
	replace coef=0.054 if treat==2 & group=="Female"
	replace coef=0.017 if treat==2 & group=="Male"
	
	
// adding SE
gen se=0.016 if treat==1 & group=="All Students" 
	replace se=0.028 if treat==1 & group=="Above-median"
	replace se=0.016 if treat==1 & group=="Below-median"
	replace se=0.019 if treat==1 & group=="Female"
	replace se=0.019 if treat==1 & group=="Male"
	
	replace se=0.018 if treat==2 & group=="All Students"
	replace se=0.036 if treat==2 & group=="Above-median"
	replace se=0.014 if treat==2 & group=="Below-median"
	replace se=0.019 if treat==2 & group=="Female"
	replace se=0.02 if treat==2 & group=="Male"



// pval 
gen tstat = coef/se

gen df=178606 if group=="All Students"
	replace df=68976 if group=="Above-median"
	replace df=109629 if group=="Below-median"
	replace df=91949 if group=="Female"
	replace df=86656 if group=="Male"
	
gen pval = 2 * ttail(df, abs(tstat))


// CIs
gen hi = coef + (1.96*se)
gen lo = coef - (1.96*se)


// short-term graph 
sort num 
list pval coef num 

graph twoway (bar coef num if treat==1) ///
(bar coef num if treat==2) || ///
(rcap hi lo num), ///
xlabel(1.5 "All Students" 4.5 "Above-median" 7.5 "Below-median" 10.5 "Female" 13.5 "Male", noticks) ///
text(-0.044 1 "", place(ne) size(small) color(black)) ///
text(0.04 2 "**", place(ne) size(small) color(black)) ///
text(-0.002 4 "", place(ne) size(small) color(black)) ///
text(0.038 5 "", place(ne) size(small) color(black)) ///
text(-0.009 7 "", place(ne) size(small) color(black)) ///
text(0.043 8 "***", place(ne) size(small) color(black)) ///
text(-0.006 10 "", place(ne) size(small) color(black)) ///
text(0.054 11 "***", place(ne) size(small) color(black)) ///
text(-0.005 13 "", place(ne) size(small) color(black)) ///
text(0.017 14 "", place(ne) size(small) color(black)) ///
ytitle("Average Math Score") graphregion(color(white)) xtitle("") title("Long-term Effects") ///
legend(label(1 "ATEMA") label(2 "ATEMA + Parental Engagement"))

graph export "D:\SECURE\data 2024\analysis\atema\output\graphs\math score (long-term).png", as(png) replace













 