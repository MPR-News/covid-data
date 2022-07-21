p <- comp_cases_total %>%
	filter(report_date == max(report_date)) %>%
	ungroup() %>%
	# filter(report_date == as_date("2022-02-15")) %>%
	# filter(report_date == max(report_date) - 7) %>%
	transmute(date, newly_reported_cases, pct = newly_reported_cases / sum(newly_reported_cases)) %>%
	filter(!is.nan(pct)) %>%
	arrange(desc(date)) %>%
	rowid_to_column() %>%
	mutate(display_date = case_when(date >= (max(date, na.rm = TRUE) - 8) ~ format(date, "%a\n%m/%d") %>% as.character(), 
									TRUE ~ "Older")) %>%
	filter(pct > 0) %>%
	mutate(display_date = fct_reorder(display_date, rowid, .desc = TRUE)) %>%
	group_by(display_date) %>%
	summarize(newly_reported_cases = sum(newly_reported_cases),
			  pct = sum(pct)) %>%
	mutate(relative_height = pct / max(pct)) %>%
	ggplot(aes(x = display_date, y = pct)) +
	geom_col() +
	geom_text(aes(label = percent(pct, accuracy = .1),
				  vjust = case_when(relative_height > .05 ~ 1.1, TRUE ~ -.1),
				  color = case_when(relative_height > .05 ~ "white", TRUE ~ "black")),
			  size = 6) +
	scale_y_continuous(expand = expansion(mult = 0)) +
	scale_color_identity() +
	theme_covidmn() +
	theme(axis.title.y = element_blank(),
		  axis.text.y = element_blank()) + 
	labs(title = "When were new cases reported today tested?",
		 subtitle = paste0("For Minnesota cases reported on ", format(current_report_date, "%b. %d, %Y")),
		 caption = caption,
		 x = "Date samples were collected")
fix_ratio(p) %>% image_write(here("images/case-report-day.png"))
