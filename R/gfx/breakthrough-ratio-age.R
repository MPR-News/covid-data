if(!exists("breakthroughs_weighted")) {source(here("R/load-files/download-breakthroughs.R"))}

p <- breakthroughs_weighted_age %>%
	group_by(age, metric, vax) %>%
	mutate(value_3week = rollmeanr(value, 3, fill = "extend")) %>%
	pivot_wider(names_from = vax, values_from = c(value_3week), id_cols = c(week_start, age, metric)) %>%
	# pivot_wider(names_from = vax, values_from = c(value), id_cols = c(week_start, age, metric)) %>%
	group_by(age, metric) %>%
	mutate(ratio = unvaxxed / vaxxed) %>%
	filter(!is.nan(ratio), !is.infinite(ratio)) %>%
	mutate(metric = case_when(metric == "caserate" ~ "Cases",
							  metric == "deathrate" ~ "Deaths",
							  metric == "hosprate" ~ "Hospitalizations") %>%
		   	fct_relevel("Cases", "Hospitalizations", "Deaths")) %>%
	ggplot(aes(x = week_start, y = ratio, color = age)) +
	geom_line(size = 1) +
	facet_wrap(vars(metric), nrow = 1) +
	scale_y_continuous(expand = expansion(mult = c(0, .02)), sec.axis = dup_axis(), breaks = c(1, 2, 4, 8, 16, 32, 64),
					   labels = number_format(suffix = "x", accuracy = 1), trans = "log2") +
	scale_x_date(date_labels = "%b", date_breaks = "2 month", expand = expansion(mult = c(.03, .03))) +
	scale_color_manual(values = covidmn_colors) +
	expand_limits(y = 1) +
	theme_covidmn() +
	theme(axis.ticks.x = element_line(),
		  axis.title.x = element_blank(),
		  axis.title.y.right = element_blank(),
		  panel.grid.major.y = element_line(color = "grey95"),
		  plot.subtitle = element_markdown(),
		  legend.position = "none") +
	labs(title = "COVID-19 breakthrough prevalence by age",
		 subtitle = "Among Minnesotans aged <span style='color:#E69F00'>12-17</span>, <span style='color:#56B4E9'>18-49</span>, <span style='color:#009E73'>50-64</span> and <span style='color:#D55E00 '>65+</span>",
		 caption = paste0("Lines are three-week averages. Death data too low to show for 12-17-year-olds.\n", caption),
		 y = "How many times more common\namong the unvaccinated")
fix_ratio(p) %>% image_write(here("images/breakthrough-ratio-age.png"))
