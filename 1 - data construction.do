

use  "S:\databases\1_Projets\CrossEUwork_Andrea_Albanese\marclondon\data\Person_Data.dta", clear 
gen OYSTER=ppoyster==1
gen OYSTER_Lweek=pluoys==1 if pluoys!=-2 &  pluoys!=-1 & pluoys!=.
gen OYSTER_Lmonth=pluoys==2 if pluoys!=-2 &  pluoys!=-1 & pluoys!=.
gen OYSTER_Lyear=pluoys==3 if pluoys!=-2 &  pluoys!=-1 & pluoys!=.
gen OYSTER_more=pluoys==4 if pluoys!=-2 &  pluoys!=-1 & pluoys!=.
gen OYSTER_NOHAVE=pluoys==5 if pluoys!=-2 &  pluoys!=-1 & pluoys!=.

gen anyTRAVElcard=ptcdur==1 | ptcdur==2 | ptcdur==3 | ptcdur==4 | ptcdur==5
gen buspassOYSTER=ppopmbus==1
gen buspassTRAVEL=ppopmtc==1
gen buspassSTAT=ppopmsss==1
gen cardANY=buspassOYSTER==1 | buspassTRAVEL==1  | buspassSTAT==1

tab anyTRAVElcard cardANY
gen noOYSTERtick=ppopmnone==1

gen mode_carDR=pwscard==1 
gen mode_carPASS=pwscarp==1 
gen mode_Acar=pwscarp==1  | pwscard==1
gen mode_moto=pwsmcr==1

gen mode_bike=pwscyc==1
gen mode_bus=pwsbus==1
gen mode_underover=pwsug==1 | pwsovg==1
gen mode_rail=pwsnr==1 | pwsdlr==1 |  pwstram==1
gen mode_taxi=pwstaxi==1
gen mode_walk=pwswalk==1

keep pdlcar pdlmc ppdlcar ppdlmc pdlpsv pdlhgv pdlnone pwsmmode ppopmnone pluoys ppopmsss ppopmtc ptcdur ppopmbus pwswalk pwstaxi pwsnr pwsdlr pwstram pwsovg pwsug pwscyc pwsmcr pwscarp pwscard pwscarp pwscard pewu poccupa pemplos pmanager pwkstat phid ppid pyearid OYSTER OYSTER_Lweek OYSTER_Lmonth OYSTER_Lyear OYSTER_more OYSTER_NOHAVE anyTRAVElcard buspassOYSTER buspassTRAVEL buspassSTAT cardANY noOYSTERtick mode_carDR mode_carPASS mode_Acar mode_moto mode_bike mode_bus mode_underover mode_rail mode_taxi mode_walk
rename phid  hid
rename ppid pid
rename pyearid yearid
sort hid pid yearid 
save  "S:\databases\1_Projets\CrossEUwork_Andrea_Albanese\marclondon\data\Person_Data_v2.dta", replace 






*1. merge original household data and Emma's data of the distance between home and the border of the charging zone
 
use "S:\databases\1_Projets\CrossEUwork_Andrea_Albanese\marclondon\data\household.dta", clear
format hhid %20.0f
sort hhid hyearid
save "S:\databases\1_Projets\CrossEUwork_Andrea_Albanese\marclondon\data\household2.dta", replace


*MODIFICATION WITH NEW DISTANCES: 07/10/2019
use "S:\databases\1_Projets\CrossEUwork_Andrea_Albanese\marclondon\data\newdistances08_10_19.dta",  clear

sort hid


rename hid hhid

format hhid %20.0f


merge 1:1 hhid  using "S:\databases\1_Projets\CrossEUwork_Andrea_Albanese\marclondon\data\household2.dta"
tab _merge
drop _merge

rename hhid hid
rename hyearid yearid

sort hid yearid

save "S:\databases\1_Projets\CrossEUwork_Andrea_Albanese\marclondon\data\house merged.dta", replace


*htdate only (used later to combine with trip data)

use "S:\databases\1_Projets\CrossEUwork_Andrea_Albanese\marclondon\data\house merged.dta", clear
keep hid htdate
sort hid
save "S:\databases\1_Projets\CrossEUwork_Andrea_Albanese\marclondon\data\house merged htdate.dta", replace




*2. merge household data and individual data

use "S:\databases\1_Projets\CrossEUwork_Andrea_Albanese\marclondon\data\person.dta", clear

rename phid hid
rename ppid pid
rename pyearid yearid

format hid pid %20.0f

sort hid pid 

save "S:\databases\1_Projets\CrossEUwork_Andrea_Albanese\marclondon\data\person2.dta", replace


use "S:\databases\1_Projets\CrossEUwork_Andrea_Albanese\marclondon\data\person travel.dta", clear

rename phid hid
rename ppid pid
rename pyearid yearid

format hid pid %20.0f

sort hid pid 

save "S:\databases\1_Projets\CrossEUwork_Andrea_Albanese\marclondon\data\person travel2.dta", replace

merge 1:1 hid pid using "S:\databases\1_Projets\CrossEUwork_Andrea_Albanese\marclondon\data\person2.dta"

drop _merge

sort hid pid

gen out=1 if pout==1
replace out=0 if pout==2

save "S:\databases\1_Projets\CrossEUwork_Andrea_Albanese\marclondon\data\person3.dta", replace


use "S:\databases\1_Projets\CrossEUwork_Andrea_Albanese\marclondon\data\person3.dta", replace





*2.2. merge workplace data (emma 2-12-2013) and person2
merge 1:1 hid pid using "S:\databases\1_Projets\CrossEUwork_Andrea_Albanese\marclondon\data\emma 2-12-2013.dta" 



replace workplaceinsidecentralzone=. if  pwsose==-1
replace workplaceinsidewesternextension=. if  pwsose==-1
gen unknownPLACEwork=1 if pwsose==-2
tab _merge 

drop _merge
sort hid pid yearid
 

*2.3. merge person2 and grid data (map segment IDs) (6-1-2014)

merge 1:1 hid pid using "S:\databases\1_Projets\CrossEUwork_Andrea_Albanese\marclondon\data\grid.dta" 

drop _merge

sort hid pid yearid

save "S:\databases\1_Projets\CrossEUwork_Andrea_Albanese\marclondon\data\person4.dta" , replace

*merge

merge m:1 hid yearid using "S:\databases\1_Projets\CrossEUwork_Andrea_Albanese\marclondon\data\house merged.dta"

drop _merge

*3. Outcome variables

*DUMMY

gen cycdum=1 if pfrcyc==1
replace cycdum=0 if cycdum!=1 & pfrcyc!=.

gen walkdum=1 if pfrwalk==1
replace walkdum=0 if walkdum!=1 & pfrwalk!=.


*FREQUENCY cycling and walking (active)

gen cyc=6 if pfrcyc==1
replace cyc=3.5 if pfrcyc==2
replace cyc=2 if pfrcyc==3
replace cyc=1 if pfrcyc==4
replace cyc=0.5 if pfrcyc==5
replace cyc=0.25 if pfrcyc==6
replace cyc=0.02 if pfrcyc==7
replace cyc=0 if pfrcyc==8 | pfrcyc==9

gen walk=6 if pfrwalk==1
replace walk=3.5 if pfrwalk==2
replace walk=2 if pfrwalk==3
replace walk=1 if pfrwalk==4
replace walk=0.5 if pfrwalk==5
replace walk=0.25 if pfrwalk==6
replace walk=0.02 if pfrwalk==7
replace walk=0 if pfrwalk==8 | pfrwalk==9

gen active=cyc+walk

replace active=5 if active>=5
replace active=3.5 if active>=3 & active<5
replace active=2 if active>=2 & active<3
replace active=1 if active>=1 & active<2
replace active=0.5 if active>=0.5 & active<1
replace active=0.25 if active>0.25 & active<0.5
replace active=0.02 if active>=0.02 & active<0.25
replace active=0 if active==0

*private car use

gen card=6 if pfrcard==1
replace card=3.5 if pfrcard==2
replace card=2 if pfrcard==3
replace card=1 if pfrcard==4
replace card=0.5 if pfrcard==5
replace card=0.25 if pfrcard==6
replace card=0.02 if pfrcard==7
replace card=0 if pfrcard==8 | pfrcard==9

gen carp=6 if pfrcarp==1
replace carp=3.5 if pfrcarp==2
replace carp=2 if pfrcarp==3
replace carp=1 if pfrcarp==4
replace carp=0.5 if pfrcarp==5
replace carp=0.25 if pfrcarp==6
replace carp=0.02 if pfrcarp==7
replace carp=0 if pfrcarp==8 | pfrcarp==9

gen car=card+carp

replace car=5 if car>=5
replace car=3.5 if car>=3 & car<5
replace car=2 if car>=2 & car<3
replace car=1 if car>=1 & car<2
replace car=0.5 if car>=0.5 & car<1
replace car=0.25 if car>0.25 & car<0.5
replace car=0.02 if car>=0.02 & car<0.25
replace car=0 if car==0


*public transportation

gen tram=6 if pfrtram==1
replace tram=3.5 if pfrtram==2
replace tram=2 if pfrtram==3
replace tram=1 if pfrtram==4
replace tram=0.5 if pfrtram==5
replace tram=0.25 if pfrtram==6
replace tram=0.02 if pfrtram==7
replace tram=0 if pfrtram==8 | pfrtram==9

gen bus=6 if pfrbus==1
replace bus=3.5 if pfrbus==2
replace bus=2 if pfrbus==3
replace bus=1 if pfrbus==4
replace bus=0.5 if pfrbus==5
replace bus=0.25 if pfrbus==6
replace bus=0.02 if pfrbus==7
replace bus=0 if pfrbus==8 | pfrbus==9

gen dlr=6 if pfrdlr==1
replace dlr=3.5 if pfrdlr==2
replace dlr=2 if pfrdlr==3
replace dlr=1 if pfrdlr==4
replace dlr=0.5 if pfrdlr==5
replace dlr=0.25 if pfrdlr==6
replace dlr=0.02 if pfrdlr==7
replace dlr=0 if pfrdlr==8 | pfrdlr==9

gen ug=6 if pfrug==1
replace ug=3.5 if pfrug==2
replace ug=2 if pfrug==3
replace ug=1 if pfrug==4
replace ug=0.5 if pfrug==5
replace ug=0.25 if pfrug==6
replace ug=0.02 if pfrug==7
replace ug=0 if pfrug==8 | pfrug==9

gen ovg=6 if pfrovg==1
replace ovg=3.5 if pfrovg==2
replace ovg=2 if pfrovg==3
replace ovg=1 if pfrovg==4
replace ovg=0.5 if pfrovg==5
replace ovg=0.25 if pfrovg==6
replace ovg=0.02 if pfrovg==7
replace ovg=0 if pfrovg==8 | pfrovg==9

gen nr=6 if pfrnr==1
replace nr=3.5 if pfrnr==2
replace nr=2 if pfrnr==3
replace nr=1 if pfrnr==4
replace nr=0.5 if pfrnr==5
replace nr=0.25 if pfrnr==6
replace nr=0.02 if pfrnr==7
replace nr=0 if pfrnr==8 | pfrnr==9

gen public=tram+bus+dlr+ug+ovg+nr

replace public=5 if public>=5
replace public=3.5 if public>=3 & public<5
replace public=2 if public>=2 & public<3
replace public=1 if public>=1 & public<2
replace public=0.5 if public>=0.5 & public<1
replace public=0.25 if public>0.25 & public<0.5
replace public=0.02 if public>=0.02 & public<0.25
replace public=0 if public==0




*Health

gen healthprob=1 if pltpmd==1
replace healthprob=0 if pltpmd==2





*4. Household tenure (the data you started to live in current home)

*htdate (survey date)

format htdate %20.0f

*year
gen tenure=htdate
replace tenure=tenure-(htenurey*10000)

*month and day
gen tenure2 = tenure/10000
replace tenure2=floor(tenure2)
replace tenure2=tenure2*10000

format tenure tenure2 %12.0f

gen tenure3=tenure-tenure2

gen htenurem2=htenurem*100

gen tenure4=tenure3/100
replace tenure4=floor(tenure4)

replace tenure4=tenure4*100
gen tenure5=tenure3-tenure4

gen diff=htenurem2-tenure4
replace diff=. if diff<0

gen diff2=1200-diff

replace tenure2=tenure2-10000 if tenure4<htenurem2
replace tenure4=diff2 if tenure4<htenurem2

replace tenure4=tenure4-htenurem2 if tenure4>=htenurem2 

gen tenure6=tenure2+tenure4+tenure5
format tenure6 %12.0f

replace tenure=tenure6

drop  tenure2 tenure3 htenurem2 tenure4 tenure5 diff diff2 tenure6





*Start to live after the implementation of the charge (20-01-2014)

gen immigrant=1 if tenure>=20030217
replace immigrant=0 if immigrant!=1 & tenure!=.

gen immigrant2=1 if tenure>=20070219 & htdate>=20070219 & htdate<=20101224 
replace immigrant2=0 if immigrant!=1 & tenure!=. & htdate>=20070219 & htdate<=20101224 

gen immigrant3=1 if tenure>=20101225 & htdate>=20101225 
replace immigrant3=0 if immigrant!=1 & tenure!=. & htdate>=20101225
 



*working or studying in the charging zone

gen workin=1 if workplaceinsidecentralzone==1
replace workin=1 if workplaceinsidewesternextension==1 & htdate>=20070219 & htdate<=20101224
replace workin=0 if workin!=1 & workplaceinsidecentralzone!=. 


*living in the charging zone

gen homein=1 if distanceinkmtothecentralzone<0
replace homein=1 if distanceinkmtothewesternextensio<0 & htdate>=20070219 & htdate<=20101224
replace homein=0 if homein!=1 & distanceinkmtothecentralzone!=. 



*Cross the border (20-01-2013)

gen homeinworkin=1 if distanceinkmtothecentralzone<0 & workplaceinsidecentralzone==1
replace homeinworkin=1 if distanceinkmtothewesternextensio<0 & workplaceinsidewesternextension==1 & htdate>=20070219 & htdate<=20101224
replace homeinworkin=0 if homeinworkin!=1 & distanceinkmtothecentralzone!=. 

gen homeinworkout=1 if distanceinkmtothecentralzone<0 & workplaceinsidecentralzone==0
replace homeinworkout=1 if distanceinkmtothewesternextensio<0 & workplaceinsidewesternextension==0 & htdate>=20070219 & htdate<=20101224
replace homeinworkout=0 if homeinworkout!=1 & distanceinkmtothecentralzone!=. 

gen homeoutworkin=1 if distanceinkmtothecentralzone>0 & workplaceinsidecentralzone==1
replace homeoutworkin=1 if distanceinkmtothewesternextensio>0 & workplaceinsidewesternextension==1 & htdate>=20070219 & htdate<=20101224
replace homeoutworkin=0 if homeoutworkin!=1 & distanceinkmtothecentralzone!=. 

gen homeoutworkout=1 if distanceinkmtothecentralzone>0 & workplaceinsidecentralzone==0
replace homeoutworkout=1 if distanceinkmtothewesternextensio>0 & workplaceinsidewesternextension==0 & htdate>=20070219 & htdate<=20101224
replace homeoutworkout=0 if homeoutworkout!=1 & distanceinkmtothecentralzone!=. 






*5. Assignment (Forcing) variable

*NotE: the original congestion charge was implementer on 20030201, the western extension was implemented on 20070219 and ended on 20101224.
cap: drop dist OLDdist

*07/10/2019: MODIFICATION WITH NEW DISTANCES

*new definition (adapted to new variables)
gen dist=distanceinkmtothecentralzone
*during expansion - middle border does not matter -> only 
replace dist=distanceinkmtothecentreORwest if (htdate>=20070219 & htdate<=20101224) 








*6. Weekend dummy

gen weekend=1 if htdow==6 | htdow==7    //saturday and sunday

replace weekend=1 if htdate>=20051225 & htdate<=20060101 //christmas & new year
replace weekend=1 if htdate>=20061225 & htdate<=20070101
replace weekend=1 if htdate>=20071225 & htdate<=20080101
replace weekend=1 if htdate>=20081225 & htdate<=20090101
replace weekend=1 if htdate>=20091225 & htdate<=20100101
replace weekend=1 if htdate>=20101225 & htdate<=20110101
replace weekend=1 if htdate>=20111225 & htdate<=20120101

replace weekend=1 if htdate==20050103 //bank holiday
replace weekend=1 if htdate==20050325
replace weekend=1 if htdate==20050328
replace weekend=1 if htdate==20050502
replace weekend=1 if htdate==20050530
replace weekend=1 if htdate==20050829

replace weekend=1 if htdate==20060102
replace weekend=1 if htdate==20060414
replace weekend=1 if htdate==20060417
replace weekend=1 if htdate==20060501
replace weekend=1 if htdate==20060529
replace weekend=1 if htdate==20060828

replace weekend=1 if htdate==20070406
replace weekend=1 if htdate==20070409
replace weekend=1 if htdate==20070507
replace weekend=1 if htdate==20070528
replace weekend=1 if htdate==20070827

replace weekend=1 if htdate==20080321
replace weekend=1 if htdate==20080324
replace weekend=1 if htdate==20080505
replace weekend=1 if htdate==20080526
replace weekend=1 if htdate==20080825

replace weekend=1 if htdate==20090410
replace weekend=1 if htdate==20090413
replace weekend=1 if htdate==20090504
replace weekend=1 if htdate==20090525
replace weekend=1 if htdate==20090831

replace weekend=1 if htdate==20100402
replace weekend=1 if htdate==20100405
replace weekend=1 if htdate==20100503
replace weekend=1 if htdate==20100531
replace weekend=1 if htdate==20100830

replace weekend=1 if htdate==20110103
replace weekend=1 if htdate==20110422
replace weekend=1 if htdate==20110425
replace weekend=1 if htdate==20110429
replace weekend=1 if htdate==20110502
replace weekend=1 if htdate==20110530
replace weekend=1 if htdate==20110829

replace weekend=1 if htdate==20120102
replace weekend=1 if htdate==20120406
replace weekend=1 if htdate==20120409
replace weekend=1 if htdate==20120507
replace weekend=1 if htdate==20120604
replace weekend=1 if htdate==20120605
replace weekend=1 if htdate==20120827

replace weekend=0 if weekend!=1 & htdate!=.


format hid pid %20.0f

sort pid

save "S:\databases\1_Projets\CrossEUwork_Andrea_Albanese\marclondon\data\individual.dta", replace





use "S:\databases\1_Projets\CrossEUwork_Andrea_Albanese\marclondon\data\individual.dta", clear




keep hid pid pwspcout pwspcin hhpcout hhpcin htdate

save "S:\databases\1_Projets\CrossEUwork_Andrea_Albanese\marclondon\data\individual for trip.dta", replace










*Trip data

use "S:\databases\1_Projets\CrossEUwork_Andrea_Albanese\marclondon\data\trip.dta", clear

format thid tpid ttid %20.0f

rename thid hid 
rename tpid pid
rename ttid tid

sort hid pid tid


merge m:1 hid pid using "S:\databases\1_Projets\CrossEUwork_Andrea_Albanese\marclondon\data\individual for trip.dta"
drop _merge

keep if tid!=.

format htdate %20.0f





gen ho=.
replace ho=1 if hhpcout==topcout & hhpcin==topcin
gen wi=.
replace wi=1 if pwspcout==tdpcout & pwspcin==tdpcin
gen howi=1 if ho==1 & wi==1

gen hi=.
replace hi=1 if hhpcout==tdpcout & hhpcin==tdpcin
gen wo=.
replace wo=1 if pwspcout==topcout & pwspcin==topcin
gen hiwo=1 if hi==1 & wo==1

gen worktrip=1 if howi==1 | hiwo==1
replace worktrip=0 if worktrip!=1 & topcout!="-1"






sort hid pid tid





*Crossing the border (30-01-2014)







save "S:\databases\1_Projets\CrossEUwork_Andrea_Albanese\marclondon\data\trip2.dta", replace



*Construction of detailed outcome variables using stage data (15-11-2013)

*NOTE: TRIP AND STAGE INFORMATION IS NOT AVAILABLE FOR THOSE WHO DID NOT MAKE ANY TRIP ON THE SURVEY DATE. (the London Travel Demand Survey (LTDS) which uses a one day travel diary to collect information about all trips for the day prior to the interview day.)

use "S:\databases\1_Projets\CrossEUwork_Andrea_Albanese\marclondon\data\stage.dta", clear

format shid spid stid ssid %20.0f


*24 outcome variables

replace smode=. if smode==-2

*drop negative values
replace slenn=. if slenn<0
replace sdurn=. if sdurn<0

*distance
forvalues j=1/24{
gen d`j'=0
}

forvalues j=1/24{
replace d`j'=slenn if smode==`j'
}

forvalues j=1/24{
bysort stid: egen distance`j'=sum(d`j') 
}

forvalues j=1/24{
drop d`j'
}

*duration
forvalues j=1/24{
gen d`j'=0
}

forvalues j=1/24{
replace d`j'=sdurn if smode==`j'
}

forvalues j=1/24{
bysort stid: egen duration`j'=sum(d`j') 
}

forvalues j=1/24{
drop d`j'
}








bysort stid: gen id=_n
keep if id==1
drop id

#delimit;

keep shid spid stid ssid syearid distance1 distance2 distance3 distance4 

distance1 distance2 distance3 distance4 distance5 distance6 distance7 distance8 distance9 distance10  
distance11 distance12 distance13 distance14 distance15 distance16 distance17 distance18 distance19 distance20 
distance21 distance22 distance23 distance24

duration1 duration2 duration3 duration4 duration5 duration6 duration7 duration8 duration9 duration10 
duration11 duration12 duration13 duration14 duration15 duration16 duration17 duration18 duration19 duration20 
duration21 duration22 duration23 duration24; 

#delimit cr

rename shid hid 
rename spid pid
rename stid tid

sort hid pid tid


*Merge 
merge 1:1 hid pid tid using "S:\databases\1_Projets\CrossEUwork_Andrea_Albanese\marclondon\data\trip2.dta"
drop _merge


gen dirZONE=tdccz==1 | (tdwez==1 & htdate>=20070219 & htdate<=20101224)

 gen nonzero=1 if tetime>=700 & ( (tstime<1830 & htdate<20070201) | (tstime<1800 & htdate>=20070201))
replace nonzero=0 if nonzero==.
order tt1fhm

 
forvalues j=1/24{
	gen duration`j'_CENTRE=duration`j'*dirZONE
	gen distance`j'_CENTRE=distance`j'*dirZONE
}
 
 forvalues j=1/24{
	gen duration`j'_NONZERO=duration`j'*nonzero
	gen distance`j'_NONZERO=distance`j'*nonzero
}

 forvalues j=1/24{
	gen duration`j'_ZERO=duration`j'*(nonzero==0)
	gen distance`j'_ZERO=distance`j'*(nonzero==0)
}

forvalues j=1/24{
	gen duration`j'_CENONZERO=duration`j'*dirZONE*nonzero
	gen distance`j'_CENONZERO=distance`j'*dirZONE*nonzero
}


*total distance and duration by travel mode


forvalues j=1/24{
bysort pid: egen tdistance`j'=sum(distance`j')
}

forvalues j=1/24{
bysort pid: egen tduration`j'=sum(duration`j')
}


forvalues j=1/24{
bysort pid: egen tdistance`j'_CENTRE=sum(distance`j'_CENTRE)
}

forvalues j=1/24{
bysort pid: egen tduration`j'_CENTRE=sum(duration`j'_CENTRE)
}


forvalues j=1/24{
bysort pid: egen tdistance`j'_NONZERO=sum(distance`j'_NONZERO)
}

forvalues j=1/24{
bysort pid: egen tduration`j'_NONZERO=sum(duration`j'_NONZERO)
}

forvalues j=1/24{
bysort pid: egen tdistance`j'_ZERO=sum(distance`j'_ZERO)
}

forvalues j=1/24{
bysort pid: egen tduration`j'_ZERO=sum(duration`j'_ZERO)
}

forvalues j=1/24{
bysort pid: egen tdistance`j'_CENONZERO=sum(distance`j'_CENONZERO)
}

forvalues j=1/24{
bysort pid: egen tduration`j'_CENONZERO=sum(duration`j'_CENONZERO)
}

*total travel

bysort pid: gen tdistance_all=tdistance1+tdistance2+tdistance3+tdistance4+tdistance5+tdistance6+tdistance7+tdistance8+tdistance9+tdistance10+tdistance11+tdistance12+tdistance13+tdistance14+tdistance15+tdistance16+tdistance17+tdistance18+tdistance19+tdistance20+tdistance21+tdistance22+tdistance23+tdistance24
gen ln_tdistance_all=ln(tdistance_all+1)
bysort pid: gen tduration_all=tduration1+tduration2+tduration3+tduration4+tduration5+tduration6+tduration7+tduration8+tduration9+tduration10+tduration11+tduration12+tduration13+tduration14+tduration15+tduration16+tduration17+tduration18+tduration19+tduration20+tduration21+tduration22+tduration23+tduration24
gen ln_tduration_all=ln(tduration_all+1)


*cycling and walking (active)

bysort pid: gen tdistance_active=tdistance1+tdistance2
bysort pid: gen tduration_active=tduration1+tduration2

bysort pid: gen tdistance_active_CENTRE=tdistance1_CENTRE+tdistance2_CENTRE
bysort pid: gen tduration_active_CENTRE=tduration1_CENTRE+tduration2_CENTRE

bysort pid: gen tdistance_active_NONZERO=tdistance1_NONZERO+tdistance2_NONZERO
bysort pid: gen tduration_active_NONZERO=tduration1_NONZERO+tduration2_NONZERO

bysort pid: gen tdistance_active_ZERO=tdistance1_ZERO+tdistance2_ZERO
bysort pid: gen tduration_active_ZERO=tduration1_ZERO+tduration2_ZERO

bysort pid: gen tdistance_active_CENONZERO=tdistance1_CENONZERO+tdistance2_CENONZERO
bysort pid: gen tduration_active_CENONZERO=tduration1_CENONZERO+tduration2_CENONZERO



gen ln_tdistance_active=ln(tdistance_active+1)
gen ln_tdistance_walk=ln(tdistance1+1)
gen ln_tdistance_cyc=ln(tdistance2+1)
gen ln_tduration_active=ln(tduration_active+1)
gen ln_tduration_walk=ln(tduration1+1)
gen ln_tduration_cyc=ln(tduration2+1)



*Car (including motorcycle, van, taxi, dial-a-ride, plane/boat/other)
bysort pid: gen tdistance_car=tdistance3+tdistance4+tdistance9+tdistance10+tdistance11+tdistance12
bysort pid: gen tduration_car=tduration3+tduration4+tduration9+tduration10+tduration11+tduration12

bysort pid: gen tdistance_car_CENTRE=tdistance3_CENTRE+tdistance4_CENTRE+tdistance9_CENTRE+tdistance10_CENTRE+tdistance11_CENTRE+tdistance12_CENTRE
bysort pid: gen tduration_car_CENTRE=tduration3_CENTRE+tduration4_CENTRE+tduration9_CENTRE+tduration10_CENTRE+tduration11_CENTRE+tduration12_CENTRE


bysort pid: gen tdistance_car_CENONZERO=tdistance3_CENONZERO+tdistance4_CENONZERO+tdistance9_CENONZERO+tdistance10_CENONZERO+tdistance11_CENONZERO+tdistance12_CENONZERO
bysort pid: gen tduration_car_CENONZERO=tduration3_CENONZERO+tduration4_CENONZERO+tduration9_CENONZERO+tduration10_CENONZERO+tduration11_CENONZERO+tduration12_CENONZERO

bysort pid: gen tdistance_car_NONZERO=tdistance3_NONZERO+tdistance4_NONZERO+tdistance9_NONZERO+tdistance10_NONZERO+tdistance11_NONZERO+tdistance12_NONZERO
bysort pid: gen tduration_car_NONZERO=tduration3_NONZERO+tduration4_NONZERO+tduration9_NONZERO+tduration10_NONZERO+tduration11_NONZERO+tduration12_NONZERO

bysort pid: gen tdistance_car_ZERO=tdistance3_ZERO+tdistance4_ZERO+tdistance9_ZERO+tdistance10_ZERO+tdistance11_ZERO+tdistance12_ZERO
bysort pid: gen tduration_car_ZERO=tduration3_ZERO+tduration4_ZERO+tduration9_ZERO+tduration10_ZERO+tduration11_ZERO+tduration12_ZERO

gen ln_tdistance_car=ln(tdistance_car+1)
gen ln_tduration_car=ln(tduration_car+1)

bysort pid: gen tdistance_onlycar=tdistance3+tdistance4
bysort pid: gen tduration_onlycar=tduration3+tduration4
gen ln_tdistance_onlycar=ln(tdistance_onlycar+1)
gen ln_tduration_onlycar=ln(tduration_onlycar+1)

*Public   

bysort pid: gen tdistance_public=tdistance13+tdistance14+tdistance16+tdistance17+tdistance18+tdistance19+tdistance20+tdistance24
bysort pid: gen tduration_public=tduration13+tduration14+tduration16+tduration17+tduration18+tduration19+tduration20+tduration24
gen ln_tdistance_public=ln(tdistance_public+1)
gen ln_tduration_public=ln(tduration_public+1)

*Other (motorcycle, taxi, dial a ride, plane/boad/other)

bysort pid: gen tdistance_other=tdistance5+tdistance6+tdistance15+tdistance21+tdistance22+tdistance23
bysort pid: gen tduration_other=tduration5+tduration6+tduration15+tduration21+tduration22+tduration23



















*FOR EACH TRIP, total distance and duration by travel mode if worktrip==1 (BYSORT TID, NOT PID) (8-2-2014)

forvalues j=1/24{
bysort tid: egen tid_tdistance`j'=sum(distance`j')
}

forvalues j=1/24{
bysort tid: egen tid_tduration`j'=sum(duration`j')
}






*total travel by trip (8-2-2014)

bysort tid: gen tid_tdistance_all=tid_tdistance1+tid_tdistance2+tid_tdistance3+tid_tdistance4+tid_tdistance5+tid_tdistance6+tid_tdistance7+tid_tdistance8+tid_tdistance9+tid_tdistance10+tid_tdistance11+tid_tdistance12+tid_tdistance13+tid_tdistance14+tid_tdistance15+tid_tdistance16+tid_tdistance17+tid_tdistance18+tid_tdistance19+tid_tdistance20+tid_tdistance21+tid_tdistance22+tid_tdistance23+tid_tdistance24
bysort pid: egen tid_tdistance_all_worktrip=mean(tid_tdistance_all) if worktrip==1
bysort pid: egen tdistance_all_worktrip=max(tid_tdistance_all_worktrip)

bysort tid: gen tid_tduration_all=tid_tduration1+tid_tduration2+tid_tduration3+tid_tduration4+tid_tduration5+tid_tduration6+tid_tduration7+tid_tduration8+tid_tduration9+tid_tduration10+tid_tduration11+tid_tduration12+tid_tduration13+tid_tduration14+tid_tduration15+tid_tduration16+tid_tduration17+tid_tduration18+tid_tduration19+tid_tduration20+tid_tduration21+tid_tduration22+tid_tduration23+tid_tduration24
bysort pid: egen tid_tduration_all_worktrip=mean(tid_tduration_all) if worktrip==1
bysort pid: egen tduration_all_worktrip=max(tid_tduration_all_worktrip)

*cycling and walking (8-2-2014)

bysort tid: gen tid_tdistance_active=tid_tdistance1+tid_tdistance2
bysort pid: egen tid_tdistance_active_worktrip=mean(tid_tdistance_active) if worktrip==1
bysort pid: egen tdistance_active_worktrip=max(tid_tdistance_active_worktrip)

bysort tid: gen tid_tduration_active=tid_tduration1+tid_tduration2
bysort pid: egen tid_tduration_active_worktrip=mean(tid_tduration_active) if worktrip==1
bysort pid: egen tduration_active_worktrip=max(tid_tduration_active_worktrip)

gen ln_tdistance_active_worktrip=ln(tdistance_active_worktrip+1)
gen ln_tduration_active_worktrip=ln(tduration_active_worktrip+1)

*car by tid (8-2-2014)

bysort tid: gen tid_tdistance_car=tid_tdistance3+tid_tdistance4+tid_tdistance9+tid_tdistance10+tid_tdistance11+tid_tdistance12
bysort pid: egen tid_tdistance_car_worktrip=mean(tid_tdistance_car) if worktrip==1
bysort pid: egen tdistance_car_worktrip=max(tid_tdistance_car_worktrip)

bysort tid: gen tid_tduration_car=tid_tduration3+tid_tduration4+tid_tduration9+tid_tduration10+tid_tduration11+tid_tduration12
bysort pid: egen tid_tduration_car_worktrip=mean(tid_tduration_car) if worktrip==1
bysort pid: egen tduration_car_worktrip=max(tid_tduration_car_worktrip)

gen ln_tdistance_car_worktrip=ln(tdistance_car_worktrip+1)
gen ln_tduration_car_worktrip=ln(tduration_car_worktrip+1)


bysort tid: gen tid_tdistance_onlycar=tid_tdistance3+tid_tdistance4
bysort pid: egen tid_tdistance_onlycar_worktrip=mean(tid_tdistance_onlycar) if worktrip==1
bysort pid: egen tdistance_onlycar_worktrip=max(tid_tdistance_onlycar_worktrip)

bysort tid: gen tid_tduration_onlycar=tid_tduration3+tid_tduration4
bysort pid: egen tid_tduration_onlycar_worktrip=mean(tid_tduration_onlycar) if worktrip==1
bysort pid: egen tduration_onlycar_worktrip=max(tid_tduration_onlycar_worktrip)


gen ln_tdistance_onlycar_worktrip=ln(tdistance_onlycar_worktrip+1)
gen ln_tduration_onlycar_worktrip=ln(tduration_onlycar_worktrip+1)






*Charge time travel (17-11-2013)

gen ctt=1 if tstime<=700 & htdate<20070219
replace ctt=1 if tstime>=1830 & htdate<20070219

replace ctt=1 if tstime<=700 & htdate>=20070219
replace ctt=1 if tstime>=1800 & htdate>=20070219
 
replace ctt=0 if ctt!=1 & tstime!=.


*CTT==1 in any one of trips is made during the charge time

bysort pid: egen anyctt=max(ctt) 

*anyctt in worktrip (8-2-2014)

bysort pid: egen anyctt_w=max(ctt) if worktrip==1
bysort pid: egen anyctt_worktrip=max(anyctt_w)
drop anyctt_w













*Converting to individual-level data

bysort pid: gen id=_n

keep if id==1
drop id

rename syearid yearid

sort hid pid yearid

merge 1:1 hid pid yearid using "S:\databases\1_Projets\CrossEUwork_Andrea_Albanese\marclondon\data\individual.dta" 





foreach var in tduration1 tduration2 tduration_all tduration_active tduration_car tduration_onlycar tduration_public tduration_other tduration_all_worktrip tduration_active_worktrip tduration_car_worktrip tduration_onlycar_worktrip {
replace `var'=0 if _merge==2
cap: replace ln_`var'=0 if _merge==2

}

foreach var in tdistance1 tdistance2 tdistance_all tdistance_active tdistance_car tdistance_onlycar tdistance_public tdistance_other tdistance_all_worktrip tdistance_active_worktrip tdistance_car_worktrip tdistance_onlycar_worktrip {
replace `var'=0 if _merge==2
cap: replace ln_`var'=0 if _merge==2

}
drop _merge




*Some control variables (30-01-2014)

*household size

gen housesize=hpeoplen

*number of cars available on the travel day

gen numcar=hcvln
replace numcar=. if numcar==-1

*household income

gen income=hincomei // notE: imputated income, raw income is "hincome". 

*gender

gen female=1 if psexi==2
replace female=0 if psexi==1

*age

gen age=pagei

*ethnic group

replace pegroup=. if pegroup==-1 | pegroup==-2 | pegroup==20
egen ethnicity = group(pegroup)

*distance between home and work/education place

gen distance_hwe=plenn
replace distance_hwe=. if distance_hwe<0


*car owner


gen carown=1 if numcar>0
replace carown=0 if numcar==0







*Charging time variable

gen charge5pound=1 if htdate<20050704
replace charge5pound=0 if charge5pound!=1 & htdate!=.

gen charge8pound=1 if htdate>=20050704 & htdate<20110104
replace charge8pound=0 if charge8pound!=1 & htdate!=.

gen charge10pound=1 if htdate>=20110104
replace charge10pound=0 if charge10pound!=1 & htdate!=.



*charging time date

gen until1830=1 if htdate<20070219
replace until1830=0 if htdate>=20070219

gen until1800=1 if htdate>=20070219
replace until1800=0 if until1800!=1 & htdate!=.


*western extension related period variables

gen wezperiod1=1 if htdate<20070219
replace wezperiod1=0 if wezperiod1!=1 & htdate!=.

gen wezperiod2=1 if htdate>=20070219 & htdate<=20101224
replace wezperiod2=0 if wezperiod2!=1 & htdate!=.

gen wezperiod3=1 if htdate>=20101224 
replace wezperiod3=0 if wezperiod3!=1 & htdate!=.




sort hid pid yearid

save "S:\databases\1_Projets\CrossEUwork_Andrea_Albanese\marclondon\data\individual.dta", replace



use "S:\databases\1_Projets\CrossEUwork_Andrea_Albanese\marclondon\data\individual.dta", replace









*treatment variable
gen treat=1 if dist>=0
replace treat=0 if dist<0




*ANDREA: MODIFICATION 08_10_2019
*add new outcomes
sort hid pid yearid
merge hid pid yearid using "S:\databases\1_Projets\CrossEUwork_Andrea_Albanese\marclondon\data\Person_Data_v2.dta", update replace
tab _merge
drop if _merge==2
drop _merge
drop if hid==.





*drop incosistent date of travel
tostring htdate, gen(strDATE)
gen YEAR=substr(strDATE, 1, 4)
gen MONTH=substr(strDATE, 5, 2)
tab MONTH
tab YEAR, m
destring YEAR, replace
*drop incosistency 
tab workplaceinsidecentralzone, m
gen tdistance_rest_CENTRE=0-tdistance_active_CENTRE-tdistance_car_CENTRE
gen tduration_rest_CENTRE=0-tduration_active_CENTRE-tduration_car_CENTRE


gen tdistance_rest_NONZERO=0-tdistance_active_NONZERO-tdistance_car_NONZERO
gen tduration_rest_NONZERO=0-tduration_active_NONZERO-tduration_car_NONZERO

gen tdistance_rest_ZERO=0-tdistance_active_ZERO-tdistance_car_ZERO
gen tduration_rest_ZERO=0-tduration_active_ZERO-tduration_car_ZERO

gen tdistance_rest_CENONZERO=0-tdistance_active_CENONZERO-tdistance_car_CENONZERO
gen tduration_rest_CENONZERO=0-tduration_active_CENONZERO-tduration_car_CENONZERO

forvalues j=1(1)24 {
	replace tdistance_rest_NONZERO=tdistance_rest_NONZERO+tdistance`j'_NONZERO
	replace tduration_rest_NONZERO=tduration_rest_NONZERO+tduration`j'_NONZERO
	
		replace tdistance_rest_ZERO=tdistance_rest_ZERO+tdistance`j'_ZERO
	replace tduration_rest_ZERO=tduration_rest_ZERO+tduration`j'_ZERO
	

		replace tdistance_rest_CENONZERO=tdistance_rest_CENONZERO+tdistance`j'_CENONZERO
	replace tduration_rest_CENONZERO=tduration_rest_CENONZERO+tduration`j'_CENONZERO
	replace tdistance_rest_CENTRE=tdistance_rest_CENTRE+tdistance`j'_CENTRE
	replace tduration_rest_CENTRE=tduration_rest_CENTRE+tduration`j'_CENTRE
	
}
replace tdistance_rest_NONZERO=0 if tdistance_rest_NONZERO<.0000143
replace tdistance_rest_CENONZERO=0 if tdistance_rest_CENONZERO< .014
replace tdistance_rest_ZERO=0 if tdistance_rest_ZERO<.001
replace tdistance_rest_CENTRE=0 if tdistance_rest_CENTRE< .014
replace tduration_rest_CENTRE=0 if tduration_rest_CENTRE< .014



drop tdistance1_CENTRE tdistance2_CENTRE tdistance3_CENTRE tdistance4_CENTRE tdistance5_CENTRE tdistance6_CENTRE tdistance7_CENTRE tdistance8_CENTRE tdistance9_CENTRE tdistance10_CENTRE tdistance11_CENTRE tdistance12_CENTRE tdistance13_CENTRE tdistance14_CENTRE tdistance15_CENTRE tdistance16_CENTRE tdistance17_CENTRE tdistance18_CENTRE tdistance19_CENTRE tdistance20_CENTRE tdistance21_CENTRE tdistance22_CENTRE tdistance23_CENTRE tdistance24_CENTRE tduration1_CENTRE tduration2_CENTRE tduration3_CENTRE tduration4_CENTRE tduration5_CENTRE tduration6_CENTRE tduration7_CENTRE tduration8_CENTRE tduration9_CENTRE tduration10_CENTRE tduration11_CENTRE tduration12_CENTRE tduration13_CENTRE tduration14_CENTRE tduration15_CENTRE tduration16_CENTRE tduration17_CENTRE tduration18_CENTRE tduration19_CENTRE tduration20_CENTRE tduration21_CENTRE tduration22_CENTRE tduration23_CENTRE tduration24_CENTRE
drop tdistance_active_CENTRE   tduration_car_CENTRE
drop duration1_CENTRE distance1_CENTRE duration2_CENTRE distance2_CENTRE duration3_CENTRE distance3_CENTRE duration4_CENTRE distance4_CENTRE duration5_CENTRE distance5_CENTRE duration6_CENTRE distance6_CENTRE duration7_CENTRE distance7_CENTRE duration8_CENTRE distance8_CENTRE duration9_CENTRE distance9_CENTRE duration10_CENTRE distance10_CENTRE duration11_CENTRE distance11_CENTRE duration12_CENTRE distance12_CENTRE duration13_CENTRE distance13_CENTRE duration14_CENTRE distance14_CENTRE duration15_CENTRE distance15_CENTRE duration16_CENTRE distance16_CENTRE duration17_CENTRE distance17_CENTRE duration18_CENTRE distance18_CENTRE duration19_CENTRE distance19_CENTRE duration20_CENTRE distance20_CENTRE duration21_CENTRE distance21_CENTRE duration22_CENTRE distance22_CENTRE duration23_CENTRE distance23_CENTRE duration24_CENTRE distance24_CENTRE

drop duration1_NONZERO distance1_NONZERO duration2_NONZERO distance2_NONZERO duration3_NONZERO distance3_NONZERO duration4_NONZERO distance4_NONZERO duration5_NONZERO distance5_NONZERO duration6_NONZERO distance6_NONZERO duration7_NONZERO distance7_NONZERO duration8_NONZERO distance8_NONZERO duration9_NONZERO distance9_NONZERO duration10_NONZERO distance10_NONZERO duration11_NONZERO distance11_NONZERO duration12_NONZERO distance12_NONZERO duration13_NONZERO distance13_NONZERO duration14_NONZERO distance14_NONZERO duration15_NONZERO distance15_NONZERO duration16_NONZERO distance16_NONZERO duration17_NONZERO distance17_NONZERO duration18_NONZERO distance18_NONZERO duration19_NONZERO distance19_NONZERO duration20_NONZERO distance20_NONZERO duration21_NONZERO distance21_NONZERO duration22_NONZERO distance22_NONZERO duration23_NONZERO distance23_NONZERO duration24_NONZERO distance24_NONZERO duration1_ZERO distance1_ZERO duration2_ZERO distance2_ZERO duration3_ZERO distance3_ZERO duration4_ZERO distance4_ZERO duration5_ZERO distance5_ZERO duration6_ZERO distance6_ZERO duration7_ZERO distance7_ZERO duration8_ZERO distance8_ZERO duration9_ZERO distance9_ZERO duration10_ZERO distance10_ZERO duration11_ZERO distance11_ZERO duration12_ZERO distance12_ZERO duration13_ZERO distance13_ZERO duration14_ZERO distance14_ZERO duration15_ZERO distance15_ZERO duration16_ZERO distance16_ZERO duration17_ZERO distance17_ZERO duration18_ZERO distance18_ZERO duration19_ZERO distance19_ZERO duration20_ZERO distance20_ZERO duration21_ZERO distance21_ZERO duration22_ZERO distance22_ZERO duration23_ZERO distance23_ZERO duration24_ZERO distance24_ZERO tdistance1_NONZERO tdistance2_NONZERO tdistance3_NONZERO tdistance4_NONZERO tdistance5_NONZERO tdistance6_NONZERO tdistance7_NONZERO tdistance8_NONZERO tdistance9_NONZERO tdistance10_NONZERO tdistance11_NONZERO tdistance12_NONZERO tdistance13_NONZERO tdistance14_NONZERO tdistance15_NONZERO tdistance16_NONZERO tdistance17_NONZERO tdistance18_NONZERO tdistance19_NONZERO tdistance20_NONZERO tdistance21_NONZERO tdistance22_NONZERO tdistance23_NONZERO tdistance24_NONZERO tduration1_NONZERO tduration2_NONZERO tduration3_NONZERO tduration4_NONZERO tduration5_NONZERO tduration6_NONZERO tduration7_NONZERO tduration8_NONZERO tduration9_NONZERO tduration10_NONZERO tduration11_NONZERO tduration12_NONZERO tduration13_NONZERO tduration14_NONZERO tduration15_NONZERO tduration16_NONZERO tduration17_NONZERO tduration18_NONZERO tduration19_NONZERO tduration20_NONZERO tduration21_NONZERO tduration22_NONZERO tduration23_NONZERO tduration24_NONZERO tdistance1_ZERO tdistance2_ZERO tdistance3_ZERO tdistance4_ZERO tdistance5_ZERO tdistance6_ZERO tdistance7_ZERO tdistance8_ZERO tdistance9_ZERO tdistance10_ZERO tdistance11_ZERO tdistance12_ZERO tdistance13_ZERO tdistance14_ZERO tdistance15_ZERO tdistance16_ZERO tdistance17_ZERO tdistance18_ZERO tdistance19_ZERO tdistance20_ZERO tdistance21_ZERO tdistance22_ZERO tdistance23_ZERO tdistance24_ZERO tduration1_ZERO tduration2_ZERO tduration3_ZERO tduration4_ZERO tduration5_ZERO tduration6_ZERO tduration7_ZERO tduration8_ZERO tduration9_ZERO tduration10_ZERO tduration11_ZERO tduration12_ZERO tduration13_ZERO tduration14_ZERO tduration15_ZERO tduration16_ZERO tduration17_ZERO tduration18_ZERO tduration19_ZERO tduration20_ZERO tduration21_ZERO tduration22_ZERO tduration23_ZERO tduration24_ZERO





drop duration1_CENONZERO distance1_CENONZERO duration2_CENONZERO distance2_CENONZERO duration3_CENONZERO distance3_CENONZERO duration4_CENONZERO distance4_CENONZERO duration5_CENONZERO distance5_CENONZERO duration6_CENONZERO distance6_CENONZERO duration7_CENONZERO distance7_CENONZERO duration8_CENONZERO distance8_CENONZERO duration9_CENONZERO distance9_CENONZERO duration10_CENONZERO distance10_CENONZERO duration11_CENONZERO distance11_CENONZERO duration12_CENONZERO distance12_CENONZERO duration13_CENONZERO distance13_CENONZERO duration14_CENONZERO distance14_CENONZERO duration15_CENONZERO distance15_CENONZERO duration16_CENONZERO distance16_CENONZERO duration17_CENONZERO distance17_CENONZERO duration18_CENONZERO distance18_CENONZERO duration19_CENONZERO distance19_CENONZERO duration20_CENONZERO distance20_CENONZERO duration21_CENONZERO distance21_CENONZERO duration22_CENONZERO distance22_CENONZERO duration23_CENONZERO distance23_CENONZERO duration24_CENONZERO distance24_CENONZERO tdistance1_CENONZERO tdistance2_CENONZERO tdistance3_CENONZERO tdistance4_CENONZERO tdistance5_CENONZERO tdistance6_CENONZERO tdistance7_CENONZERO tdistance8_CENONZERO tdistance9_CENONZERO tdistance10_CENONZERO tdistance11_CENONZERO tdistance12_CENONZERO tdistance13_CENONZERO tdistance14_CENONZERO tdistance15_CENONZERO tdistance16_CENONZERO tdistance17_CENONZERO tdistance18_CENONZERO tdistance19_CENONZERO tdistance20_CENONZERO tdistance21_CENONZERO tdistance22_CENONZERO tdistance23_CENONZERO tdistance24_CENONZERO tduration1_CENONZERO tduration2_CENONZERO tduration3_CENONZERO tduration4_CENONZERO tduration5_CENONZERO tduration6_CENONZERO tduration7_CENONZERO tduration8_CENONZERO tduration9_CENONZERO tduration10_CENONZERO tduration11_CENONZERO tduration12_CENONZERO tduration13_CENONZERO tduration14_CENONZERO tduration15_CENONZERO tduration16_CENONZERO tduration17_CENONZERO tduration18_CENONZERO tduration19_CENONZERO tduration20_CENONZERO tduration21_CENONZERO tduration22_CENONZERO tduration23_CENONZERO tduration24_CENONZERO


compress
save "S:\databases\1_Projets\CrossEUwork_Andrea_Albanese\marclondon\data\data.dta", replace

