
# Absolute and relative number of children expected to live 
# longer than their mothers. (A) Number of children expected 
# to outlive an average woman. Values in the vertical axis 
# show the number of children alive at the time of a woman's 
# death if she survives to the life expectancy in her cohort 
# and country of birth. (B) Children expected to outlive a 
# woman as a fraction of her cohort's TFR. Higher values indicate 
# that a larger fraction of a woman's offspring is expected to 
# live longer than her, independently of the prevalent levels 
# of fertility. The solid lines represent regional median values 
# and the bands the variability among countries in each region.

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# A. Plot CL and CS in four facets ~~~~ ----
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Data requirements (20190827):
# sum_ecl_ctfr  (3.6.1_ECL_share_outlive_mother.R)
# cl_ex_pop_country (3.7_ECL_by_mother_ex.R)
# cs_ex_pop_country (4.6_ECS_by_mother_ex.R)
# ecl_ctfr (3.6.1_ECL_share_outlive_mother.R)
# sum_cl_ex
# sum_cs_ex
# sum_ecs_ctfr
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# All are cut when mother's age is equal to regional life expectancy.
# The panels
# A   B
# C   D

# represnt:

# A) CL (tally at woman's death)
# B) CS (tally at woman's death)
# C) CL (share of CTFR)
# D) CS (share of CTFR)

# 0. Plotting params ----

lower_year <- 1950
# upper_year <- 1999
upper_year <- 2000

point_br <- c(seq(lower_year, upper_year, 10) , upper_year)
col_lab <- ""

# 0.2. Draft paper and presentation format (large)

width <- 16
height <- 10
base_size <- 14
region_line_size <- 1
point_size <- 4

# 1. Merge dfs for tally part ----

levels <- c("a. Expected number of children", "b. Expected number as fraction of TFR")
levels <- factor(levels, levels = levels)
measures <- c("Child death", "Child survival")

tally_df <-
  rbind(
    # Child loss
    sum_cl_ex %>% 
      mutate(
        level = levels[1]
        , measure = measures[1]
             ) 
    # Child survival
    , sum_cs_ex %>% 
      mutate(
        level = levels[1]
        , measure = measures[2]
      ) 
  ) %>% 
  select(region, cohort, value = median, low = low_iqr, high = high_iqr, level, measure)

# 2. Merge with dfs of 'share' ====

# Share of cohort's TFR, that is.

tally_share <- rbind(
  tally_df
  , sum_ecl_ctfr %>% 
    mutate(
      level = levels[2]
      , measure = measures[2]
    ) %>% 
    select(region, cohort, value, low = low_iqr, high = high_iqr, level, measure )
  , sum_ecs_ctfr %>% 
    mutate(
      level = levels[2]
      , measure = measures[1]
    ) %>% 
    select(region, cohort, value, low = low_iqr, high = high_iqr, level, measure)
)
# ! 4. Plot with facets ----

# Add facet Label
coh <- paste0(c(lower_year, upper_year), " birth cohort")

# f_lab <- data.frame(
#   x = 1955
#   , y = c(5.9, 0.97)
#   , label = letters[1:2]
#   , level = levels
# )

p_cs_number_share <-
  tally_share %>% 
  filter(!region %in% regions_to_remove) %>% 
  filter(measure %in% measures[2]) %>% 
  mutate(region = factor(as.character(region), levels = regions_long)) %>% 
  ggplot() +
  # Region summary lines
  geom_line(
    aes(x = cohort, y = value, group = region, colour = region)
    , size = region_line_size
    , show.legend = F
  ) +
  # Plot ECL quantiles as bands
  geom_ribbon(
    aes(x = cohort, ymin = low, ymax = high, group = region, fill = region)
    , alpha = 0.4, show.legend = F
  ) +
  # Plot ECL shapes to help distinguish regions
  geom_point(
    aes(x = cohort, y = value, group = region, colour = region
        , shape = region
    )
    , size = point_size
    , data = . %>% filter(cohort %in% c(lower_year, 1975, upper_year))
  ) +
  # Add facet numbers
  # geom_text(aes(x = x, y = y, label = label), data = f_lab, size = 6) +
  scale_x_continuous(
    "Woman's Birth Cohort"
    # , breaks = c(1950, 1960, 1985, 2000)
    # , breaks = pretty_breaks(n = 3)
    , breaks = seq(lower_year, 2000, 10)
    # , labels = c(lower_year, seq(60, 90, 10), 2000)
    ) +
  scale_y_continuous(
    "Children Outlive Mother"
    , br = trans_breaks(identity, identity, 4)
    , labels = function(x) gsub("^0", "", as.character(x))
    ) +
  scale_color_discrete(col_lab, br = regions_long, labels = regions_short) +
  scale_fill_discrete(col_lab, br = regions_long, labels = regions_short) +
  scale_shape_discrete(col_lab, br = regions_long, labels = regions_short) +
  scale_size_continuous("Population share") +
  facet_wrap(level ~ ., scales = 'free_y') +
  theme_bw(base_size = base_size) +
  theme(
    legend.position = "bottom"
    # Remove space over legend
    , legend.margin=margin(t=-0.25, r=0.5, b=0, l=0, unit="cm")
    # Remove space between legends
    , legend.key.size = unit(0.1, "cm")
    # Move y axis closer to the plot
    , axis.title.y = element_text(margin = margin(t = 0, r = - 0.5, b = 0, l = 0), face="bold")
    , axis.title.x = element_text(face="bold")
    , plot.margin = unit(c(t=0.2, r=0.25, b=0.1, l=0.1), unit="cm")
    # get rid of facet boxes
    , strip.background = element_blank()
    , strip.text = element_text(face="bold")
    # Remove spacing between facets
  )

p_cs_number_share

# ECS_expected_share_TFR
ggsave(paste0("../../Output/fig5_outlive_mother.pdf"), p_cs_number_share, width = width+1, height = height, units = "cm")

print("Figure 5 saved to ../../Output")