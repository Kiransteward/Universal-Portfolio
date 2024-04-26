library(ggplot2)
library(quantmod)
library("gridExtra")
library('nleqslv')
#Adjust the transaction rates for both stocks
lambda1 = 0.01
lambda2 = 0.01



get_return = function(ticker, time_period, base_year){
  stock = quantmod::getSymbols(ticker, src = "yahoo", auto.assign = FALSE)
  stock <- na.omit(stock)
  horizon <- paste0(as.character(base_year), "/", as.character(Sys.Date()))
  stock = stock[horizon]
  data = periodReturn(stock, period = time_period, type = "arithmetic")
  data = data +rep(1,nrow(data))
  assign(ticker, data, envir = .GlobalEnv)
  
}
#Function for generating random uniform intervals over [0,1]
generateRandomUniformIntervals = function(n){
  lower_ends = runif(n)
  upper_ends = rep(0,length(lower_ends))
  for(i in 1:length(lower_ends)){
    upper_ends[i] = runif(1,min = lower_ends[i], max = 1)
  }
  policies = cbind(lower_ends,upper_ends)
  return(policies)
}
#TransactionFeesEquation solves for the net realised wealth from optimally trading portfolio b for z 
# at transaction rates of lambda1 and lambda2
TransactionFeesEquation = function(b,z,lambda1,lambda2){
  functionToSolve = function(x){
    y = numeric(1)
    y[1] = lambda1*abs(x[1]*z-b)+lambda2*abs(x[1]*(1-z)-(1-b)) - (1-x[1])
    y
  }
  xstart <- c(0.98)
  result = nleqslv(xstart, functionToSolve, control=list(btol=.01))
  return(result)
}
computeWealthFromPolicy = function(alpha,stocks, lambda1,lambda2){
  wealth = rep(1, length(stocks[,1]))
  currentPortfolio = 0.5
  alphaPortfolio = 0.5
  for(i in 1:length(stocks[,1])){
    if(currentPortfolio < alpha[1]){
      alphaPortfolio = alpha[1]
    }
    else if(currentPortfolio > alpha[2]){
      alphaPortfolio = alpha[2]
    }
    else{
      alphaPortfolio = currentPortfolio
    }
    transactionFees = TransactionFeesEquation(currentPortfolio,alphaPortfolio,lambda1,lambda2)$x
    wealthRelative = as.numeric(stocks[i,1])*alphaPortfolio + as.numeric(stocks[i,2])*(1-alphaPortfolio)
    wealth[i] = transactionFees*wealthRelative
    currentPortfolio = (as.numeric(stocks[i,1])*alphaPortfolio)/wealthRelative
  }
  return(c(cumprod(wealth)))
}
computeBestPolicyInHindsight = function(stocks, lambda1,lambda2){
  ui = cbind(c(-1,1,-1,0), c(0,0,1,-1))
  ci=c(-1,0,0.00001,-1)
  RandomStartPoints = generateRandomUniformIntervals(5)
  # optimalPolicy = constrOptim(c(0.5,0.7), gr = NULL, function(x){
  #   wealths = computeWealthFromPolicy(x,stocks, lambda1,lambda2)
  #   return(wealths[length(wealths)])
  # }, ui = ui, ci=ci, control = list(fnscale = -1))
  # return(optimalPolicy)
  maximumPolicy = data.frame(value = -Inf, par = c(0.5,0.5))
  for(i in 1:length(RandomStartPoints[,1])){
    optimalPolicy = constrOptim(RandomStartPoints[i,], gr = NULL , function(x){
      wealths = computeWealthFromPolicy(x,stocks, lambda1,lambda2)
      return(wealths[length(wealths)])
    }, ui = ui, ci=ci, control = list(fnscale = -1))
    if(optimalPolicy$value > maximumPolicy$value)maximumPolicy=optimalPolicy
  }
  return(maximumPolicy)
}
#Computes 1/n * log(S^{hat}_{n}/S_{n}) 
Compute_Limit_Ratio = function(profit1,profit2){
  ratio = log(profit1/profit2)
  for(i in 1:length(ratio)){
    ratio[i] = (1/i)*ratio[i]
  }
  return(ratio)
}

computeWealthAverages = function(intervals, stocks, lambda1,lambda2){
  wealth_averages = rep(0,length(stocks[,1]))
  for(i in 1:length(intervals[,1])){
    wealth_averages  = wealth_averages + computeWealthFromPolicy(intervals[i,], stocks, lambda1, lambda2)
  }
  return(wealth_averages/length(intervals[,1]))
}
PlotGraphs = function(wealthDataFrame, colors){
  plot1 = ggplot(wealthDataFrame,aes(x=1:nrow(wealthDataFrame),color = variables)) + 
    geom_line(aes(y = Stock1 , color = "Stock 1"), size=0.5) + 
    geom_line(aes(y = Stock2, color = "Stock 2"), size=0.5) + 
    geom_line(aes(y = BestPolicyInHindsite, color = "Best Hindsight Policy"), size=0.5) + 
    geom_line(aes(y = UniversalPolicyWealth, color = "Universal Policy"), size=0.5) + 
    labs(x = "Time", y = "Profit",  color = "Legend")+ 
    scale_color_manual(values = colors)+
    theme(legend.position = c(0.25, 0.83))

  ratio = data.frame(fraction = Compute_Limit_Ratio(wealthDataFrame$UniversalPolicyWealth, wealthDataFrame$BestPolicyInHindsite))
  plot2 = ggplot(ratio ,aes(x=1:(length(ratio[,1])))) +
    geom_line(aes(y = fraction)) +
    labs(x = "Time", y = "Difference In Growth Exponents")
  grid.arrange(plot1, plot2, ncol = 2)
}

#Random intervals used to approximate the wealth of the universal policy
intervals = generateRandomUniformIntervals(300)
#Random Stock Data
stocks = ((rdirichlet(500, c(1,1))))
#Add offset to each stock so they roughly centered around 1
stocks[,1] = stocks[,1]+0.51
stocks[,2] = stocks[,2]+0.52
optimalPolicy = computeBestPolicyInHindsight(stocks, lambda1,lambda2)
wealths_optimalPolicy = computeWealthFromPolicy(optimalPolicy$par, stocks, lambda1,lambda2)
wealth_averages = computeWealthAverages(intervals, stocks, lambda1,lambda2)
wealthDataFrame = data.frame(UniversalPolicyWealth = wealth_averages, BestPolicyInHindsite = wealths_optimalPolicy, Stock1 = as.numeric(cumprod(stocks[,1])), Stock2 = as.numeric(cumprod(stocks[,2])))
colors <- c("Stock 1" = "steelblue", "Stock 2" = "red", "Best Hindsight Policy" = "orange", "Universal Policy"  = "purple")
PlotGraphs(wealthDataFrame, colors)



get_return("GOOG", "daily",2023)
get_return("AAPL", "daily", 2023)
realStocks = merge.xts(GOOG,AAPL)
optimalPolicyReal = computeBestPolicyInHindsight(realStocks, lambda1,lambda2)
wealths_optimalPolicyReal = computeWealthFromPolicy(optimalPolicyReal$par, realStocks, lambda1,lambda2)
wealth_averagesReal = computeWealthAverages(intervals, realStocks, lambda1,lambda2)
wealthDataFrameReal = data.frame(UniversalPolicyWealth = wealth_averagesReal, BestPolicyInHindsite = wealths_optimalPolicyReal, Stock1 = as.numeric(cumprod(realStocks[,1])), Stock2 = as.numeric(cumprod(realStocks[,2])))
colors <- c("Google" = "steelblue", "Apple" = "red", "Best Hindsight Policy" = "orange", "Universal Policy"  = "purple")
PlotGraphs(wealthDataFrameReal, colors)

plot1 = ggplot(wealthDataFrameReal,aes(x=1:nrow(wealthDataFrameReal),color = variables)) + 
  geom_line(aes(y = Google , color = "Google"), size=0.5) + 
  geom_line(aes(y = Apple, color = "Apple"), size=0.5) + 
  geom_line(aes(y = BestPolicyInHindsite, color = "Best Hindsight Policy"), size=0.5) + 
  geom_line(aes(y = UniversalPolicyWealth, color = "Universal Policy"), size=0.5) + 
  labs(x = "Time", y = "Profit",  color = "Legend")+ 
  scale_color_manual(values = colors)
ratio = data.frame(fraction = Compute_Limit_Ratio(wealthDataFrameReal$UniversalPolicyWealth, wealthDataFrameReal$BestPolicyInHindsite))
plot2 = ggplot(ratio ,aes(x=1:(length(ratio[,1])))) +
  geom_line(aes(y = fraction)) +
  labs(x = "Time", y = "Fraction")
grid.arrange(plot1, plot2, ncol = 2)













