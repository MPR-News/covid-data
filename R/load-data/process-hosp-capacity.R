clean_hosp_capacity <- raw_hospital_data %>%
	filter(metric_type == "CAPACITY", bed_type != "Ventilators", GeographicName == "Minnesota") %>%
	pivot_wider(id_cols = date, names_from = bed_type, names_prefix = "avail_") %>% 
	janitor::clean_names() %>%
	left_join(raw_hospital_data %>%
			  	filter(metric_type == "IN USE", bed_type != "Ventilators", GeographicName == "Minnesota") %>%
			  	pivot_wider(id_cols = date, names_from = c(bed_type, is_covid), names_prefix = "inuse_") %>%
			  	janitor::clean_names(),
			  by = "date") %>%
	left_join(raw_hospital_data %>%
			  	filter(bed_type == "Ventilators", is.na(is_covid), metric_type != "CAPACITY", GeographicName == "Minnesota") %>%
			  	mutate(metric_type = case_when(metric_type == "AVAILABLE" ~ "avail", TRUE ~ "inuse")) %>%
			  	pivot_wider(id_cols = date, names_from = metric_type, names_glue = "{metric_type}_vents"),
			  by = "date") %>%
	left_join(raw_hospital_data %>% 
			  	filter(is_covid == "Surge", GeographicName == "Minnesota", metric_type != "IN USE") %>%
			  	pivot_wider(id_cols = date, names_from = units, names_prefix = "surge_") %>%
			  	janitor::clean_names(),
			  by = "date") %>%
	arrange(date) %>%
	mutate(icu_used_pct = (inuse_icu_covid + inuse_icu_non_covid) / avail_icu,
		   nonicu_used_pct =  (inuse_non_icu_covid + inuse_non_icu_non_covid) / avail_non_icu,
		   covid_pct_icu = inuse_icu_covid / (inuse_icu_covid + inuse_icu_non_covid),
		   covid_pct_nonicu = inuse_non_icu_covid / (inuse_non_icu_covid + inuse_non_icu_non_covid)) %>%
	select(date, contains("pct"), contains("inuse"), everything()) %>%
	write_csv(here("data/hospital_capacity.csv"))
