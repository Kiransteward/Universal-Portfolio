install.packages("quantmod")
install.packages("PerformanceAnalytics")
install.packages("dygraphs")

library(quantmod)
library(PerformanceAnalytics)
library(dygraphs)
library(pracma)
library(polynom)
library(ggplot2)
library("gridExtra")
library(LaplacesDemon)

#This function scrapes data from yahoo finanace. 
get_return = function(ticker, time_period, base_year){
  stock = quantmod::getSymbols(ticker, src = "yahoo", auto.assign = FALSE)
  stock <- na.omit(stock)
  horizon <- paste0(as.character(base_year), "/", as.character(Sys.Date()))
  stock = stock[horizon]
  data = periodReturn(stock, period = time_period, type = "arithmetic")
  data = data +rep(1,nrow(data))
  assign(ticker, data, envir = .GlobalEnv)
  
}
#Function computes the universal portfolio for any stock sequences for 2 stocks.  
compute_universal = function(stocks){
  m = length(stocks[1,])
  steps = length(stocks[,1])
  universal_port = matrix(nrow = steps,ncol = m)
  productReturn = c(0,1)
  for(i in 1:steps){
    numerator_polynomial = polymul(productReturn, c(1,0))
    numerator = integrate(function(x) polyval(numerator_polynomial,x),lower=0,upper=1, subdivisions = 100000 )
    denominator = integrate(function(x) polyval(productReturn,x),lower=0,upper=1,subdivisions = 100000)
    b_1 = (numerator$value)/(denominator$value)
    b_2 = (1.0-b_1)
    universal_port[i,1] = b_1
    universal_port[i,2] = b_2

    productReturn = polymul(productReturn, c(as.numeric(stocks[i,1])-as.numeric(stocks[i,2]),as.numeric(stocks[i,2])))
    
  }
  return(universal_port)
}
#Computes the best constantly rebalanced portfolio in hindsight, given access to all the stock in advance. 
compute_best_rebalanced = function(stocks){
  m = length(stocks[1,])
  steps = length(stocks[,1])
  productReturn = c(0,1)
  for(i in 1:steps){
    productReturn = polymul(productReturn, c(as.numeric(stocks[i,1])-as.numeric(stocks[i,2]),as.numeric(stocks[i,2])))
  }
  optimal_portflio = optimize(function(x) prod(stocks%*%c(x,1-x)), interval = c(0,1), maximum = TRUE)
    
  return(c(optimal_portflio$maximum,1-optimal_portflio$maximum))
  
}
#Computes cumulative profit of a portfolio on any inputed sequence of stocks. 
compute_profit = function(portflio,stocks){
  profit = rep(1,length(portflio[,1]))
  for(i in 1:length(portflio[,1])){
    profit[i] = (portflio[i,1]*stocks[i,1] + portflio[i,2]*stocks[i,2])
  }
  return(cumprod(profit))
}


get_return("GOOG", "daily",2023)
get_return("AAPL", "daily", 2023)
returns = merge.xts(GOOG,AAPL)
universal_portflio = compute_universal(returns)
best_rebalanced = compute_best_rebalanced(returns)
profit_rebalanced = cumprod(returns %*% best_rebalanced)
profit_universal = compute_profit(universal_portflio,returns)
returns = data.frame(cbind(returns, Universal_Profit = profit_universal, Best_Rebalanced_Profit= profit_rebalanced, First_Stock = as.numeric(cumprod(returns[,1])),Second_Stock = as.numeric(cumprod(returns[,2]))))
colors <- c("Google" = "steelblue", "Apple" = "red", "Best Rebalanced" = "orange", "Universal Portfolio"  = "purple")
PlotReal = ggplot(returns,aes(x=1:nrow(returns), col = legend)) + 
  geom_line(aes(y = Universal_Profit, color = "Universal Portfolio"),size = 0.5) + 
  geom_line(aes(y = Best_Rebalanced_Profit, color="Best Rebalanced"), size = 0.5) +
  geom_line(aes(y = First_Stock, color="Google" ), size = 0.5) +
  geom_line(aes(y = Second_Stock, color="Apple" ), size =0.5) +
  labs(x = "Time", y = "Profit",  color = "Legend")+ 
  scale_color_manual(values = colors)+
  theme(legend.position = c(0.25, 0.82))


# We now look at random stock data 
stocks = ((rdirichlet(300, c(1,1))))
stocks[,1] = stocks[,1]+0.55
stocks[,2] = stocks[,2] + 0.5
best_rebalanced = compute_best_rebalanced(stocks)
best_rebalanced_profit = cumprod(stocks %*% best_rebalanced)
logOptimumPortfolio = c(0.6539,0.3461)
LogOptimProfit = cumprod(stocks %*% logOptimumPortfolio)
Universal_Portflio_randomData = compute_universal(stocks)
Universal_profit = compute_profit(Universal_Portflio_randomData, stocks)
profits = data.frame(Stock1 = cumprod(stocks[,1]), Stock2 = cumprod(stocks[,2]), best_rebalanced_profit, Universal_profit, LogOptimProfit)
colors <- c("Stock 1" = "steelblue", "Stock 2" = "red", "Best Rebalanced" = "orange", "Universal Portfolio"  = "purple", "Log Optimal" = "green")
PlotRandom = ggplot(profits,aes(x=1:nrow(profits),color = variables)) + 
  geom_line(aes(y = Stock1, color = "Stock 1"), size=0.5) + 
  geom_line(aes(y = Stock2,color="Stock 2"), size=0.5) +
  geom_line(aes(y = best_rebalanced_profit, color="Best Rebalanced"), size=0.5)+
  geom_line(aes(y = Universal_profit, color="Universal Portfolio"), size=0.5)+
  geom_line(aes(y = LogOptimProfit, color="Log Optimal"), size = 0.5)+
  labs(x = "Time", y = "Profit",  color = "Legend")+ 
  scale_color_manual(values = colors)+
  theme(legend.position = c(0.25, 0.82))


# As per the theory we see that (1/n)ln(Sn*/S^n) tends to 0 for the Dir(1,1) universal portfolio.  
Compute_Limit_Ratio = function(profit1,profit2){
  ratio = log(profit1/profit2)
  for(i in 1:length(ratio)){
    ratio[i] = (1/i)*ratio[i]
  }
  return(ratio)
}

ratiosRandom = data.frame(fraction = Compute_Limit_Ratio(profits$best_rebalanced_profit,profits$Universal_profit))
PlotRatioRandom = ggplot(ratiosRandom ,aes(x=1:(length(ratiosRandom[,1])))) +
  geom_line(aes(y = fraction )) +
  labs(x = "Time", y = "Difference In Growth Exponents")
grid.arrange(PlotRandom, PlotRatioRandom, ncol = 2)


ratiosReal = data.frame(fraction = Compute_Limit_Ratio(returns$Best_Rebalanced_Profit,returns$Universal_Profit))
PlotRatioReal = ggplot(ratiosReal ,aes(x=1:(length(ratiosReal[,1])))) +
  geom_line(aes(y = fraction )) +
  labs(x = "Time", y = "Difference In Growth Exponents")



Compute_Limit_Ratio(returns$Best_Rebalanced_Profit,returns$Universal_Profit)



