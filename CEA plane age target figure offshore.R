#'===========================================================================================================
#' This script creates a cost-effectivenes plane showing incremental cost and 
#' effectiveness (in QALYs) of different intervention offshore strategies.
#' To create the rds files that this script can import you need to run to
#'the "CEA plane age target" first
#' to generate the results.
#' 
#' Inputs:
#' Need to run the "CEA plane age target" first, which can be used to create four 
#' rds files (offshore with and wihout emigration) that this code then uses.
#' 
#' Output:
#' tiff files
#' 
#' Coding style
#' https://google.github.io/styleguide/Rguide.xml

#' LOAD LIBRARIES ===========================================================================================

library(xlsx)
library(data.table)
library(ggplot2)
library(RColorBrewer)
library(ggrepel)
library(scales)
library(egg)
library(cowplot)
library(grid)
library(gridExtra)
# Need to obtain chance of having sae with different treatment regimens.
# I have researched this and it is in an excel file in "Model parameters"

ylimupper <- 800000/1000
ylimlower <- -500000/1000
xlimupper <- -5
xlimlower <- 100
 
# Reading in the data 
setwd("H:/Katie/PhD/CEA/MH---CB-LTBI")
# setwd("C:/Users/Robin/Documents/Katie/PhD/CEA/LTBI-Aust-CEA")
data <- readRDS("Data/agetargetoffshore.rds")
data <- as.data.table(data)


# Write the table to clipboard so I can paste it into Excel
write.table(data, "clipboard", sep = "\t", row.names = FALSE)

data <- subset(data, strategy != "0_12...rds")
data <- data[, c("age.low", "age.high", "Percentage.of.all.TB.cases.prevented",
                 "Incremental.QALYS", "total.additional.cost")]
setnames(data, "Incremental.QALYS", "incremental.qalys")
setnames(data, "total.additional.cost", "incremental.cost")
setnames(data, "Percentage.of.all.TB.cases.prevented", "tb.prev.percent")

data[ , strategy := do.call(paste, c(.SD, sep = "-")), .SDcols = c("age.low", "age.high")]

percent <- function(x, digits = 1, format = "f", ...) {
  paste0(formatC(x, format = format, digits = digits, ...), "%")
}

data$tb.prev.percent <- percent(data$tb.prev.percent)

data$strategy <- factor(data$strategy,levels = c("11-19", "20-29", "30-39",
                                                 "40-59", "60-69", 
                                                 "11-35", "11-65", "36-65"))

# Get the colour palatte
# I need 4 fill colours
getPalette <- brewer.pal(5, "Spectral")
getPalette 
getPalette <- c(getPalette, "gray50")
getPalette

textsize <- 17
geomtextsize <- 5
options(scipen = 5)
#dev.off()
myplot1 <-  
  ggplot(data, aes(x = incremental.qalys, y = incremental.cost/1000,
                   fill = strategy,
                   shape =  strategy)) +
  geom_point(size = 7, alpha = 1, na.rm = T) +
  geom_vline(xintercept = 0, color = "black") +
  geom_hline(yintercept = 0, color = "black") +
  geom_abline(intercept = 0, slope = (45000/1000)/1,
              colour = "gray65",
              size = 1, lty = 2) +
  geom_abline(intercept = 0, slope = (75000/1000)/1,
              colour = "gray65", 
              size = 1) +
  labs(x = "Incremental QALYs", 
       y = "Incremental cost (AUD$thousands)",
       fill = "Age group\n(years)",
       shape = "Age group\n(years)") +
  scale_shape_manual(values = c(21, 24,
                                22, 25,
                                23, 7,
                                12, 14)) +
  scale_fill_manual(values = c(getPalette, getPalette)) +
  geom_text_repel (aes(label = tb.prev.percent),
                   hjust = 0.5, vjust = -1,
                   segment.color = "transparent",
                   size = geomtextsize) +
  scale_y_continuous(breaks = seq(-1000000/1000, 10000000/1000, 200000/1000),
                     label = comma) +
  scale_x_continuous(breaks = seq(-20, 500, 20)) +
  theme_bw() +
  coord_cartesian(xlim = c(xlimlower, xlimupper), 
                  ylim = c(ylimlower, ylimupper)) +
  theme(text = element_text(size = textsize),
        # axis.title.x = element_blank(),
        legend.position = "none",
        panel.border = element_blank())


tiff('Figures/ceaplaneagetalk.tiff', units = "in", width = 15, height = 7,
     res = 200)
myplot1
dev.off()



# Reading in the data without emigration
data <- readRDS("Data/agetargetoffshorenoemig.rds")
data <- as.data.table(data)

# Write the table to clipboard so I can paste it into Excel
write.table(data, "clipboard", sep = "\t", row.names = FALSE)

data <- subset(data, strategy != "0_12...rds")
data <- data[, c("age.low", "age.high", "Percentage.of.all.TB.cases.prevented",
                 "Incremental.QALYS", "total.additional.cost")]
setnames(data, "Incremental.QALYS", "incremental.qalys")
setnames(data, "total.additional.cost", "incremental.cost")
setnames(data, "Percentage.of.all.TB.cases.prevented", "tb.prev.percent")

data[ , strategy := do.call(paste, c(.SD, sep = "-")), .SDcols = c("age.low", "age.high")]

percent <- function(x, digits = 1, format = "f", ...) {
  paste0(formatC(x, format = format, digits = digits, ...), "%")
}

data$tb.prev.percent <- percent(data$tb.prev.percent)

data$strategy <- factor(data$strategy,levels = c("11-19", "20-29", "30-39",
                                                 "40-59", "60-69", 
                                                 "11-35", "11-65", "36-65"))

# Get the colour palatte
# I need 4 fill colours
getPalette<-brewer.pal(5, "Spectral")
getPalette

options(scipen = 5)
#dev.off()
myplot2 <-  
  ggplot(data, aes(x = incremental.qalys, y = incremental.cost/1000,
                   fill = strategy,
                   shape =  strategy)) +
  geom_point(size = 7, alpha = 1, na.rm = T) +
  geom_vline(xintercept = 0, color = "black") +
  geom_hline(yintercept = 0, color = "black") +
  geom_abline(intercept = 0, slope = (45000/1000)/1,
              colour = "gray65",
              size = 1, lty = 2) +
  geom_abline(intercept = 0, slope = (75000/1000)/1,
              colour = "gray65", 
              size = 1) +
  labs(x = "Incremental QALYs", 
       y = "Incremental cost (in thousands, AUD$)",
       fill = "Age group\n(years)",
       shape = "Age group\n(years)") +
  scale_shape_manual(values = c(21, 24,
                                22, 25,
                                23, 7,
                                12, 14)) +
  scale_fill_manual(values = c(getPalette, getPalette)) +
  geom_text_repel (aes(label = tb.prev.percent),
                   hjust = 0.5, vjust = -1,
                   segment.color = "transparent",
                   size = geomtextsize) +
  scale_y_continuous(breaks = seq(-1000000/1000, 600000/1000, 200000/1000),
                     label = comma) +
  scale_x_continuous(breaks = seq(-20, 500, 20)) +
  theme_bw() +
  coord_cartesian(xlim = c(xlimlower, xlimupper), 
                  ylim = c(ylimlower, ylimupper)) +
  theme(text = element_text(size = textsize),
        axis.title.y = element_blank(),
        panel.border = element_blank())

# Extract legend
grobs <- ggplotGrob(myplot2)$grobs
legend <- grobs[[which(sapply(grobs, function(x) x$name) == "guide-box")]]

# Resave the plot without the legend
myplot2 <-  
  ggplot(data, aes(x = incremental.qalys, y = incremental.cost/1000,
                   fill = strategy,
                   shape =  strategy)) +
  geom_point(size = 7, alpha = 1, na.rm = T) +
  geom_vline(xintercept = 0, color = "black") +
  geom_hline(yintercept = 0, color = "black") +
  geom_abline(intercept = 0, slope = (45000/1000)/1,
              colour = "gray65",
              size = 1, lty = 2) +
  geom_abline(intercept = 0, slope = (75000/1000)/1,
              colour = "gray65", 
              size = 1) +
  labs(x = "Incremental QALYs", 
       y = "Incremental cost (in thousands, AUD$)",
       fill = "Age group\n(years)",
       shape = "Age group\n(years)")  +
  scale_shape_manual(values = c(21, 24,
                                22, 25,
                                23, 7,
                                12, 14)) +
  scale_fill_manual(values = c(getPalette, getPalette)) +
  geom_text_repel (aes(label = tb.prev.percent),
                   hjust = 0.5, vjust = -1,
                   segment.color = "transparent",
                   size = geomtextsize) +
scale_y_continuous(breaks = seq(-1000000/1000, 600000/1000, 200000/1000),
                   label = comma) +
  scale_x_continuous(breaks = seq(-20, 500, 20)) +
  theme_bw() +
  coord_cartesian(xlim = c(xlimlower, xlimupper), 
                  ylim = c(ylimlower, ylimupper)) +
  theme(text = element_text(size = textsize),
        axis.title.y = element_blank(),
        legend.position = "none",
        panel.border = element_blank())


plotty <- plot_grid(myplot1, myplot2, legend, ncol = 3, 
          rel_widths = c(1, 1, .3),
          labels = c("A)", "B)", " "))

tiff('Figures/ceaplaneageoffshore.tiff', units = "in", width = 15, height = 5,
     res = 200)
plotty
dev.off()

# geom_text(aes(label="More costly\nLess effective", x = -Inf, y = Inf),
#           hjust = -0.03, vjust = 1.5, size = textsize, 
#           colour = "black") +
# geom_text(aes(label="More costly\nMore effective", x = Inf, y = Inf),
#           hjust = 1, vjust = 1.5, size = textsize, 
#           colour = "black") +
# geom_text(aes(label="Less costly\nLess effective", x = -Inf, y = -Inf),
#           hjust = -0.03, vjust = -0.7, size = textsize, 
#           colour = "black") +
# geom_text(aes(label="Less costly\nMore effective", x = Inf, y = -Inf),
#           hjust = 1, vjust = -0.7, size = textsize, 
#           colour = "black") +
