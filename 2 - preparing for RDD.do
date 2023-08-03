
adopath + "U:\My Documents\PAPERS PUBLICATION\ADOPATH"
sysdir set PLUS "U:\My Documents\PAPERS PUBLICATION\ADOPATH"
clear all 
clear all
cap: log close
cd "S:\databases\1_Projets\CrossEUwork_Andrea_Albanese\marclondon\data\"


set more off


use "S:\databases\1_Projets\CrossEUwork_Andrea_Albanese\marclondon\data\data.dta", clear

replace tduration_active_NONZERO=0 if tduration_active==0
replace tduration_active_ZERO=0 if tduration_active==0
replace tdistance_car_NONZERO=0 if tdistance_car==0
replace tdistance_car_ZERO=0 if tdistance_car==0
replace tduration_rest_NONZERO=0 if tduration_rest_NONZERO==0
replace tdistance_rest_NONZERO=0 if tdistance_rest_NONZERO==0


tostring htdate, gen(htdateSTR)
tostring tenure, gen(tenureSTR)

gen yearTEN=substr(tenureSTR, 1, 4)
gen monthTEN=substr(tenureSTR, 5, 2)
gen dayTEN=substr(tenureSTR, 7, 2)
destring monthTEN dayTEN yearTEN, replace




tostring htdate, replace
gen YEARH= substr(htdate, 1, 4 )
gen MONTHH= substr(htdate, 5, 2 )
destring YEARH, replace
destring MONTHH, replace
tab MONTHH, gen(MONTHH_)
destring htdate, replace
rename distanceinkmtothewesternextensio distWEST
rename distanceinkmtothecentralzone distCENTER
rename  householdisinsidethecentralzonen houseCENTER
rename  householdisinsidethewesternexten houseWEST
rename  householdisinsidethecentralzoneo houseCENTER_WEST



di "if missing information in the survey (var hhccz,hhwez) , use information from survey of people in the same  postcodes"
replace hhccz=. if hhccz==0
replace hhwez=. if hhwez==0
replace hhccz=0 if hhccz==2
replace hhwez=0 if hhwez==2



cap: drop carown
gen carown=hcvn>=1 if hcvn!=-1 & hcvn!=.
gen carunkn= hcvn==-1 | hcvn==.
tab carown



*CREATE COVARIATES:
gen period=1 if wezperiod1==1
replace period=2 if wezperiod2==1
replace period=3 if wezperiod3==1


qui tabulate yearid, generate(year)
qui tabulate income, generate(inc)

*any child below age 5
gen childrenB5=tunder5!=0 &  tunder5!=.

*Long term health problem / disabilty that limits daily activity
gen healthprob2=pltpmd==1  

*work status:
gen work=pwkstat>=1 & pwkstat<=5
*student or less than 16 (all missing status) 
gen student=pwkstat==5 | age<16
*unknown status
gen UNKNWwork= pwkstat==.  & age>16 & age!=.

gen unemplINACTIVEother=work!=1 & student!=1  & UNKNWwork!=1 
*selfempl or work from hom
cap: drop SELFempl
gen SELFempl=pemplos==2 | pemplos==3  | pewu==3 
*household size (logs)
gen lnHHsize=ln(hresnon)
*enthinicty
gen White=pegroup==17 | pegroup==18 | pegroup==2 | pegroup==3 
gen Asian=pegroup>=8 & pegroup<=11
gen Other=Asian!=1  & White!=1
*single
gen single=hresnon==1

*fixed effect border 
gen bSEGMENT=idCENTERorWESTbord if htdate>=20070219 & htdate<=20101224
replace bSEGMENT=idCENTERbord  if htdate<20070219 | htdate>20101224


*CLEANING DATASET
drop if (yearid==9 & YEAR<=2008) | YEAR==. | dist==.
drop if age<18 
drop if   healthprob2==1
*v - First trip of day is from home
keep if tt1fhm==1
*only weekdays
keep if weekend==0 
tab YEAR , gen(YEAR_)
tab  htdow, gen(dayw_)
gen age2=age*age
tab  dirZONE
_pctile  tdistance_car_NONZERO, p(99.9)
  return list
  _pctile  tduration_active_NONZERO, p(99.9)
  return list
keep if    tduration_active_NONZERO< 326 & tdistance_car_NONZERO< 285.6919860839844


	 
	 
	*I had to write 179 as to have 50 (due to ties)
egen SEGMENT2 = cut(bSEGMENT), group(179)
codebook SEGMENT2
replace SEGMENT=SEGMENT2
tab SEGMENT2, gen(DSEGMENT_)
drop DSEGMENT_1


	gen lic=(pdlcar==1 | ppdlcar==1) 

	
	keep period  hcvn hovnan hvehnan hsvnan hcarnan  hcaracb hcarsdp tenure htdate hresnon   lnHHsize childrenB5 single bSEGMENT hincomei  dist distCENTER              carown   carunkn bSEGMENT  immigrant workin nonzero idWESTbord distCENTER distWEST  hincomei dist                 DSEGMENT_* SEGMENT dirZONE age  age2 female inc1 inc2 inc3 inc4 inc5 inc6 inc7 inc8 inc9 inc10     Asian  White  SELFempl   unemplINACTIVE UNKNWwork      carown lic student dayw_1 dayw_2 dayw_3 dayw_4 dayw_5 YEAR_1 YEAR_2 YEAR_3 YEAR_4 YEAR_5 YEAR_6 YEAR_7 YEAR_8  MONTHH_1  MONTHH_2 MONTHH_3 MONTHH_4 MONTHH_5 MONTHH_6 MONTHH_7 MONTHH_8 MONTHH_9 MONTHH_10 MONTHH_11 MONTHH_12  childrenB5 single hresnon    tduration_active_NONZERO tdistance_car_NONZERO tdistance_rest_NONZERO     tduration_active_ZERO  tduration_rest_ZERO tduration_car_ZERO    tdistance_rest_NONZERO
	
compress


cap: drop centre out
gen centre= dist<=2
cap: drop ALL N
gen ALL=1

gen otherRACE=White==0 & Asian==0
gen EMP=SELFempl==0 &   unemplINACTIVE==0 & UNKNWwork==0 & student  ==0 
**#
gen N=1

table ()  centre   , statistic(mean  tduration_active_NONZERO tdistance_car_NONZERO tdistance_rest_NONZERO    age   female inc1 inc2 inc3 inc4 inc5 inc6 inc7 inc8 inc9 inc10     Asian  White otherRACE EMP SELFempl   unemplINACTIVE UNKNWwork student      lic     dayw_1 dayw_2 dayw_3 dayw_4 dayw_5 YEAR_1 YEAR_2 YEAR_3 YEAR_4 YEAR_5 YEAR_6 YEAR_7 YEAR_8 MONTHH_1   MONTHH_2 MONTHH_3 MONTHH_4 MONTHH_5 MONTHH_6 MONTHH_7 MONTHH_8 MONTHH_9 MONTHH_10 MONTHH_11 MONTHH_12) statistic(total N ) statistic(sd   tduration_active_NONZERO tdistance_car_NONZERO tdistance_rest_NONZERO    age)   nformat(%5.3f mean)  nototals

replace centre=2 if centre==0
histogram hincome, discrete  by(centre) scheme(s2mono)
gr_edit plotregion1.subtitle[1].text = {}
gr_edit plotregion1.subtitle[1].text.Arrpush Inner London
// subtitle[1] edits

gr_edit plotregion1.subtitle[2].text = {}
gr_edit plotregion1.subtitle[2].text.Arrpush Rest
// subtitle[2] edits

// subtitle[3] edits

gr_edit note.text = {}
gr_edit note.text.Arrpush Graphs by gg
// note edits

gr_edit b1title.text = {}
gr_edit b1title.text.Arrpush Income classes
gr_edit note.text = {}

graph export income.png, width(1200) replace


gen nocharge=nonzero==.
compress
drop nonzero
tab workin dirZONE, m
cap: drop nocharge 
cap: drop dirCENTER
 gen nocharge = tduration_active_ZERO!=0 | tduration_rest_ZERO!=0 | tduration_car_ZERO!=0

 cap: drop carunkn
  gen carunkn=carown==.
replace carown=0 if carown==.

 
 *move last year
 tostring htdate tenure, replace
 cap: drop  monthTEN dayTEN yearTEN monthTODAY dayTODAY yearTODAY
 gen monthTEN=substr(tenure,5,2)
 gen dayTEN=substr(tenure,7,2)
  gen yearTEN=substr(tenure,1,4)

   gen monthTODAY=substr(htdate,5,2)
 gen dayTODAY=substr(htdate,7,2)
  gen yearTODAY=substr(htdate,1,4)
  
  destring monthTEN dayTEN yearTEN monthTODAY dayTODAY yearTODAY htdate, replace
    replace dayTEN=1 if dayTEN==.
    replace dayTEN=1 if dayTEN==0
    replace dayTEN=30 if dayTEN==32

  cap: drop tdENTRY tdTODAY 
 gen tdENTRY = mdy(monthTEN, dayTEN, yearTEN )
  gen tdTODAY = mdy(monthTODAY, dayTODAY, yearTODAY)
format tdENTRY  tdTODAY %td
order tdENTRY tdTODAY
cap: drop recentmover
gen TENURE=tdTODAY-tdENTRY

 order    tdTODAY tdENTRY monthTODAY dayTODAY yearTODA monthTEN dayTEN yearTEN
 
 sort TENURE
 
 order TENURE tdTODAY tdENTRY htdate
 
  replace TENURE=. if TENURE<-1
 replace TENURE=0 if TENURE<0

 gen recentmover=TENURE<=365  if TENURE!=.

  
 

 gen OWNCARgeneral=hcarnan>=1 if  hcarnan!=. & hcarnan!=-1
 tab OWNCARgeneral carown
  tab OWNCARgeneral 
 replace OWNCARgeneral=1 if hsvnan>=1 &  hsvnan!=. & hsvnan!=-1
  tab OWNCARgeneral , m




 
keep period OWNCARgeneral     htdate recentmover  carunkn    dirZONE  workin     bSEGMENT hincomei  dist distCENTER nocharge  immigrant DSEGMENT_* SEGMENT  carown lic     age age2  female inc1 inc2 inc3 inc4 inc5 inc6 inc7 inc8 inc9 inc10     Asian  White otherRACE EMP SELFempl   unemplINACTIVE UNKNWwork student          dayw_1 dayw_2 dayw_3 dayw_4 dayw_5 YEAR_1 YEAR_2 YEAR_3 YEAR_4 YEAR_5 YEAR_6 YEAR_7 YEAR_8 MONTHH_1   MONTHH_2 MONTHH_3 MONTHH_4 MONTHH_5 MONTHH_6 MONTHH_7 MONTHH_8 MONTHH_9 MONTHH_10 MONTHH_11 MONTHH_12    tduration_active_NONZERO tdistance_car_NONZERO               idWESTbord tdistance_rest_NONZERO  distWEST
 




compress

  save "S:\databases\1_Projets\CrossEUwork_Andrea_Albanese\marclondon\data\london", replace
