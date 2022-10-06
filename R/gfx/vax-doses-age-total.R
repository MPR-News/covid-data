p <- vaccine_1x_age %>%
	filter(age != "Unknown/Missing", age != "Unknown/missing") %>%
	mutate(age = str_remove_all(age, " years")) %>%
	mutate(report_date = as_date(report_date)) %>%
	left_join(tibble(age = c("0.5-4", "5-11", "12-15", "16-17", "18-49", "50-64", "65+") %>% as_factor(),
					 pop = c(316497, 509735, 290688, 143046, 2294817, 1114015, 490739 + 367959)),
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
				  alpha = case_when(pct_complete < 0.06 ~ 0, TRUE ~ 1)), 
			  color = "white", size = 6) +
	geom_text(aes(y = pct_boosted, label = percent(pct_boosted, accuracy = .1), hjust = case_when(pct_boosted < 0.05 ~ -.1, TRUE ~ 1.1),
				  alpha = case_when(pct_boosted < 0.06 ~ 0, TRUE ~ 1)), 
			  color = "white", size = 6) +
	scale_y_continuous(expand = expansion(mult = c(0, .12))) +
	scale_color_identity() + 
	scale_alpha_identity() +
	scale_fill_manual(values = covidmn_colors) +
	coord_flip() +
	theme_covidmn() +
	theme(axis.title = element_blank(),
		  axis.text.x = element_blank(),
		  plot.subtitle = element_markdown(lineheight = 1.1),
		  legend.position = "none") +
	labs(title = "Total COVID-19 vaccinations to date by age",
		 subtitle = "Minnesotans who have <span style='color:#56B4E9'>at least one dose</span>, <span style='color:#E69F00'>complete vaccinations</span> and who are<br><span style='color:#009E73'>up-to-date</span>. To be \"up-to-date\" people may need multiple booster doses.",
		 caption = caption)
fix_ratio(p, ratio = "short") %>% image_write(here("images/doses-by-age-pct.png"))
