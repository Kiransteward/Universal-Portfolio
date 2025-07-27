
🔄 Universal Portfolio Simulation
This project implements and simulates the Universal Portfolio strategy, a model-free online portfolio selection method proposed by Thomas M. Cover. Unlike traditional strategies that rely on return prediction or optimization assumptions, the universal portfolio adapts to market behavior and asymptotically matches the performance of the best constant-rebalanced portfolio (CRP) in hindsight.

📘 What is a Universal Portfolio?
The Universal Portfolio approach distributes wealth over all possible portfolios and continuously rebalances toward those that perform better. Over time, it achieves nearly the same exponential growth rate as the best fixed rebalanced portfolio chosen in hindsight.

Key idea:

"Without assuming any statistical model, we can still construct a portfolio strategy that is nearly as good as the best fixed portfolio in hindsight."

🧠 Core Concepts
Online Learning: Updates portfolio allocations using past observed returns, without forecasting.

No Model Assumptions: Makes no assumptions on asset return distributions.

Performance Guarantee: Achieves the same asymptotic growth rate as the best fixed portfolio (Cover, 1991).

📖 References
Cover, T. M. (1991). Universal Portfolios. Mathematical Finance, 1(1), 1–29.

Universal Portfolios - Wikipedia
