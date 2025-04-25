using DelimitedFiles
using Distributions
using Random

Random.seed!(4328)

n = 500  # Anzahl der Datenpunkte
dimensions = 4  # Anzahl der Dimensionen

# Funktion zur Generierung eines Datensatzes mit Abhängigkeiten
function generate_dependent_data(n, dimensions)
    θ = rand(Normal(π / 2, 1.3), n)
    r = 3 .+ rand(Uniform(0, 0.2), n) .* (θ .- π / 2)
    
    # Erzeuge den ersten Satz von Daten (zweidimensional)
    δ1 = r .* cos.(θ)
    δ2 = r .* sin.(θ)

    # Erzeuge Abhängigkeiten
    data = [δ1 δ2]
    for i in 3:dimensions
        δ = r .* cos.(θ .+ 0.2 * i)  # Stärkere Abhängigkeit
        data = hcat(data, δ)  # Verknüpfe die Daten in höheren Dimensionen
    end
    
    return data
end

# Erzeuge den Datensatz
data = generate_dependent_data(n, dimensions)

# Speichern des Datensatzes
writedlm("demo/data/high_dim.csv", data, ',')

