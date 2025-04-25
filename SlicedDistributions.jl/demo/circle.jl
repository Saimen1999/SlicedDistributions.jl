using DelimitedFiles
using Plots
using SlicedDistributions
using Statistics

δ = readdlm("demo/data/circle.csv", ',')
δ_grouping = ParameterGrouping(δ)

# Fit Sliced Normal Distribution
d = 4
b = 10000
samples = []

for i in δ_grouping
    @time sn, lh = SlicedNormal(δ[:,i], d, b)
    println("Likelihood: $lh")
    push!(samples,rand(sn, 1000))
end

p = scatter(
    δ[:, 1], δ[:, 2]; aspect_ratio=:equal, lims=[-4, 4], xlab="δ1", ylab="δ2", label="data")
    scatter!(p, samples[1][:, 1], samples[1][:, 2]; label="samples")

display(p)