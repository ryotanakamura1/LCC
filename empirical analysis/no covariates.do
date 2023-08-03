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
	cap: log close
	
  foreach het in   HnoX  HHnox HLnox {

  global het="`het'"
cap: mkdir  GRAPH\GPH/${het}
cap: mkdir  GRAPH\PNG/${het} 


if "${het}"=="HnoX" {
global Y="tduration_active_NONZERO tdistance_car_NONZERO   tdistance_rest_NONZERO"
}
if "${het}"=="HLnoX" | "${het}"=="HHnoX"  {
global Y="tduration_active_NONZERO tdistance_car_NONZERO   "
}


foreach Y in    $Y       {		
    
  use    "S:\databases\1_Projets\CrossEUwork_Andrea_Albanese\marclondon\data\london", clear
  describe DSEGMENT_*, varlist
local seg=r(varlist)    
global X="  `seg'  " 

di "Group: ${het}; Y=`Y'"

if "${het}"=="HLnox" {
keep if hincomei<6
}
if "${het}"=="HHnox" {
keep if hincomei>=6 
}


qui:	rdbwselect `Y'  dist,  p(1) kernel(triangular)  c(0)   covs($X)  bwselect(msetwo) masspoints(adjust)  vce(cluster SEGMENT)
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


if "${het}"=="HnoX" {

quietly {
	
	

keep if dist>=-`hTRl' & dist<= `hTRr' 




 qui: sum `Y'  if dist<0
 local nl=r(N)
 qui:  sum `Y'  if dist>=0
 local nr=r(N)
}
 local scale=`nr'/`nl'
 di "`scale'"
 rdplot `Y'  dist if dist>=-`hTRl' & dist<=`hTRr', binselect( qsmv)  p(1) h(`hTRl' `hTRr' ) kernel(triangular) covs(${X}) covs_eval(mean)    name(Lqsmv`Y', replace)  xline(0)  legend(off)   scale(1 `scale' ) graph_options(graphregion(color(white)) saving(GRAPH\GPH/${het}/${het}`Y'qsmv, replace))

graph export GRAPH\PNG/${het}/${het}`Y'qsmv.png, width(1000) replace
	 rdplot `Y'  dist if dist>=-`hTRl' & dist<=`hTRr', binselect( esmv)  p(1) h(`hTRl' `hTRr' ) kernel(triangular) covs(${X}) covs_eval(mean)    name(Lesmv`Y', replace)  xline(0)  legend(off)     scale(1 `scale') graph_options(graphregion(color(white)) saving(GRAPH\GPH/${het}/${het}`Y'esmv, replace))
graph export GRAPH\PNG/${het}/${het}`Y'esmv.png, width(1000) replace		

}




graph drop _all
}








	


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






foreach Y in    $Y       {		
    
	



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
replace `Y'_l="${locQ_`Y'}"  if _n==12
replace  `Y'_l="${N_`Y'}"  if _n==13
replace `Y'_l="${EffNh_`Y'}"  if _n==14
replace `Y'_l="${EffNb_`Y'}"  if _n==15




}
save ${het}.dta, replace
}