if(!exists("breakthroughs_weighted_age_adults")) {
	breakthroughs_weighted_age_adults <- read_csv(here("data/breakthroughs/breakthroughs-weighted-age-adults.csv"))
	}



breakthrough_age_function <- function(metric_name, label) {
	p <- breakthroughs_weighted_age_adults %>%
		filter(metric != "pop", metric_type == "rate") %>%
		group_by(metric, age, vax_status) %>%
		mutate(value_3day = rollmeanr(value, 3, fill = "extend")) %>%
		pivot_wider(names_from = vax_status, values_from = value_3day, id_cols = c(week_start, metric, age)) %>%
		mutate(boosted_ratio = unvaxxed / boosted,
			   vaxxed_ratio = unvaxxed / vaxxed) %>%
		pivot_longer(contains("ratio"), names_to = "ratio_type", values_to = "ratio") %>%
		filter(!is.infinite(ratio)) %>%
		filter(metric == metric_name) %>%
		filter(if(metric_name == "deaths") age != "18-49" else age %in% age) %>%
		filter(if(metric_name == "deaths") week_start >= as_date("2021-08-01") else week_start %in% week_start) %>%
		ggplot(aes(x = week_start, y = ratio, color = ratio_type)) +
		geom_hline(yintercept = 1, linetype = 3) +
		geom_line(size = 1) +
		facet_wrap(vars(age)) + 
		scale_y_continuous(expand = expansion(mult = c(.02, .02)), sec.axis = dup_axis(), breaks = c(1, 2, 4, 8, 16, 32, 64),
						   labels = number_format(suffix = "x", accuracy = 1), trans = "log2") +
		scale_x_date(date_labels = "%Y", date_breaks = "1 year", expand = expansion(mult = c(.03, .03))) +
		scale_color_manual(values = covidmn_colors) +
		theme_covidmn_line() +
		theme(axis.title = element_blank(),
			  plot.subtitle = element_markdown(lineheight = 1.1),
			  legend.position = "none") +
		labs(title = paste0("COVID ", label, " in MN by age, vaccination"),
			 subtitle = "Prevalence among unvaccinated adults relative to the <span style = 'color:#56B4E9'>fully vaccinated</span> <br>and <span style = 'color:#E69F00'>boosted</span>, by age. Lines represent three-week rolling averages.",
			 caption = caption,
			 y = "How many times more common\namong the unvaccinated")
	fix_ratio(p) %>% image_write(here("images/", paste0("breakthrough-age-", metric_name, ".png")))
}

map2(list("cases", "hosp", "deaths"),
	 list("cases", "hospitalizations", "deaths"),
	 ~breakthrough_age_function(.x, .y))
rm(breakthrough_age_function)
