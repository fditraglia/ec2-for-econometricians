set.seed(1983)
x <- rnorm(10)
e <- rnorm(10)
y <- 0.5 + 2 * x
out <- data.frame(x, y)
Sys.sleep(30)
setwd("~/")
write.csv(out, file = 'regression.csv')
