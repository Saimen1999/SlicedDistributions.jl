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
u3 = rand(Uniform(0, 1), n)  # Neue Zufallsvariable für die dritte Dimension

# Abhängigkeiten durch Gumbel-Copula modellieren
θ = 2.5
# Abhängigkeit zwischen u1 und u2
dependent_u2 = [gumbel_copula(ui, uj, θ) for (ui, uj) in zip(u1, u2)]
# Abhängigkeit zwischen (u1, u2) und u3
dependent_u3 = [gumbel_copula(ui, uj, θ) for (ui, uj) in zip(dependent_u2, u3)]

# Marginalverteilungen definieren
marginal1 = Normal(3, 1)
marginal2 = Uniform(-2, 2)
marginal3 = Exponential(1.0)  # Neue Marginalverteilung für die dritte Dimension

# Werte in die Marginalverteilungen umwandeln
x1 = quantile.(marginal1, u1)
x2 = quantile.(marginal2, dependent_u2)
x3 = quantile.(marginal3, dependent_u3)

# Datenpunkte kombinieren
data = hcat(x1, x2, x3)

# Speichern der Daten in einer CSV-Datei
writedlm("demo/data/copula3d.csv", data, ',')
