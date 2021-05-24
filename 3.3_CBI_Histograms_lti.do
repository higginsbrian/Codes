
* A file to plot histograms that were already created in datasets at the CBI


*-------------------------*-------------------------*-------------------------*-------------------------
*--------choose sample
*-------------------------*-------------------------*-------------------------*-------------------------


*local data  "noBTL"
*local data  "BTL"
*local data  "SSB"
*local data  "FTB"
*local data  "all"
*BTL SSB FTB all
foreach data in noBTL  {
local data  "noBTL"
use "$DATA_LOCAL/10.CBI/2.outputs/histograms/time_borrowerlti_bin.dta" ,clear

if "`data'" == "BTL" | "`data'" == "SSB" | "`data'" == "FTB" {
	keep if borrower_type == "`data'" 
	di "`data'"
	}
else if "`data'" == "noBTL" {
	keep if borrower_type == "FTB" |borrower_type == "SSB"
	di "`data'"
}
else if "`data'" == "all" {
	keep if borrower_type == "FTB"   |borrower_type == "SSB"  |borrower_type == "BTL"
	di "`data'"
}


*-------------------------*-------------------------*-------------------------*-------------------------
*--------collapse and organise variables
*-------------------------*-------------------------*-------------------------*-------------------------

collapse (sum) countvar loan_size , by(lti_bin yr_loan)

drop if lti_bin == 0
drop if lti_bin == .

*calculate totals to do densities
sort yr_loan 
by yr_loan: egen countvar_total = total(countvar)
by yr_loan: egen loan_size_total = total(loan_size)

g countvar_percent = (countvar/countvar_total)*100
g loan_size_percent =(loan_size/loan_size_total)*100 


egen id = group(lti_bin)
order yr_loan lti_bin id
drop if id==.
tsset yr_loan id
tsfill, full
replace countvar_percent= 0 if countvar_percent==.
replace loan_size_percent= 0 if loan_size_percent==.
label var  countvar_percent "Percent"
label var loan_size_percent "Percent"

bysort yr_loan: egen countvar_percent_total =  total(countvar_percent)
bysort yr_loan: egen loan_size_percent_total = total(loan_size_percent)

*-------------------------*-------------------------*-------------------------*-------------------------
*--------plot
*-------------------------*-------------------------*-------------------------*-------------------------

foreach year of numlist 2000/2018 {
	foreach var in  loan_size_percent /*countvar_percent*/ {
		
		*local year =2014
		*local var loan_size_percent 
		
		*local for filenames
		if "`var'" == "countvar_percent" {
			local varname "count"
			}
		if "`var'" == "loan_size_percent" {
			local varname "loan"
			}	

	*square
	twoway bar `var' id if yr_loan ==`year' , ///
				barwidth(1) color(gs3)  xline(23, lwidth(thick)) /// 
				xlabel(1 " " 2 " " 3 "0.5" 4 " " 5 " " 6 " " 7 " " 8 " " 9 " " 10 "1.5"  11 " " 12 " " 13 " " ///
				14 " " 15 " " 16 "2.5" 17 " " 18 " " 19 " " 20 " " 21 " " 22 " " 23 "3.5" 24 " " 25 " " 26 " " ///
				27 " " 28 " " 29 " " 30 "4.5" 31 " " 32 " " 33 " " 34 " " 35 " " 36 "5.5" 37 " " 38 " " 39 " " ///
				40 " " 41 " " 42 " " 43 "6.5" 44 " " 45 " " 46 " " 47 " ",  nogrid labsize(vlarge) )  ///
				ylabel(0 "" 5 "5" 10 "10" 15 "15" 20 "20", labsize(vlarge))	///
				yscale( range(0 23)) ytitle(, size(vlarge)) xtitle(Loan to income, size(vlarge)) xsize(4.6)
				graph export "$CHARTS_LOCAL/14.histograms_scaled/1.square/lti_`year'_`data'_fweight_`varname'.png", ///
				as(png) replace
	
	*wide	
	/*
	twoway bar `var'  id if yr_loan ==`year' , ///
				barwidth(1) color(gs3)  xline(23, lwidth(thick)) /// 
				xlabel(1 " " 2 " " 3 "0.5" 4 " " 5 " " 6 " " 7 " " 8 " " 9 " " 10 "1.5"  11 " " 12 " " 13 " " ///
				14 " " 15 " " 16 "2.5" 17 " " 18 " " 19 " " 20 " " 21 " " 22 " " 23 "3.5" 24 " " 25 " " 26 " " ///
				27 " " 28 " " 29 " " 30 "4.5" 31 " " 32 " " 33 " " 34 " " 35 " " 36 "5.5" 37 " " 38 " " 39 " " ///
				40 " " 41 " " 42 " " 43 "6.5" 44 " " 45 " " 46 " " 47 " ",  nogrid labsize(large) )  ///
				ylabel(0 "" 5 "5" 10 "10" 15 "15" 20 "20", labsize(large))	///
				yscale( range(0 23)) ytitle(, size(large)) xtitle(Loan to income, size(large)) xsize(8)
				graph export "$CHARTS_LOCAL/14.histograms_scaled/2.wide/lti_`year'_`data'_fweight_`varname'.png", ///
				as(png) replace
		*/		
	}
}			

}
