global data="S:\databases\1_Projets\CrossEUwork_Andrea_Albanese\marclondon\data"
set more off
clear all
cap: log close
cd "S:\databases\1_Projets\CrossEUwork_Andrea_Albanese\marclondon\final"
*net install rdrobust, from(https://raw.githubusercontent.com/rdpackages/rdrobust/master/stata) replace
  * IMPLEMENT CATTANEO ET AL 2014 TO FIND OPTIMAL BANDWITHD ON THE FULL SAMPLE (WITHOUT IMPOSING PRELIMINARY RESTRICTIONS
  *AND ALLOWING ASSYMETRIC BANDWIDTH DUE TO THE ASSYMETRIC NATURE (INSIDE THE CENTER MAX 2)
timer on 1
set matsize 11000, permanently
  clear all
	
	

  use    "S:\databases\1_Projets\CrossEUwork_Andrea_Albanese\marclondon\data\london", clear
  cap: log close
log using log/density.txt, replace text
*density test
rddensity  dist  ,  plot_ciuniform plot    plot_grid(es)    graph_opt(title("") graphregion(color(white) ) leg(off) scheme(s2mono))
graph save GRAPH/GPH/rddensity.gph, replace
graph export GRAPH/PNG//rddensity.png, width(1200) replace
cap: log close



set matsize 11000, permanently
  clear all
	cap: log close
local G="Full sample"
  foreach het in   PLAC2  PLAC4  PLAC6  PLAC8  PLAC10  PLAC12  PLAC14      PLAC16   {

  global het="`het'"
cap: mkdir  GRAPH\GPH/${het}
cap: mkdir  GRAPH\PNG/${het} 


**# Bookmark #1
foreach Y in    tduration_active_NONZERO tdistance_car_NONZERO      {	
    
  use    "S:\databases\1_Projets\CrossEUwork_Andrea_Albanese\marclondon\data\london", clear
  describe DSEGMENT_*, varlist
local seg=r(varlist)    



global X="  `seg'   age  age2 female inc2 inc3 inc4 inc5 inc6 inc7 inc8 inc9 inc10     Asian  White  SELFempl   unemplINACTIVE UNKNWwork student     lic   dayw_2 dayw_3 dayw_4 dayw_5 YEAR_2 YEAR_3 YEAR_4 YEAR_5 YEAR_6 YEAR_7 YEAR_8   MONTHH_2 MONTHH_3 MONTHH_4 MONTHH_5 MONTHH_6 MONTHH_7 MONTHH_8 MONTHH_9 MONTHH_10 MONTHH_11 MONTHH_12 " 


if "${het}"=="PLAC2" {
            	drop if dist<0
    replace dist=dist-2
}

if "${het}"=="PLAC4" {
            	drop if dist<0

    replace dist=dist-4
}

if "${het}"=="PLAC6" {
            	drop if dist<0

    replace dist=dist-6
}

if "${het}"=="PLAC8" {
            	drop if dist<0

    replace dist=dist-8
}

if "${het}"=="PLAC10" {
            	drop if dist<0

    replace dist=dist-10
}


if "${het}"=="PLAC12" {
            	drop if dist<0

    replace dist=dist-12
}

if "${het}"=="PLAC14" {
            	drop if dist<0

    replace dist=dist-14
}
if "${het}"=="PLAC16" {
            	drop if dist<0

    replace dist=dist-16
}
if "${het}"=="PLAC18" {
            	drop if dist<0

    replace dist=dist-18
}
if "${het}"=="PLAC20" {
            	drop if dist<0

    replace dist=dist-20
}
if "${het}"=="PLAC22" {
            	drop if dist<0

    replace dist=dist-22
}
if "${het}"=="PLAC24" {
            	drop if dist<0

    replace dist=dist-24
}
if "${het}"=="PLAC26" {
            	drop if dist<0

    replace dist=dist-26
}
qui:	rdbwselect `Y'  dist,  p(1) kernel(triangular)  c(0)   covs($X)  bwselect(msetwo) masspoints(adjust)  vce(cluster SEGMENT)
local hTRl= e(h_msetwo_l)  
local hTRr= e(h_msetwo_r)  
local bTRl=e(b_msetwo_l)
local bTRr=e(b_msetwo_r)

	preserve
*triangular weights
gen wei=1-abs(dist)/`hTRl' if dist>=-`hTRl' & dist<0
replace wei=1-dist/`hTRr' if dist>=0 & dist<=`hTRr'

des ${X}, varlist
local lista=r(varlist)
foreach var2 in `lista'  { 
	sum `var2' [aw=wei] if dist>=-`hTRl' & dist<`hTRr'
	replace `var2' =(`var2' - r(mean))/r(sd)
		replace `var2'=0 if `var2'==.

}
  rdrobust `Y'  dist,   p(1) kernel(triangular) h(`hTRl' `hTRr' ) b(`bTRl' `bTRr') c(0)  covs($X)  bwselect(msetwo) vce(cluster SEGMENT)
 
 mat beta =e(b)
 local  Bl`Y'_R =beta[1,1]
 global Bl`Y'_R :  di %5.3f `Bl`Y'_R'

local Y0_`Y'=e(tau_cl_l)
global Y0_`Y':  di %5.1f `Y0_`Y''

local Y1_`Y'=e(tau_cl_r)
global Y1_`Y': di %5.1f `Y1_`Y''

local PC`Y'=(e(tau_cl) /${Y0_`Y'})*100 
global PC`Y': di %6.1f `PC`Y''

global locP_`Y'=e(p) 
global loc_`Y'=e(q) 

local BWlh_`Y'=round(`hTRl', 0.01)
global BWlh_`Y': di %6.2f `BWlh_`Y''

local BWrh_`Y'=round(`hTRr', 0.01)
global BWrh_`Y': di %6.2f `BWrh_`Y''

local BWlb_`Y'=round(`bTRl', 0.01)
global BWlb_`Y': di %6.2f `BWlb_`Y''

local BWrb_`Y'=round(`bTRr', 0.01)
global BWrb_`Y': di %6.2f `BWrb_`Y''


local  rpv_`Y'=e(pv_rb)
global rpv_`Y': di %04.3f `rpv_`Y'' 

local EffNh_`Y'=e(N_h_l)+e(N_h_r)
global EffNh_`Y': di %14.0fc `EffNh_`Y'' 

local EffNb_`Y'=e(N_b_l)+e(N_b_r)
global EffNb_`Y': di %14.0fc `EffNb_`Y'' 

local N_`Y'= e(N)
global N_`Y': di %14.0fc `N_`Y'' 

global CI_`Y'=e(ci_rb)


  

restore

*quadratic
qui:	rdbwselect `Y'  dist,  p(2) kernel(triangular)  c(0)   covs($X)  bwselect(msetwo) masspoints(adjust)  vce(cluster SEGMENT)
local hTRl= e(h_msetwo_l)  
local hTRr= e(h_msetwo_r)  
local bTRl=e(b_msetwo_l)
local bTRr=e(b_msetwo_r)


*triangular weights
gen wei=1-abs(dist)/`hTRl' if dist>=-`hTRl' & dist<0
replace wei=1-dist/`hTRr' if dist>=0 & dist<=`hTRr'

des ${X}, varlist
local lista=r(varlist)
foreach var2 in `lista'  { 
	sum `var2' [aw=wei] if dist>=-`hTRl' & dist<`hTRr'
	replace `var2' =(`var2' - r(mean))/r(sd)
		replace `var2'=0 if `var2'==.

}

  rdrobust `Y'  dist,    p(2) kernel(triangular) h(`hTRl' `hTRr' ) b(`bTRl' `bTRr') c(0)  covs($X)  bwselect(msetwo) vce(cluster SEGMENT)
 mat beta =e(b)
 local  Bl`Y'_RQ =beta[1,1]
 global Bl`Y'_RQ :  di %5.3f `Bl`Y'_RQ'

local Y0_`Y'Q=e(tau_cl_r)
global Y0_`Y'Q:  di %5.1f `Y0_`Y'Q'

local Y1_`Y'Q=e(tau_cl_l)
global Y1_`Y'Q: di %5.1f `Y1_`Y'Q'

local PC`Y'Q=(e(tau_cl) /${Y0_`Y'Q})*100 
global PC`Y'Q: di %6.1f `PC`Y'Q'

global locP_`Y'Q=e(p) 
global loc_`Y'Q=e(q) 

local BWlh_`Y'Q=round(`hTRl', 0.01)
global BWlh_`Y'Q: di %6.2f `BWlh_`Y'Q'

local BWrh_`Y'Q=round(`hTRr', 0.01)
global BWrh_`Y'Q: di %6.2f `BWrh_`Y'Q'

local BWlb_`Y'Q=round(`bTRl', 0.01)
global BWlb_`Y'Q: di %6.2f `BWlb_`Y'Q'

local BWrb_`Y'Q=round(`bTRr', 0.01)
global BWrb_`Y'Q: di %6.2f `BWrb_`Y'Q'


local  rpv_`Y'Q=e(pv_rb)
global rpv_`Y'Q: di %04.3f `rpv_`Y'Q' 

local EffNh_`Y'Q=e(N_h_l)+e(N_h_r)
global EffNh_`Y'Q: di %14.0fc `EffNh_`Y'Q' 

local EffNb_`Y'Q=e(N_b_l)+e(N_b_r)
global EffNb_`Y'Q: di %14.0fc `EffNb_`Y'Q' 

local N_`Y'Q= e(N)
global N_`Y'Q: di %14.0fc `N_`Y'Q' 

global CI_`Y'Q=e(ci_rb)

  


graph drop _all

}






	cap: log close

	
clear all
set obs 15
gen var="Beta" if _n==1
replace var="Robust CI" if _n==2
replace var="Robust p-value" if _n==3
replace var="% effect" if _n==4
replace var="Y1" if _n==5
replace var="Y0" if _n==6
replace var="BW Loc. Poly. [h] - left" if _n==7
replace var="BW Loc. Poly. [h] - right"  if _n==8
replace var="BW Bias [b] - left" if _n==9
replace var="BW Bias [b] - right" if _n==10
replace var="Order Loc. Poly. [p]" if _n==11
replace var="Order Bias [q]" if _n==12
replace  var="Total N" if _n==13
replace var="Eff. N estimate [h]" if _n==14
replace var="Eff. N bias [b]" if _n==15







foreach Y in    tduration_active_NONZERO tdistance_car_NONZERO      {	
    
	



gen `Y'_l ="${Bl`Y'_R}" if _n==1
replace `Y'_l="${CI_`Y'}"  if _n==2
replace `Y'_l="${rpv_`Y'}"  if _n==3
replace `Y'_l="${PC`Y'}"  if _n==4
replace `Y'_l="${Y1_`Y'}"  if _n==5
replace `Y'_l="${Y0_`Y'}"  if _n==6
replace `Y'_l="${BWlh_`Y'}"  if _n==7
replace `Y'_l="${BWrh_`Y'}"   if _n==8
replace `Y'_l="${BWlb_`Y'}"  if _n==9
replace `Y'_l="${BWrb_`Y'}"  if _n==10
replace `Y'_l="${locP_`Y'}"  if _n==11
replace `Y'_l="${loc_`Y'}"  if _n==12
replace  `Y'_l="${N_`Y'}"  if _n==13
replace `Y'_l="${EffNh_`Y'}"  if _n==14
replace `Y'_l="${EffNb_`Y'}"  if _n==15

gen `Y'_q ="${Bl`Y'_RQ}" if _n==1
replace `Y'_q="${CI_`Y'Q}"  if _n==2
replace `Y'_q="${rpv_`Y'Q}"  if _n==3
replace `Y'_q="${PC`Y'Q}"  if _n==4
replace `Y'_q="${Y1_`Y'Q}"  if _n==5
replace `Y'_q="${Y0_`Y'Q}"  if _n==6
replace `Y'_q="${BWlh_`Y'Q}"  if _n==7
replace `Y'_q="${BWrh_`Y'Q}"   if _n==8
replace `Y'_q="${BWlb_`Y'Q}"  if _n==9
replace `Y'_q="${BWrb_`Y'Q}"  if _n==10
replace `Y'_q="${locP_`Y'Q}"  if _n==11
replace `Y'_q="${loc_`Y'Q}"  if _n==12
replace `Y'_q="${N_`Y'Q}"  if _n==13
replace `Y'_q="${EffNh_`Y'Q}"  if _n==14
replace `Y'_q="${EffNb_`Y'Q}"  if _n==15


}
save ${het}.dta, replace
}


clear all
gen plac=""
  foreach het in      PLAC2  PLAC4  PLAC6  PLAC8  PLAC10  PLAC12  PLAC14      PLAC16  {
  
append using `het'.dta
replace plac="`het'" if  plac==""
  }
  compress
save PLAC.dta, replace
br plac var tduration_active_NONZERO_l tduration_active_NONZERO_q tdistance_car_NONZERO_l tdistance_car_NONZERO_q