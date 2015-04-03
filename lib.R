library("ggplot2")
library("plyr")

system("python write_csv.py")
d <- read.csv("database.csv", stringsAsFactors = F)
d$rating[is.na(d$rating)] <- 0
d$play_count[is.na(d$play_count)] <- 0
str(d)
cond <- as.data.frame(table(d$rating))
cond$weight <- c(0, 1, 10, 20, 50, 100)
cond$selected <- ceiling(cond$Freq * cond$weight / sum(cond$weight))
names(cond)[names(cond) == "Var1"] <- "rating"
cond$last_play_days <- c(9, 8, 7, 6, 5, 4)
print(cond)
d <- d[order(d$rating), ]
d$id_by_rating <- 1:nrow(d)
d$play_date_time <- strptime(d$play_date_utc, "%Y-%m-%d %H:%M:%S", tz = "UTC")
d <- d[, !names(d) %in% c("play_date", "play_date_utc")]

PlotPlayCounts <- function(d, filename){
    print(mean(d$rating))
    g <- ggplot(d, aes(factor(rating), play_count)) +
         geom_boxplot()
    ggsave(filename, g, width = 7, height = 7)
}

PlayCountsSim <- function(d, days, cond, num){
    # d : data frame
    # days : number of the total days of the simulation
    # cond : dataframe of conditions
    # num : number of songs to be played each day
    for (i in 1:days){
        print(i)
        today <- as.POSIXlt(Sys.time(), "UTC") + i * 86400
        d$days_from_last_play <- difftime(today, d$play_date_time, units = "days")
        s <- split(d, list(d$rating))
        l <- lapply(s, function(x){
            c <- cond[cond$rating == x$rating[1], ]
            x <- x[x$days_from_last_play > c$last_play_days[1] | is.na(x$days_from_last_play), ]
            x[sample(nrow(x), c$selected[1]), ]
        })
        d.selected <- ldply(l, data.frame)
        ids <- d.selected[sample(nrow(d.selected), num), ]$id_by_rating
        d[d$id_by_rating %in% ids, ]$play_date_time <- today
        plays <- d[d$id_by_rating %in% ids, ]$play_count
        d[d$id_by_rating %in% ids, ]$play_count <- plays + 1
    }
    dput(d, file = "d.sim.R")
}


# PlayCountsSim(d, 10000, cond, 20)
d.sim <- dget("d.sim.R")
PlotPlayCounts(d, "PlayCountsNow.jpg")
PlotPlayCounts(d.sim, "PlayCountsSim.jpg")
