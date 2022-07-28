p <- vaccine_1x_age %>%
	filter(age != "Unknown/Missing", age != "Unknown/missing") %>%
	mutate(age = str_remove_all(age, " years")) %>%
	mutate(report_date = as_date(report_date)) %>%
	left_join(read_csv(here("data-input/mn-age-pop.csv")) %>%
			  	filter(NAME == "Minnesota", SEX == 0, AGE >= 0, AGE != 999) %>%
			  	select(age = AGE, POPEST2015_CIV:POPEST2019_CIV) %>% #, pop = POPEST2019_CIV) %>%
			  	mutate(age_bracket = case_when(age %in% 1:4 ~ "0.5-4",
			  								   age %in% 5:11 ~ "5-11",
			  								   age %in% 12:15 ~ "12-15",
			  								   age %in% 16:17 ~ "16-17",
			  								   age %in% 18:49 ~ "18-49",
			  								   age %in% 50:64 ~ "50-64",
			  								   age >= 65 ~ "65+")) %>%
			  	group_by(age = age_bracket) %>%
			  	summarize(across(is.numeric, sum)) %>%
			  	filter(!is.na(age)) %>%
			  	transmute(age, pop = (POPEST2015_CIV + POPEST2016_CIV + POPEST2017_CIV + POPEST2018_CIV + POPEST2019_CIV) / 5),
			  by = "age") %>%
	mutate(pct_onedose = people_onedose / pop,
		   pct_complete = people_complete / pop,
		   pct_boosted = people_boosted / pop) %>%
	mutate(age = fct_relevel(age, "0.5-4", "5-11", "12-15", "16-17", "18-49", "50-64", "65+")) %>%
	filter(report_date == max(report_date)) %>%
	ggplot(aes(x = fct_rev(age))) +
	geom_col(aes(y = pct_onedose), fill = covidmn_colors[2]) +
	geom_col(aes(y = pct_complete), fill = covidmn_colors[1]) +
	geom_col(aes(y = pct_boosted), fill = covidmn_colors[3]) +
	geom_text(aes(y = pct_onedose, label = percent(pct_onedose, accuracy = .1)), 
			  hjust = -.1, color = "black", size = 6) +
	geom_text(aes(y = pct_complete, label = percent(pct_complete, accuracy = .1), hjust = case_when(pct_complete < 0.05 ~ -.1, TRUE ~ 1.1),
				  alpha = case_when(pct_complete < 0.05 ~ 0, TRUE ~ 1)), 
			  color = "white", size = 6) +
	geom_text(aes(y = pct_boosted, label = percent(pct_boosted, accuracy = .1), hjust = case_when(pct_complete < 0.05 ~ -.1, TRUE ~ 1.1),
				  alpha = case_when(pct_complete < 0.05 ~ 0, TRUE ~ 1)), 
			  color = "white", size = 6) +
	scale_y_continuous(expand = expansion(mult = c(0, .12))) +
	scale_color_identity() + 
	scale_alpha_identity() +
	scale_fill_manual(values = covidmn_colors) +
	# expand_limits(y = 4478797) +
	coord_flip() +
	theme_covidmn() +
	theme(axis.title = element_blank(),
		  axis.text.x = element_blank(),
		  plot.subtitle = element_markdown(lineheight = 1.1),
		  legend.position = "none") +
	labs(title = "Total COVID-19 vaccinations to date by age",
		 subtitle = "Minnesotans who have <span style='color:#56B4E9'>at least one dose</span>, <span style='color:#E69F00'>complete vaccinations</span> and who are<br><span style='color:#009E73'>fully boosted</span>. \"Fully boosted\" older adults must have multiple booster doses.",
		 caption = caption)
fix_ratio(p, ratio = "short") %>% image_write(here("images/doses-by-age-pct.png"))
