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

rollsum_new <- function(x, y) {case_when(y == 3 ~ rollsumr(x, 3, fill = NA),
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
					  url = c("https://mn.gov/covid19/assets/Doses%20Administered_tcm1148-513630.csv", 
					  		"https://mn.gov/covid19/assets/Doses%20Administered%20By%20Age_tcm1148-513626.csv",
					  		"https://mn.gov/covid19/assets/Doses%20Administered%20By%20Gender_tcm1148-513627.csv",
					  		"https://mn.gov/covid19/assets/Doses%20Administered%20By%20Provider_tcm1148-513628.csv",
					  		"https://mn.gov/covid19/assets/People%20Vaccinated%2C%20By%20County_tcm1148-513635.csv",
					  		"https://mn.gov/covid19/assets/People%20Vaccinated%2C%20By%20Age_tcm1148-513634.csv",
					  		"https://mn.gov/covid19/assets/People%20Vaccinated%2C%20By%20Gender_tcm1148-513636.csv",
					  		"https://mn.gov/covid19/assets/Doses%20shipped%20to%20Minnesota%20providers%2C%20by%20product_tcm1148-513632.csv",
					  		"https://mn.gov/covid19/assets/Percent%20of%20Age%20Group%20Population%20Vaccinated_tcm1148-513637.csv",
					  		"https://mn.gov/covid19/assets/Vaccinations%20by%20Race%20and%20Ethnicity_tcm1148-470631.csv",
					  		"https://mn.gov/covid19/assets/Vaccination%20Progress%20to%20Date%2C%20by%20Race%20and%20Ethnicity_tcm1148-470630.csv",
					  		"https://mn.gov/covid19/assets/People%20Vaccinated%2C%20By%20ZIP_tcm1148-513788.csv"
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
