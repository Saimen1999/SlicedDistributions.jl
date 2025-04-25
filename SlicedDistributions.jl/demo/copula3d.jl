using DelimitedFiles
using Plots
using SlicedDistributions

# Daten einlesen
δ = readdlm("demo/data/copula3d.csv", ',')

# Sliced Normal Distribution anpassen
d = 3  # Dimension der Verteilung
b = 10000  # Anzahl der Samples für den Fit

δ_grouping = ParameterGrouping(δ)

# Fit Sliced Normal Distribution
d = 3
b = 10000
samples = []

for i in δ_grouping
    @time sn, lh = SlicedNormal(δ[:,i], d, b)
    println("Likelihood: $lh")
    push!(samples,rand(sn, 1000))
end

# 3D-Projektion der Daten (Beispiel für eine Projektion auf die ersten 3 Dimensionen)
p = scatter3d(
    δ[:, 1], δ[:, 2], δ[:, 3]; 
    aspect_ratio=:equal, 
    xlabel="δ1", ylabel="δ2", zlabel="δ3", 
    label="data"
)

# 3D-Plot der Samples von der Verteilung (Projektion auf die ersten 3 Dimensionen)
scatter3d!(p, samples[1][:, 1], samples[1][:, 2], samples[1][:, 3]; label="samples")

# Zeige den 3D-Plot an
display(p)
