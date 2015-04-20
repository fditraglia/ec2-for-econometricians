out <- data.frame(1:10, 10:1)
Sys.sleep(30)
setwd("~/")
write.csv(out, file = 'results.csv')
