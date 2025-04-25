using DelimitedFiles
using Random
using Distributions

Random.seed!(4328)

# Anzahl der Datenpunkte
n = 500

# Gumbel-Copula
function gumbel_copula(u1, u2, θ)
    log_u1 = -log(u1)
    log_u2 = -log(u2)
    term = (log_u1^θ + log_u2^θ)^(1/θ)
    exp(-term)
end

# Generieren von Zufallswerten
u1 = rand(Uniform(0, 1), n)
u2 = rand(Uniform(0, 1), n)

# Abhängigkeit durch Gumbel-Copula modellieren
θ = 2.5 
dependent_u2 = [gumbel_copula(ui, uj, θ) for (ui, uj) in zip(u1, u2)]

# Marginalverteilungen definieren
marginal1 = Normal(3, 1)
marginal2 = Uniform(-2, 2)

# Werte in die Marginalverteilungen umwandeln
x1 = quantile.(marginal1, u1)
x2 = quantile.(marginal2, dependent_u2)

# Datenpunkte kombinieren
data = hcat(x1, x2)

# Speichern der Daten in einer CSV-Datei
writedlm("demo/data/copula2d.csv", data, ',')
