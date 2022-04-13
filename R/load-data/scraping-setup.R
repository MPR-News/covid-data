library(tidyverse)
library(rvest)
library(lubridate)
library(httr)

url <- "https://www.health.state.mn.us/diseases/coronavirus/situation.html"

situation_report <- url %>%
	GET(user_agent(user_agent)) %>%
	read_html()

current_report_date <- situation_report %>%
	html_nodes(xpath = '//*[@id="body"]/div[1]/p/strong[1]') %>%
	html_text() %>%
	str_remove_all("Updated ") %>%
	str_split(" \r| \n") %>%
	pluck(1) %>%
	purrr::pluck(1) %>%
	mdy()

if(is.na(current_report_date)) {stop("Date not acquired")}

scrape_totals <- function() {
	total_booster_doses <- readline("total_booster_doses = ") %>% parse_number()
	tibble(metric = c("cases_removed", 
					  # "total_tests", 
					  # "total_antigen_tests", 
					  "total_positives_reinfections", 
					  "total_antigen_positives", 
					  "total_positives", 
					  "total_recovered", 
					  "total_deaths", 
					  "total_ltc_deaths", 
					  "total_hosp", 
					  "total_icu"),
		   xpath = c('//*[@id="dailyc"]/div/ul/li/text()[1]', 
		   		  # '//*[@id="testtotal"]/tbody/tr[1]/td', 
		   		  # '//*[@id="testtotal"]/tbody/tr[3]/td',
		   		  '//*[@id="casetotal"]/tbody/tr/td',
		   		  '//*[@id="casebtotal"]/tbody/tr[2]/td/span',
		   		  '//*[@id="casereinftotal"]/tbody/tr/td',
		   		  '//*[@id="noisototal"]/tbody/tr/td',
		   		  '//*[@id="deathtotal"]/tbody/tr/td',
		   		  '//*[@id="deathtotal"]/tbody/tr/td/span',
		   		  '//*[@id="hosptotal"]/tbody/tr[1]/td',
		   		  '//*[@id="hosptotal"]/tbody/tr[2]/td/span')) %>%
		mutate(value = map_dbl(xpath, 
							   ~situation_report %>% 
							   	html_nodes(xpath = .x) %>% 
							   	html_text() %>% 
							   	pluck(1) %>% 
							   	parse_number())) %>%
		select(-xpath) %>%
		pivot_wider(names_from = metric, values_from = value) %>%
		mutate(date = current_report_date,
			   day = wday(current_report_date, label = TRUE, abbr = FALSE),
			   .before = 1L) %>%
		bind_cols(vaccine_1x_gender %>%
				  	filter(report_date == max(report_date)) %>%
				  	summarize(across(is.numeric, sum, .names = '{str_replace_all({.col}, "people_", "total_vax_")}')),
				  vaccine_doses %>%
				  	filter(report_date == max(report_date), category == "Total vaccine doses administered") %>%
				  	select(total_vax_doses = doses),
				  tibble(total_booster_doses = total_booster_doses))
}