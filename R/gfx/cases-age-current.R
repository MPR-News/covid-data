if(!exists("cases_age")) {source(here("R/load-data/download-cases.R"))}

p <- cases_age %>%
	filter(mmwr_enddate < max(mmwr_enddate)) %>%
	filter(mmwr_enddate == max(mmwr_enddate)) %>%
	ggplot(aes(x = fct_rev(age_group), y = new_cases_percap)) +
	geom_col() + 
	geom_text(aes(label = comma(new_cases_percap, accuracy = .1)), hjust = 1.1, color = "white", size = 5) +
	scale_y_continuous(expand = expansion(mult = 0)) +
	coord_flip() +
	theme_covidmn() +
	theme(axis.title = element_blank(), axis.text.x = element_blank()) +
	labs(title = "New COVID-19 cases per capita by age",
		 subtitle = "Confirmed cases per 100,000 last week in Minnesota",
		 caption = caption)
fix_ratio(p, ratio = "short") %>% image_write(here("images/new-cases-age-current.png"))
