if(!exists("breakthroughs_weighted_adults")) {
	breakthroughs_weighted_adults <- read_csv(here("data/breakthroughs/breakthroughs-weighted-adults.csv"))
}

p <- breakthroughs_weighted_adults %>%
	pivot_longer(4:ncol(.), names_to = c("metric", "vax_status"), names_sep = "_") %>%
	group_by(metric, vax_status) %>%
	mutate(value_3week = rollmeanr(value, 3, fill = "extend")) %>%
	pivot_wider(names_from = vax_status, values_from = c(value_3week), id_cols = c(week_start, metric)) %>%
	mutate(boosted_ratio = boosted / unvaxxed,
		   vaxxed_ratio = vaxxed / unvaxxed) %>%
	pivot_longer(contains("ratio"), names_to = "ratio_type", values_to = "ratio") %>%
	mutate(ratio_type = str_remove_all(ratio_type, "_ratio")) %>%
	mutate(metric = case_when(metric == "hosp" ~ "Hospitalizations", TRUE ~ str_to_title(metric))) %>%
	ungroup() %>%
	mutate(metric = fct_relevel(metric, "Cases", "Hospitalizations", "Deaths")) %>%
	filter(ratio > 0) %>%
	ggplot(aes(x = week_start, y = ratio, color = ratio_type)) +
	geom_hline(yintercept = 1, linetype = 2) +
	geom_line(size = 1) +
	facet_wrap(vars(metric)) +
	scale_y_continuous(sec.axis = dup_axis(), labels = percent_format(accuracy = 1)) +
	scale_x_date(date_labels = "%b\n%Y", date_breaks = "4 months", expand = expansion(mult = c(.03, .15))) +
	scale_color_manual(values = covidmn_colors) +
	theme_covidmn() +
	theme(axis.ticks.x = element_line(),
		  axis.title = element_blank(),
		  plot.subtitle = element_markdown(lineheight = 1.1),
		  legend.position = "none") +
	labs(title = "Observed vaccine effectiveness in Minnesota",
		 subtitle = "COVID prevalence among <span style = 'color:#56B4E9'>fully vaccinated</span> and <span style = 'color:#E69F00'>boosted</span> adults, compared to <br>rates among the unvaccinated",
		 caption = caption)
fix_ratio(p) %>% image_write(here("images/breakthrough-effectiveness.png"))