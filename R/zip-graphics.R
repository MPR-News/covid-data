dir(here("images"), full.names = TRUE) %>% 
	file.info() %>% 
	filter(mtime >= today() - 7) %>% 
	rownames_to_column() %>%
	pull(rowname) %>%
	zip::zipr(zipfile = "current_charts.zip",
			  files = .,
			  root = here(),
			  include_directories = FALSE)