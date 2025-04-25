module SlicedDistributions

using CovarianceEstimation
using Distributions
using LinearAlgebra
using Monomials
using TransitionalMCMC
using QuasiMonteCarlo
using Optim

import Base: rand

export SlicedNormal, SlicedExponential, rand, pdf, ParameterGrouping

abstract type SlicedDistribution end

function ParameterGrouping(δ::AbstractMatrix)
    # Berechne die Distanzmatrix basierend auf der (absoluten) Korrelation
    dist_matrix = 1 .- abs.(cor(δ))
    num_columns = size(δ, 2)
    
    groups = []                      # Liste für die Gruppen
    assigned = falses(num_columns)   # Vektor, um zu verfolgen, welche Spalten bereits zugeordnet wurden
    
    # Solange mehr als 2 Parameter unzugeordnet sind, bilde Paare
    while sum(.!assigned) > 2
        remaining = findall(.!assigned)
        # Wähle die erste noch nicht zugewiesene Spalte als Startpunkt
        first_idx = remaining[1]
        # Entferne first_idx aus den Kandidaten
        candidates = setdiff(remaining, [first_idx])
        
        # Finde den Kandidaten mit dem kleinsten Abstand (also höchster Korrelation) zu first_idx
        candidate_dists = dist_matrix[first_idx, candidates]
        best_candidate = candidates[argmin(candidate_dists)]
        
        # Bilden ein Paar: Startspalte und ihr bester Kandidat
        new_group = [first_idx, best_candidate]
        assigned[[first_idx, best_candidate]] .= true
        remaining = findall(.!assigned)
        if length(remaining) == 1
            push!(new_group, remaining[1])
            assigned[remaining[1]] = true
        end
        push!(groups, new_group)

    end
    
    # Füge die letzten 2 unzugeordneten Parameter als Gruppe hinzu
    remaining = findall(.!assigned)
    if length(remaining) == 2
        push!(groups, remaining)
    end
    
    return groups
end


function Distributions.pdf(sn::SlicedDistribution, δ::AbstractMatrix)
    n, m = size(δ)
    if n == 1 || m == 1
        return pdf(sn, vec(δ))
    end
    if n < m
        return [pdf(sn, c) for c in eachcol(δ)]
    end
    return [pdf(sn, c) for c in eachrow(δ)]
end

function rand(sd::SlicedDistribution, n::Integer)
    prior = Uniform.(sd.lb, sd.ub)

    logprior(x) = sum(logpdf.(prior, x))
    sampler(n) = mapreduce(u -> rand(u, n), hcat, prior)
    loglikelihood(x) = log(SlicedDistributions.pdf(sd, x))

    samples, _ = tmcmc(loglikelihood, logprior, sampler, n)

    return samples
end

function get_likelihood(
    zδ::Matrix{<:Real}, zΔ::Matrix{<:Real}, n::Integer, vol::Real, b::Integer
)
    f = λ -> n * log(vol / b * sum(exp.(zΔ * λ / -2))) + sum(zδ * λ) / 2
    return f
end

function get_gradient(zδ::Matrix{<:Real}, zΔ::Matrix{<:Real}, n::Integer)
    f =
        (g, λ) -> begin
            exp_Δ = exp.(zΔ * λ / -2)
            sum_exp_Δ = sum(exp_Δ)
            for i in eachindex(g)
                g[i] = @views n * sum(exp_Δ .* -0.5zΔ[:, i]) / sum_exp_Δ + sum(zδ[:, i]) / 2
            end
            return nothing
        end
    return f
end

function get_hessian(zΔ::Matrix{<:Real}, n::Integer)          # Geändert von Simon Aspenleider [09.12.24]: Symmetrie wird nun ausgenutzt
    f =
        (H, λ) -> begin
            exp_Δ = exp.(zΔ * λ / -2)
            sum_exp_Δ = sum(exp_Δ)
            sum_exp_Δ² = sum_exp_Δ^2

            for i in 1:size(zΔ, 2)
                exp_Δ_i = exp_Δ .* -0.5 .* zΔ[:, i]
                sum_exp_Δ_i = sum(exp_Δ_i)

                for j in i:size(zΔ, 2)  # Nur obere Dreiecksmatrix berechnen
                    exp_Δ_j = exp_Δ .* -0.5 .* zΔ[:, j]
                    H_ij = n * (
                        sum(exp_Δ_i .* zΔ[:, j] .* -0.5) * sum_exp_Δ -
                        sum_exp_Δ_i * sum(exp_Δ_j)
                    ) / sum_exp_Δ²

                    H[i, j] = H_ij
                    if i != j
                        H[j, i] = H_ij
                    end
                end
            end
            return nothing
        end
    return f
end

include("exponentials/poly.jl")
include("normals/sum-of-squares.jl")

end
