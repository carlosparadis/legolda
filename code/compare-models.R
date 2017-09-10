# Compare LDA models
## @knitr color-distribution
lda_models <- readRDS(here::here("inst", "data", "lda_models_all.RDS"))

set_topics <- lda_models %>%
  purrr::map(function(x) {
    class(x) <- "LDA"
    x
  }) %>%
  purrr::map(tidytext::tidy, matrix = "gamma")

# Total frequency used in relevance score
word_freq <- set_colors %>%
  count(rgba) %>%
  mutate(percent = n / nrow(set_colors))

# Create palette
pal <- unique(set_colors$rgba)
names(pal) <- unique(pal)

# Plot weighted relevance of terms/colors for each topic
plot_relevance <- function(top_terms, bgcol) {
 
  ntopics <- max(top_terms$topic)
  subtitle <- paste0("Weighted color distribution for ", ntopics, " topics")

  top_terms %>%
    ggplot(aes(x = -order, y = relevance, fill = term)) +
    labs(
      x = "", y = "Relevance",
      title = "Lego color topics",
      subtitle = subtitle
    ) +
    geom_col(show.legend = FALSE) +
    facet_wrap(~topic, scales = "free", nrow = 5) +
    scale_fill_manual(values = pal) +
    coord_flip() +
    theme_bar(bgcol) +
    theme(
      axis.text.x = element_blank(),
      axis.text.y = element_blank(),
      panel.grid.major.x = element_blank()
    )
}

top_list <- lda_models %>% 
  map(legolda::top_terms, lambda = 0.7, nterms = 7, freq = word_freq)

bgcol = "#a8a4a2"
plot_relevance(top_list[[1]], bgcol) # 20 topics
plot_relevance(top_list[[3]], bgcol) # 40 topics
plot_relevance(top_list[[5]], bgcol) # 60 topics

## @knitr topic-sets-table
docs <- lapply(lda_models, function(x) {
  class(x) <- "LDA"
  x
}) %>%

purrr::map(tidytext::tidy, matrix = "gamma")

# Which sets are most associated with a topic
topic_num <- 37
model_num <- 4

view_topic <- docs[[model_num]] %>%
  filter(topic == topic_num) %>%
  arrange(desc(gamma)) %>%
  head(10) %>%
  mutate(set_num = document, gamma = round(gamma, 2)) %>%
  left_join(sets_df, by = "set_num") %>%
  mutate(set_name = stringr::str_sub(name, 1, 20)) %>%
  select(topic, gamma, set_name, set_num, theme_id, year, num_parts) %>%
  left_join(theme_df, by = c("theme_id" = "id")) %>%
  mutate(theme_name = name) %>%
  select(topic, gamma, set_name, set_num, theme_name, theme_id, year, num_parts)

knitr::kable(view_topic, caption = "Sets most associated with topic 37")

## @knitr waffle-topic
library(waffle)
plot_topic <- docs[[model_num]] %>%
  dplyr::filter(topic == topic_num) %>%
  dplyr::arrange(desc(gamma)) %>%
  head(20)


waffle_prep <- function(document, sets) {
  document$set_num <- document$document
  document %>%
    left_join(sets, by = "set_num") %>%
    select(set_num, name, theme, year, rgba) %>%
    group_by(theme, name, set_num, year) %>%
    tidyr::nest() %>%
    mutate(counts = purrr::map(data, table))
}

bgcol <- "#e8e4e2"
w1 <- waffle_prep(plot_topic[5, ], set_colors)
w2 <- waffle_prep(plot_topic[6, ], set_colors)
w3 <- waffle_prep(plot_topic[7, ], set_colors)
w4 <- waffle_prep(plot_topic[8, ], set_colors)

waffle::iron(
  waff(w1, size = 0.5, rows = 1, nchr = 20, bgcol = bgcol),
  waff(w2, size = 2,   rows = 1, nchr = 13, bgcol = bgcol),
  waff(w3, size = 0.2, rows = 4, nchr = 20, bgcol = bgcol),
  waff(w4, size = 0.2, rows = 3, nchr = 13, bgcol = bgcol)
)

## @knitr topic-sets-table2

# Which sets are most associated with a topic
topic_num <- 19
model_num <- 4

view_topic <- docs[[model_num]] %>%
  filter(topic == topic_num) %>%
  arrange(desc(gamma)) %>%
  head(10) %>%
  mutate(set_num = document, gamma = round(gamma, 2)) %>%
  left_join(sets_df, by = "set_num") %>%
  mutate(set_name = stringr::str_sub(name, 1, 20)) %>%
  select(topic, gamma, set_name, set_num, theme_id, year, num_parts) %>%
  left_join(theme_df, by = c("theme_id" = "id")) %>%
  mutate(theme_name = name) %>%
  select(topic, gamma, set_name, set_num, theme_name, theme_id, year, num_parts)

knitr::kable(view_topic, caption = paste0("Sets most associated with topic ", topic_num))

## @knitr waffle-topic2
topic_num <- 19
plot_topic <- docs[[model_num]] %>%
  dplyr::filter(topic == topic_num) %>%
  dplyr::arrange(desc(gamma)) %>%
  head(20)
# plot_topic

waffle_prep <- function(document, sets) {
  document$set_num <- document$document
  document %>%
    left_join(sets, by = "set_num") %>%
    select(set_num, name, theme, year, rgba) %>%
    group_by(theme, name, set_num, year) %>%
    tidyr::nest() %>%
    mutate(counts = purrr::map(data, table))
}

w1 <- waffle_prep(plot_topic[5, ], set_colors)
w2 <- waffle_prep(plot_topic[6, ], set_colors)
w3 <- waffle_prep(plot_topic[7, ], set_colors)
w4 <- waffle_prep(plot_topic[8, ], set_colors)

waffle::iron(
  waff(w1,  size = 0.5, rows = 3, nchr = 20, bgcol = bgcol),
  waff(w2,  size = 0.5, rows = 1, nchr = 13, bgcol = bgcol),
  waff(w3,  size = 0.5, rows = 1, nchr = 20, bgcol = bgcol),
  waff(w4,  size = 0.5, rows = 1, nchr = 13, bgcol = bgcol)
)


## @knitr topic-sets-table3

# Which sets are most associated with a topic
topic_num <- 2
model_num <- 4

view_topic <- docs[[model_num]] %>%
  filter(topic == topic_num) %>%
  arrange(desc(gamma)) %>%
  head(10) %>%
  mutate(set_num = document, gamma = round(gamma, 2)) %>%
  left_join(sets_df, by = "set_num") %>%
  mutate(set_name = stringr::str_sub(name, 1, 20)) %>%
  select(topic, gamma, set_name, set_num, theme_id, year, num_parts) %>%
  left_join(theme_df, by = c("theme_id" = "id")) %>%
  mutate(theme_name = name) %>%
  select(topic, gamma, set_name, set_num, theme_name, theme_id, year, num_parts)

knitr::kable(view_topic, caption = paste0("Sets most associated with topic ", topic_num))


## @knitr waffle-topic3
topic_num <- 2
plot_topic <- docs[[model_num]] %>%
  dplyr::filter(topic == topic_num) %>%
  dplyr::arrange(desc(gamma)) %>%
  head(20)
# plot_topic

waffle_prep <- function(document, sets) {
  document$set_num <- document$document
  document %>%
    left_join(sets, by = "set_num") %>%
    select(set_num, name, theme, year, rgba) %>%
    group_by(theme, name, set_num, year) %>%
    tidyr::nest() %>%
    mutate(counts = purrr::map(data, table))
}

w1 <- waffle_prep(plot_topic[5, ], set_colors)
w2 <- waffle_prep(plot_topic[6, ], set_colors)
w3 <- waffle_prep(plot_topic[7, ], set_colors)
w4 <- waffle_prep(plot_topic[8, ], set_colors)

waffle::iron(
  waff(w1,  size = 0.5, rows = 1, nchr = 20, bgcol = bgcol),
  waff(w2,  size = 0.2, rows = 3, nchr = 20, bgcol = bgcol),
  waff(w3,  size = 0.5, rows = 6, nchr = 20, bgcol = bgcol),
  waff(w4,  size = 0.5, rows = 4, nchr = 20, bgcol = bgcol)
)



## @knitr topic-sets-table4

# Which sets are most associated with a topic
# Compare to 50-topic model num 37
topic_num <- 64
model_num <- 6

view_topic <- docs[[model_num]] %>%
  filter(topic == topic_num) %>%
  arrange(desc(gamma)) %>%
  head(10) %>%
  mutate(set_num = document, gamma = round(gamma, 2)) %>%
  left_join(sets_df, by = "set_num") %>%
  mutate(set_name = stringr::str_sub(name, 1, 20)) %>%
  select(topic, gamma, set_name, set_num, theme_id, year, num_parts) %>%
  left_join(theme_df, by = c("theme_id" = "id")) %>%
  mutate(theme_name = name) %>%
  select(topic, gamma, set_name, set_num, theme_name, theme_id, year, num_parts)

knitr::kable(view_topic, caption = paste0("Sets most associated with topic ", topic_num))


## @knitr waffle-topic4
topic_num <- 64
plot_topic <- docs[[model_num]] %>%
  dplyr::filter(topic == topic_num) %>%
  dplyr::arrange(desc(gamma)) %>%
  head(20)
# plot_topic

waffle_prep <- function(document, sets) {
  document$set_num <- document$document
  document %>%
    left_join(sets, by = "set_num") %>%
    select(set_num, name, theme, year, rgba) %>%
    group_by(theme, name, set_num, year) %>%
    tidyr::nest() %>%
    mutate(counts = purrr::map(data, table))
}

w1 <- waffle_prep(plot_topic[5, ], set_colors)
w2 <- waffle_prep(plot_topic[6, ], set_colors)
w3 <- waffle_prep(plot_topic[7, ], set_colors)
w4 <- waffle_prep(plot_topic[8, ], set_colors)

waffle::iron(
  waff(w1,  size = 0.5, rows = 3, nchr = 17, bgcol = bgcol),
  waff(w2,  size = 0.2, rows = 3, nchr = 20, bgcol = bgcol),
  waff(w3,  size = 0.5, rows = 2, nchr = 19, bgcol = bgcol),
  waff(w4,  size = 0.5, rows = 1, nchr = 16, bgcol = bgcol)
)


## @knitr topic-sets-table5
# Which sets are most associated with a topic
# Compare to 50-topic model num 37
topic_num <- 8
model_num <- 4

view_topic <- docs[[model_num]] %>%
  filter(topic == topic_num) %>%
  arrange(desc(gamma)) %>%
  head(10) %>%
  mutate(set_num = document, gamma = round(gamma, 2)) %>%
  left_join(sets_df, by = "set_num") %>%
  mutate(set_name = stringr::str_sub(name, 1, 20)) %>%
  select(topic, gamma, set_name, set_num, theme_id, year, num_parts) %>%
  left_join(theme_df, by = c("theme_id" = "id")) %>%
  mutate(theme_name = name) %>%
  select(topic, gamma, set_name, set_num, theme_name, theme_id, year, num_parts)

knitr::kable(view_topic, caption = paste0("Sets most associated with topic ", topic_num))


## @knitr waffle-topic5
topic_num <- 26
plot_topic <- docs[[model_num]] %>%
  dplyr::filter(topic == topic_num) %>%
  dplyr::arrange(desc(gamma)) %>%
  head(20)
# plot_topic

waffle_prep <- function(document, sets) {
  document$set_num <- document$document
  document %>%
    left_join(sets, by = "set_num") %>%
    select(set_num, name, theme, year, rgba) %>%
    group_by(theme, name, set_num, year) %>%
    tidyr::nest() %>%
    mutate(counts = purrr::map(data, table))
}

w1 <- waffle_prep(plot_topic[5, ], set_colors)
w2 <- waffle_prep(plot_topic[6, ], set_colors)
w3 <- waffle_prep(plot_topic[7, ], set_colors)
w4 <- waffle_prep(plot_topic[8, ], set_colors)

waffle::iron(
  waff(w1,  size = 0.5, rows = 3, nchr = 17, bgcol = bgcol),
  waff(w2,  size = 0.2, rows = 3, nchr = 20, bgcol = bgcol),
  waff(w3,  size = 0.5, rows = 2, nchr = 19, bgcol = bgcol),
  waff(w4,  size = 0.5, rows = 1, nchr = 16, bgcol = bgcol)
)

## @knitr topic-sets-table5

# Which sets are most associated with a topic
topic_num <- 3
model_num <- 6

view_topic <- docs[[model_num]] %>%
  filter(topic == topic_num) %>%
  arrange(desc(gamma)) %>%
  head(10) %>%
  mutate(set_num = document, gamma = round(gamma, 2)) %>%
  left_join(sets_df, by = "set_num") %>%
  mutate(set_name = stringr::str_sub(name, 1, 20)) %>%
  select(topic, gamma, set_name, set_num, theme_id, year, num_parts) %>%
  left_join(theme_df, by = c("theme_id" = "id")) %>%
  mutate(theme_name = name) %>%
  select(topic, gamma, set_name, set_num, theme_name, theme_id, year, num_parts)

knitr::kable(view_topic, caption = "Sets most associated with topic 37")

## @knitr waffle-topic5
library(waffle)
plot_topic <- docs[[model_num]] %>%
  dplyr::filter(topic == topic_num) %>%
  dplyr::arrange(desc(gamma)) %>%
  head(20)
# plot_topic

waffle_prep <- function(document, sets) {
  document$set_num <- document$document
  document %>%
    left_join(sets, by = "set_num") %>%
    select(set_num, name, theme, year, rgba) %>%
    group_by(theme, name, set_num, year) %>%
    tidyr::nest() %>%
    mutate(counts = purrr::map(data, table))
}

w1 <- waffle_prep(plot_topic[3, ], set_colors)
w2 <- waffle_prep(plot_topic[4, ], set_colors)
w3 <- waffle_prep(plot_topic[5, ], set_colors)
w4 <- waffle_prep(plot_topic[6, ], set_colors)

waffle::iron(
  waff(w1,  size = 0.5, rows = 1, nchr = 20, bgcol = bgcol),
  waff(w2,  size = 2, rows = 1, nchr = 13, bgcol = bgcol),
  waff(w3,  size = 0.2, rows = 1, nchr = 20, bgcol = bgcol),
  waff(w4,  size = 0.2, rows = 1, nchr = 13, bgcol = bgcol)
)