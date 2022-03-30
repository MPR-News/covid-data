if(!exists("age_table")) {source(here("R/scrape-demographics.R"))}

p <- age_table %>%
	mutate(age_group = str_remove_all(age_group, " years")) %>%
	filter(age_group != "Unknown/missing") %>%
	filter(date >= as_date("2020-08-20")) %>%
	mutate(age = fct_collapse(age_group,
							  "0-9" = c("0-4", "5-9"),
							  "10-19" = c("10-14", "15-19"),
							  "20-29" = c("20-24", "25-29"),
							  "30-39" = c("30-34", "35-39"),
							  "40-49" = c("40-44", "45-49"),
							  "50-59" = c("50-54", "55-59"),
							  "60-69" = c("60-64", "65-69"),
							  "70+" = c("70-74", "75-79", "80-84", "85-89", "90-94", "95-99", "100+"))) %>%
	group_by(date, age) %>%
	summarize(cases = sum(cases)) %>%
	left_join(read_csv(here("data-input/mn-age-pop.csv")) %>%
			  	mutate(age = case_when(AGE %in% 0:9 ~ "0-9",
			  						   AGE %in% 10:19 ~ "10-19",
			  						   AGE %in% 20:29 ~ "20-29",
			  						   AGE %in% 30:39 ~ "30-39",
			  						   AGE %in% 40:49 ~ "40-49",
			  						   AGE %in% 50:59 ~ "50-59",
			  						   AGE %in% 60:69 ~ "60-69",
			  						   AGE >= 70 ~ "70+")) %>%
			  	select(age, POPEST2015_CIV:POPEST2019_CIV) %>%
			  	group_by(age) %>%
			  	summarize(across(is.numeric, sum)) %>%
			  	transmute(age, pop = (POPEST2015_CIV + POPEST2016_CIV + POPEST2017_CIV + POPEST2018_CIV + POPEST2019_CIV) / 5),
			  by = "age") %>%
	mutate(lag_date = date - 7) %>%
	left_join(x = ., 
			  y = {.} %>% select(date, age, lag_cases = cases),
			  by = c("lag_date" = "date", "age")) %>%
	filter(!is.na(lag_cases)) %>%
	group_by(age) %>%
	mutate(new_cases_percap_7day = ((cases - lag_cases) / 7) / (pop / 100000)) %>%
	filter(date == max(date)) %>%
	ggplot(aes(x = fct_rev(age), y = new_cases_percap_7day)) +
	geom_col() + 
	geom_text(aes(label = comma(new_cases_percap_7day, accuracy = .1)), hjust = 1.1, color = "white", size = 5) +
	scale_y_continuous(expand = expansion(mult = 0)) +
	coord_flip() +
	theme_covidmn() +
	theme(axis.title = element_blank(), axis.text.x = element_blank()) +
	labs(title = "New COVID-19 cases per capita by age",
		 subtitle = "Average cases per 100,000 over the last 7 days in Minnesota",
		 caption = caption)
fix_ratio(p, ratio = "short") %>% image_write(here("images/new-cases-age-current.png"))
