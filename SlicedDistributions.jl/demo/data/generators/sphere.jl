using DelimitedFiles
using Distributions
using Random

Random.seed!(4328)

n = 500  # Anzahl der Punkte

# Step 1: Erzeugen der ersten Gruppe von Punkten auf der Kugel
θ = rand(Normal(π / 2, 1.3), n)  # Zufällige Winkel für die x-y-Ebene
φ = rand(Uniform(0, 2π), n)  # Zufällige Winkel für die z-Ebene
r = 3 .+ rand(Uniform(0, 0.2), n) .* (θ .- π / 2)  # Radien mit Verzerrung

# Umrechnung von Kugelkoordinaten (r, θ, φ) in kartesische Koordinaten (x, y, z)
δ1 = r .* sin.(θ) .* cos.(φ)  # x-Koordinaten
δ2 = r .* sin.(θ) .* sin.(φ)  # y-Koordinaten
δ3 = r .* cos.(θ)  # z-Koordinaten

# Die generierten 3D-Punkte
δ = hcat(δ1, δ2, δ3)

# Step 2: Erzeugen der zweiten Gruppe von Punkten (weitere Kugelpunkte)
θ = rand(Normal(π / 2, 1.3), n)
φ = rand(Uniform(0, 2π), n)
r = 3 .+ rand(Uniform(0, 0.2), n) .* (θ .- π / 2)

δ1 = r .* sin.(θ) .* cos.(φ)
δ2 = r .* sin.(θ) .* sin.(φ)
δ3 = r .* cos.(θ)

# Die weiteren 3D-Punkte
δ2 = hcat(δ1, δ2, δ3)

# Alle Punkte zusammenfügen
δ = vcat(δ, δ2)

# Speichern der 3D-Punkte als CSV
writedlm("demo/data/sphere.csv", δ, ',')
