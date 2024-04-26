library(quantmod)
library(PerformanceAnalytics)
library(dygraphs)
library(pracma)
library(polynom)
library(ggplot2)
library(LaplacesDemon)
library("gridExtra")

#Computes the KL divergence of a dirichlet distribution with m=2 parameters.
KLDivergence_Dirchellete = function(coef1,coef2){
  integ = integrate(function(x) DirchelleteDensity(coef1,x)*log(DirchelleteDensity(coef1,x)/DirchelleteDensity(coef2,x)), lower = 0, upper = 1)
  return(integ$value)
}
#Density function of dirichlet
DirchelleteDensity = function(coef,x){
  coefficient = gamma(coef[1]+coef[2])/(gamma(coef[1])*gamma(coef[2]))
  return(coefficient*(x^(coef[1]-1))*(1-x)^(coef[2]-1))
}
#Gievn any candidate log optimal portfolio b, this function computes E(log(b^{T}X)) (the growth rate of b).
Expected_Log_Profit = function(b, alpha1, alpha2, offset1,offset2){
  integ = integrate(function(x) log(b*(x+offset1)+(1-b)*(1-x+offset2))*(DirchelleteDensity(c(alpha1,alpha2),x)), lower = 0, upper = 1)
  return(integ$value)
}
#Computes the log optimum distribution for m = 2 stocks generated from a dirichlet distribution with offsets (see below)
ComputeLogOptimumDirchellete2Stocks = function(alpha1,alpha2, offset1, offset2){
  optim = optimize(function(b) Expected_Log_Profit(b, alpha1,alpha2, offset1,offset2), maximum = TRUE, interval = c(0,1))
  return(optim)
}
LogOptimalDist = ComputeLogOptimumDirchellete2Stocks(1,1,0.51,0.49)
colors <- c("Stock 1" = "steelblue", "Stock 2" = "red",  "Log Optimal" = "green", "Close to Log Optimal" = 'black')
randomStocks = rdirichlet(10000, c(1,1))
randomStocks[,1] = randomStocks[,1] + 0.51
randomStocks[,2] = randomStocks[,2] + 0.49
profitLogOptimal = cumprod(randomStocks%*%c(LogOptimalDist$maximum, 1-LogOptimalDist$maximum))
profitNonOptimum = cumprod(randomStocks%*%c(0.6, 0.4))
profits = data.frame(profitLogOptimal = profitLogOptimal, profitNonOptimum = profitNonOptimum, stock1 = cumprod(randomStocks[,1]), stock2 = cumprod(randomStocks[,2]))
plot1 = ggplot(profits,aes(x=1:nrow(profits), col = legend)) + 
  geom_line(aes(y = stock1, color = "Stock 1"), size = 0.5) + 
  geom_line(aes(y = stock2, color = "Stock 2"), size = 0.5) +
  geom_line(aes(y = profitLogOptimal, color="Log Optimal"),size = 0.5)+
  geom_line(aes(y = profitNonOptimum, color="Close to Log Optimal"),size=0.5)+
  labs(x = "Time", y = "Profit",  color = "Legend")+ 
  scale_color_manual(values = colors)+
  theme(legend.position = c(0.25, 0.83))


#We now demonstrate Theorem 16.3.1 and show 1/nln(sn/sn*) <= 0 for large n 
profitRatio = function(profits1, profits2){
  n = length(profits1)
  ratio = rep(0,n)
  for(i in 1:n){
    ratio[i] = (1/i)*log((profits2[i]/profits1[i]))
  }
  return(ratio)
}
ratioProfits = data.frame(profitRatio = profitRatio(profitLogOptimal,profitNonOptimum))
plot2 = ggplot(ratioProfits,aes(x=1:length(ratioProfits$profitRatio),color = variables)) + 
  geom_line(aes(y = profitRatio ), color = "black") +
  labs(x = "Time", y = "Difference In Growth Exponents",  color = "Legend")+
  theme(legend.position = c(0.25, 0.83))
grid.arrange(plot1, plot2, ncol = 2)


#We now compute the difference in growth rate between using the optimal portfolio for an incorrect distribution v.s the correct distrbution 
# as per Theorem 16.4.1
LogOptimalDist2 = ComputeLogOptimumDirchellete2Stocks(0.9999,0.9999,0.51,0.49)
ExpectedLogReturnIncorrectPortfolio = Expected_Log_Profit(LogOptimalDist2$maximum, 1,1, 0.51,0.49)
difference = LogOptimalDist$objective - ExpectedLogReturnIncorrectPortfolio
KL = KLDivergence_Dirchellete(c(1,1),c(0.9999,0.9999))
# We see that the differnece in expected log return is never greater than the KL divergence!



LogOptimalDist = ComputeLogOptimumDirchellete2Stocks(1,1,0.55,0.5)
