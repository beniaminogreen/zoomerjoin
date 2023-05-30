library(zoomerjoin)
library(fuzzyjoin)
library(tidyverse)
library(microbenchmark)
library(profmem)

data <- read_csv("bonica.csv")
data_1 <- as.data.frame(sample_n(data, 10^6))
names(data_1) <- c("id_1", "name")
data_2 <- as.data.frame(sample_n(data, 10^6))
names(data_2) <- c("id_2", "name")

fuzzy_jaccard_bench <- function(n){
  time <- microbenchmark(
    stringdist_inner_join(data_1[1:n, ],
      data_2[1:n, ],
      method = "jaccard",
      max_dist = .6,
      q = 4
    ),
    times = 5
  )$time %>%
    mean()

  mem <- profmem(stringdist_inner_join(data_1[1:n, ],
    data_2[1:n, ],
    method = "jaccard",
    max_dist = .6,
    q = 4
  )) %>%
    total()

  return(c(time = time, memory = mem))
}


zoomer_jaccard_bench <- function(n) {
  time <- microbenchmark(
    jaccard_inner_join(data_1[1:n, ], data_2[1:n, ],
      by = "name", band_width = 11,
      n_bands = 350, threshold = .7,
      n_gram_width = 4
    ),
    times = 5
  )$time %>%
    mean()

  mem <- profmem(
    jaccard_inner_join(data_1[1:n, ], data_2[1:n, ],
      by = "name", band_width = 11,
      n_bands = 350, threshold = .7,
      n_gram_width = 4
    )
  ) %>%
    total()

  return(c(time = time, memory = mem))
}

n <- seq(500, 5000, 250)
names(n) <- n

fuzzy_jacard_benches <- map_df(n, fuzzy_jaccard_bench, .id="n")
zoomer_jacard_benches <- map_df(n, zoomer_jaccard_bench, .id="n")
fuzzy_jacard_benches$package = "fuzzyjoin"
zoomer_jacard_benches$package = "zoomerjoin"

jaccard_benches <- bind_rows(fuzzy_jacard_benches, zoomer_jacard_benches)
jaccard_benches$join_type = "Jaccard Distance"

n <- 10^5
p <- 50
X <- matrix(rnorm(n * p), n, p)
X_1 <- as.data.frame(X)
X_2 <- as.data.frame(X + .000000001)

fuzzy_euclid_bench <- function(n) {
  time <- microbenchmark(
    distance_join(X_1[1:n, ], X_2[1:n, ], max_dist = .1, method = "euclidean"),
    times = 5
  )$time %>%
    mean()

  mem <- total(profmem(
    distance_join(X_1[1:n, ], X_2[1:n, ], max_dist = .1, method = "euclidean")
  ))

  return(c(time = time, memory = mem))
}

zoomer_euclid_bench <- function(n) {
  time <- microbenchmark(
    euclidean_inner_join(X_1[1:n, ], X_2[1:n, ],
      threshold = .1, n_bands = 90,
      band_width = 2, r = .1
    ),
    times = 5
  )$time %>%
    mean()

  mem <- profmem(euclidean_inner_join(X_1[1:n, ], X_2[1:n, ],
    threshold = .1, n_bands = 90,
    band_width = 2, r = .1
  )) %>%
    total()

  return(c(time = time, memory = mem))
}


n <- seq(250, 5000, 250)
names(n) <- n

fuzzy_euclid_benches <- map_df(n, fuzzy_euclid_bench, .id="n")
zoomer_euclid_benches <- map_df(n, zoomer_euclid_bench, .id="n")
fuzzy_euclid_benches$package = "fuzzyjoin"
zoomer_euclid_benches$package = "zoomerjoin"

euclid_benches <- bind_rows(fuzzy_euclid_benches, zoomer_euclid_benches)
euclid_benches$join_type = "Euclidean Distance"

sim_data <- bind_rows(euclid_benches, jaccard_benches) %>%
    pivot_longer(c(time, memory)) %>%
    mutate(value = ifelse(name =="time", value / 10^9, value/10^6))

write_csv(sim_data, "sim_data.csv")

sim_data <- read_csv("sim_data.csv")
sim_data  %>%
    mutate(
           name = ifelse(name == "time", "Time Usage (s)", "Memory Usage (MB)"),
           join_type = ifelse(join_type == "Jaccard Distance",
                              "Jaccard Distance Join",
                              "Euclidean Distance Joins"),
           ) %>%
    ggplot(aes(x=as.numeric(n), y=value, col = package, linetype = package)) +
    geom_point() +
    geom_line() +
    facet_wrap(~ join_type + name, scales = 'free') +
    ylab("Time (s) / memory (MB)") +
    xlab("Number of Rows in Each Dataset") +
    theme_bw() +
    guides(
           color=guide_legend(title="Software Package"),
           linetype=guide_legend(title="Software Package"),
    )
ggsave("benchmarks.png")



