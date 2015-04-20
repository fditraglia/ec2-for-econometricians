library("parallel")

sim.rep <- function(n = 10, a = 1, b = 2){
  Sys.sleep(0.01) # wait for a hundredth of a second
  n * (a - b)^2
}

system.time(foo <- replicate(1000, sim.rep()))
system.time(bar <- mclapply(seq_len(1000), sim.rep, 
                            mc.cores = 8))
