## MU Weighted Universal Portfolio Algorithm
🔄 Universal Portfolio Simulation <br>
This project implements and simulates the Universal Portfolio strategy, a model-free portfolio selection method proposed by Thomas M. Cover. Unlike traditional strategies that rely on return prediction or optimization assumptions, the universal portfolio adapts to market behavior and asymptotically matches the performance of the best constant-rebalanced portfolio (CRP) in hindsight. This is a performance weighted algorithm which 

📘 What is a Universal Portfolio? <br>
Universal Portfolio's are a family of mathematical algorthims which satisfy the following condition: 
$$
\lim_{n\to\infty}\sup_{x_{1}^{n}}\frac{1}{n}\log\left(\frac{S^{\ast}_{n}}{S_{n}}\right) = \lim_{n\to\infty} \sup_{x_{1}^{n}} W_{n}^{\ast}(x_{1}^{n})- W_{n}(x_{1}^{n}) = 0.
$$


distributes wealth over all possible portfolios and continuously rebalances toward those that perform better. Over time, it achieves nearly the same exponential growth rate as the best fixed rebalanced portfolio chosen in hindsight.

Key idea:

"Without assuming any statistical model, we can still construct a portfolio strategy that is nearly as good as the best fixed portfolio in hindsight."

🧠 Core Concepts
Online Learning: Updates portfolio allocations using past observed returns, without forecasting.

No Model Assumptions: Makes no assumptions on asset return distributions. The only assumption is that the 

Performance Guarantee: Achieves the same asymptotic growth rate as the best constantly rebalanced portfolio in hindsite. 

📖 References
Cover, T. M. (1991). Universal Portfolios. Mathematical Finance, 1(1), 1–29.

Universal Portfolios - Wikipedia
