# Note that, since it uses forking, mclapply only works on Mac/Linux
library("parallel")

sim.study <- function(n, a, b){
  Sys.sleep(1) # wait for 1 second
  n * (a - b)^2
}

n.values <- c(10, 100)
a.values <- c(0.1, 0.2, 0.3, 0.4)
b.values <- c(1, 2)

params <- expand.grid(n = n.values,
                      a = a.values,
                      b = b.values)

system.time(foo <- mcmapply(sim.study, params$n, params$a, params$b, 
                            mc.cores = 8))
system.time(bar <- mapply(sim.study, params$n, params$a, params$b))


