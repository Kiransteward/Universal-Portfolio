# Universal-Portfolios
This repository has contains the code used to generate the plots in my disseration. It consists of the following 3 files:
1. Log Optimal Portfolio for dirichlet random stock data.
2. Universal Portfolio. The code is run on random stock data as well as real stock data
3. Universal Policies

  
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

📁 Project Structure
bash
Copy
Edit
universal_portfolio/
├── data/
│   └── returns.csv               # Historical or synthetic return data
├── src/
│   ├── main.py                   # Main simulation script
│   ├── universal.py              # Core universal portfolio implementation
│   └── utils.py                  # Helper functions
├── results/
│   └── wealth_curve.png          # Portfolio value growth over time
├── README.md                     # Project documentation
└── requirements.txt              # Python dependencies
📈 Mathematical Idea
Let 
𝑤
∈
Δ
𝑛
w∈Δ 
n
  be a portfolio weight vector in the n-dimensional simplex.

At time 
𝑡
t, the wealth of a constant-rebalanced portfolio 
𝑤
w is:

𝑆
𝑡
(
𝑤
)
=
∏
𝑠
=
1
𝑡
(
𝑤
⊤
𝑥
𝑠
)
S 
t
​
 (w)= 
s=1
∏
t
​
 (w 
⊤
 x 
s
​
 )
Where:

𝑥
𝑠
x 
s
​
  is the gross return vector at time 
𝑠
s

The Universal Portfolio wealth at time 
𝑡
t is:

𝑆
𝑡
univ
=
∫
Δ
𝑛
𝑆
𝑡
(
𝑤
)
 
𝑑
𝜇
(
𝑤
)
S 
t
univ
​
 =∫ 
Δ 
n
 
​
 S 
t
​
 (w)dμ(w)
Where:

𝜇
(
𝑤
)
μ(w) is a prior distribution over the simplex (typically uniform)

🛠 Installation
bash
Copy
Edit
git clone https://github.com/yourusername/universal-portfolio.git
cd universal-portfolio
pip install -r requirements.txt
🚀 Usage
Add your return data in CSV format to the data/ directory (rows = time, columns = assets).

Modify parameters or configurations in main.py if needed.

Run the simulation:

bash
Copy
Edit
python src/main.py
View the portfolio growth results in the results/ folder.

📊 Features
Simulate universal portfolio wealth over time

Compare with:

Best constant rebalanced portfolio (CRP) in hindsight

Equal-weight portfolio

Works with any number of assets and time periods

Visualization of wealth trajectories

🧪 Example
With synthetic or historical data, the simulation compares:

Universal Portfolio

Best CRP (oracle)

Equal-weight baseline

All portfolio values are plotted and saved as wealth_curve.png.

📚 Dependencies
numpy

pandas

matplotlib

scipy (for numerical integration or optimization)

Optional:

cvxpy (if computing CRP via optimization)

📄 License
MIT License – see LICENSE for details.

🙋‍♀️ Contact & Contributions
Open an issue or submit a pull request for improvements, or reach out via your_email@example.com.

📖 References
Cover, T. M. (1991). Universal Portfolios. Mathematical Finance, 1(1), 1–29.

Universal Portfolios - Wikipedia
