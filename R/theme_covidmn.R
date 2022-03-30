update_geom_defaults("col", list(fill = "black"))
update_geom_defaults("bar", list(fill = "black"))
update_geom_defaults("line", list(color = "black"))
update_geom_defaults("point", list(color = "black"))
update_geom_defaults("text", list(fontface = "bold"))
update_geom_defaults("label", list(fontface = "bold"))

theme_covidmn <- function(base_size = 12) {
	theme_grey(base_size = base_size) %+replace%
		theme(panel.background = element_rect(fill = "white", color = NA), # Set plot background to white, hide border
			  plot.background = element_rect(fill = "white", size = 0), # Set the broader chart's background to white
			  plot.margin = margin(t = 20, l = 30, r = 30, b = 10), # Adjust margins
			  panel.spacing.x = unit(2, "lines"), # Define spacing between facets
			  panel.grid = element_blank(), # Remove gridlines
			  plot.title = element_text(face = "bold", 
			  						  size = 28, # Set size
			  						  hjust = 0, # Define horizontal justification (left)
			  						  vjust = 1, # Define vertical justification (bottom)
			  						  margin = margin(b = 18)), # Add a bottom margin
			  plot.subtitle = element_text(size = 20,
			  							 hjust = 0,
			  							 vjust = 1,
			  							 margin = margin(b = 10)),
			  plot.caption = element_text(face = "italic",
			  							hjust = 0,
			  							vjust = 1,
			  							margin = margin(b = 10)),
			  # Align left
			  plot.title.position = "plot",
			  plot.caption.position = "plot",
			  # Format axis labels
			  axis.text = element_text(size = 16),
			  axis.text.x = element_text(margin = margin(b = 10)),
			  # Format axis titles
			  axis.title = element_text(size = 18, 
			  						  hjust = 0.5,
			  						  vjust = 0.5),
			  axis.ticks = element_blank(), # Remove tick marks
			  # Format facet labels
			  strip.background = element_rect(fill = NA, # No fill
			  								color = NA),  # No border
			  strip.text = element_text(face = "bold",
			  						  size = 20,
			  						  margin = margin(b = 5)),
			  legend.key = element_blank(), # No box around legend
			  legend.title = element_text(size = 18), # Format legend title
			  legend.text = element_text(size = 16), # Format legend text
			  legend.position = "top", # Put legends on top of graph
			  complete = TRUE) # Done defining theme
}

fix_ratio <- function(p, ratio = "rect") {
	plot <- tempfile()
	#rect
	if(ratio == "rect") {
		ggsave(p, filename = plot, device = "png", width = 10, height = 7.5)
		image_read(plot) %>% image_scale("2000x1500")
	} else if(ratio == "square") {
		ggsave(p, filename = plot, device = "png", width = 10, height = 10)
		image_read(plot) %>% image_scale("2000x2000")
	} else if(ratio == "short") {
		ggsave(p, filename = plot, device = "png", width = 10, height = 4)
		image_read(plot) %>% image_scale("2000x800")
	}
}

# Sub-theme for line charts
theme_covidmn_line <- function(base_size = 12) {
	list(theme_covidmn(base_size = base_size) %+replace% # Use theme_covidmn as our base
		 	theme(axis.title.x = element_blank(), # Hid x-axis title
		 		  axis.ticks.x = element_line())) # Show x-axis ticks
}

# Sub-theme for flipped bar charts
theme_covidmn_bar <- function(base_size = 12) {
	list(theme_covidmn(base_size = base_size) %+replace% # Use theme_covidmn as our base
		 	theme(axis.title = element_blank(),
		 		  axis.text.x = element_blank()),
		 scale_y_continuous(expand = expansion(mult = 0)),
		 coord_flip())
}

# Color palette by Masataka Okabe and Kei Ito: https://jfly.uni-koeln.de/color/
covidmn_colors <- list(c(230, 159, 0), # Orange
	 c(86, 180, 233), # Sky Blue
	 c(0, 158, 115), # Bluish Green
	 c(213, 94, 0), # Vermillion
	 c(0, 114, 176), # Blue
	 c(240, 199, 66), # Yellow
	 c(204, 121, 167), # Reddish Purple
	 c(0, 0, 0)) %>% # Black
	map(~rgb(red = .x[1], green = .x[2], blue = .x[3],
			 maxColorValue = 255)) %>%
	reduce(c)