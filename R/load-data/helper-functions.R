reverselog_trans <- function(base = exp(1)) {
	trans <- function(x) -log(x, base)
	inv <- function(x) base^(-x)
	trans_new(paste0("reverselog-", format(base)), trans, inv, 
			  log_breaks(base = base), 
			  domain = c(1e-100, Inf))
}

monthyear_labels <- function(breaks) {
	df.breaks <- data.frame(date = breaks) %>%
		mutate(formatted = case_when(lubridate::month(date) == 1 ~ format(date, "%b '%y"),
									 T ~ format(date, "%b")))
	return(df.breaks$formatted)
}

date_parser <- function(mystring) {
	if(stringr::str_detect(mystring, "^20\\d\\d\\-")) {
		lubridate::ymd(mystring)
	} else if (stringr::str_detect(mystring, "^\\d\\d?\\/")) {
		lubridate::mdy(mystring)
	}
}


rollmean_n <- function(x, n) {if(is.na(n)) {rollmeanr(x, 7, fill = NA)} else {rollmeanr(x, n, fill = NA)}}
rollsum_n <- function(x, n) {if(is.na(n)) {rollsumr(x, 7, fill = NA)} else {rollsumr(x, n, fill = NA)}}
rollmean7 <- function(x) {rollmeanr(x, 7, fill = NA)}
rollmean6 <- function(x) {rollmeanr(x, 6, fill = NA)}
rollsum7 <- function(x) {rollsumr(x, 7, fill = NA)}
rollsum6 <- function(x) {rollsumr(x, 6, fill = NA)}

rollsum_new <- function(x, y) {case_when(y == 1 ~ rollsumr(x, 1, fill = NA),
										 y == 2 ~ rollsumr(x, 2, fill = NA),
										 y == 3 ~ rollsumr(x, 3, fill = NA),
										 y == 4 ~ rollsumr(x, 4, fill = NA),
										 y == 5 ~ rollsumr(x, 5, fill = NA),
										 y == 6 ~ rollsumr(x, 6, fill = NA),
										 y == 7 ~ rollsumr(x, 7, fill = NA),
										 TRUE ~ NA_real_)}

rollmean_new <- function(x, y) {rollsum_new(x, y) / 7}

options("HTTPUserAgent"="User-Agent: MPR_KSJN_KLINGBOT")

hospitals_dir <- tibble(name = c("TELETRACKING", "MNTRAC"),
						url = c("https://mn.gov/covid19/assets/TELETRACKING_ICU_NonICU_Beds_in_Use_CSV_tcm1148-455097.csv",
								 "https://mn.gov/covid19/assets/MNTRAC_ICU_NonICU_BedAvailability_IdentifiedSurge_CSV_tcm1148-455098.csv"),
						filepath = c(here("captcha-bypass/TELETRACKING_ICU_NonICU_Beds_in_Use_CSV_tcm1148-455097.csv"),
									 here("captcha-bypass/MNTRAC_ICU_NonICU_BedAvailability_IdentifiedSurge_CSV_tcm1148-455098.csv")))

vaccine_dir <- tibble(name = c("vaccine_doses", "vaccine_age", "vaccine_gender", "vaccine_providers", "vaccine_1x_county", "vaccine_1x_age", "vaccine_1x_gender", "doses_shipped", "vaccine_1x_age_county", "vaccine_race", "vaccine_race_progress", "vaccine_zip"), 
					  url = c("https://www.health.state.mn.us/diseases/coronavirus/stats/vaxdp.csv", #vaccine_doses
					  		"https://www.health.state.mn.us/diseases/coronavirus/stats/vaxdemodage.csv", #vaccine_age
					  		"https://www.health.state.mn.us/diseases/coronavirus/stats/vaxdemodsex.csv", #vaccine_gender
					  		"https://www.health.state.mn.us/diseases/coronavirus/stats/vaxdap.csv", #vaccine_providers
					  		"https://www.health.state.mn.us/diseases/coronavirus/stats/vaxpplcty.csv", #vaccine_1x_county
					  		"https://www.health.state.mn.us/diseases/coronavirus/stats/vaxdemopplage.csv", #vaccine_1x_age
					  		"https://www.health.state.mn.us/diseases/coronavirus/stats/vaxdemopplsex.csv", #vaccine_1x_gender
					  		"https://mn.gov/covid19/assets/Doses%20shipped%20to%20Minnesota%20providers%2C%20by%20product_tcm1148-513632.csv", #doses_shipped
					  		"https://www.health.state.mn.us/diseases/coronavirus/stats/vaxdemoagepop.csv", #waccine_1x_age_county
					  		"https://www.health.state.mn.us/diseases/coronavirus/stats/vaxhere.csv", #vaccine_race
					  		"https://www.health.state.mn.us/diseases/coronavirus/stats/vaxheotre.csv", #vaccine_race_progress
					  		"https://www.health.state.mn.us/diseases/coronavirus/stats/vaxpplzip.csv" #vaccine_zip
					  ),
					  url2 = c(rep(NA_character_, 7), "https://mn.gov/covid19/assets/Doses%20shipped%20for%20CDC%20federal%20pharmacy%20program%2C%20by%20product_tcm1148-513631.csv", rep(NA_character_, 4)),
					  filepath = c(here("captcha-bypass/Doses Administered_tcm1148-513630.csv"), 
					  			 here("captcha-bypass/Doses Administered By Age_tcm1148-513626.csv"), 
					  			 here("captcha-bypass/Doses Administered By Gender_tcm1148-513627.csv"), 
					  			 here("captcha-bypass/Doses Administered By Provider_tcm1148-513628.csv"), 
					  			 here("captcha-bypass/People Vaccinated, By County_tcm1148-513635.csv"), 
					  			 here("captcha-bypass/People Vaccinated, By Age_tcm1148-513634.csv"), 
					  			 here("captcha-bypass/People Vaccinated, By Gender_tcm1148-513636.csv"), 
					  			 here("captcha-bypass/Doses shipped to Minnesota providers, by product_tcm1148-513632.csv"), 
					  			 here("captcha-bypass/Percent of Age Group Population Vaccinated_tcm1148-513637.csv"), 
					  			 here("captcha-bypass/Vaccinations by Race and Ethnicity_tcm1148-470631.csv"), 
					  			 here("captcha-bypass/Vaccination Progress to Date, by Race and Ethnicity_tcm1148-470630.csv"), 
					  			 here("captcha-bypass/People Vaccinated, By ZIP_tcm1148-487055.csv")),
					  filepath2 = c(rep(NA_character_, 7), 
					  			  here("captcha-bypass/Doses shipped for CDC federal pharmacy program, by product_tcm1148-513631.csv"), 
					  			  rep(NA_character_, 4)))

url_picker <- function(id, is_captcha, is2 = FALSE) {
	if(is_captcha == TRUE & is2 == FALSE) {
		vaccine_dir %>% filter(name == id) %>% pull(filepath)
	} else if(is_captcha == FALSE & is2 == FALSE) {
		vaccine_dir %>% filter(name == id) %>% pull(url)
	} else if(is_captcha == TRUE & is2 == TRUE) {
		vaccine_dir %>% filter(name == id) %>% pull(filepath2)	
	} else {
		vaccine_dir %>% filter(name == id) %>% pull(url2)
	}
}

url_picker_hosp <- function(id, is_captcha) {
	if(is_captcha == TRUE) {
		hospitals_dir %>% filter(name == id) %>% pull(filepath)
	} else {
		hospitals_dir %>% filter(name == id) %>% pull(url)
	}
}

update_boosters <- function(n) {
	covid_totals_report <<- covid_totals_report %>%
		mutate(total_booster_doses = case_when(date == max(date) ~ n, TRUE ~ total_booster_doses)) %>%
		write_csv(here("data/covid_totals_report.csv"))
}

comp_tibble <- tibble(object = c("cases_total", "cases_county", "cases_age", "cases_sex", "cases_race",
								 "hosp_total", "hosp_county", "hosp_age", "hosp_sex", "hosp_race",
								 "deaths_total", "deaths_county", "deaths_age", "deaths_sex", "deaths_race"),
					  raw_file = c("cases_total.csv", "cases_county.csv", "cases_age.csv", "cases_sex.csv", "cases_race.csv",
					  			 "hosp_total.csv", "hosp_county.csv", "hosp_age.csv", "hosp_sex.csv", "hosp_race.csv",
					  			 "deaths_total.csv", "deaths_county.csv", "deaths_age.csv", "deaths_sex.csv", "deaths_race.csv"),
					  comp_file = c("comp/comp_cases_total.csv", "comp/comp_cases_county.csv", "comp/comp_cases_age.csv", "comp/comp_cases_sex.csv", "comp/comp_cases_race.csv",
					  			  "comp/comp_hosp_total.csv", "comp/comp_hosp_county.csv", "comp/comp_hosp_age.csv", "comp/comp_hosp_sex.csv", "comp/comp_hosp_race.csv",
					  			  "comp/comp_deaths_total.csv", "comp/comp_deaths_county.csv", "comp/comp_deaths_age.csv", "comp/comp_deaths_sex.csv", "comp/comp_deaths_race.csv"),
					  group_col = rep(c("outcome", "county", "age_group", "sex", "race_ethnicity"), 3))

process_comps <- function(object, comp_file, group_col) {
	group_col <- syms(group_col)
	# object <- get(object)
	bind_rows(get(object),
			  read_csv(here("data", comp_file))) %>%
		arrange(report_date, !!!group_col, mmwr_startdate) %>%
		distinct(report_date, mmwr_startdate, !!!group_col, .keep_all = TRUE) %>%
		assign(x = object, value = ., envir = globalenv()) %>%
		write_csv(here("data", comp_file))
}