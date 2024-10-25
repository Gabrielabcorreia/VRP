using JuMP
using MathOptInterface
import GLPK
import Plots

function subtour(edges::Vector{Tuple{Int, Int}}, n)
    shortest_subtour, unvisited = collect(1:n), Set(collect(1:n))
    while !isempty(unvisited)
        this_cycle, neighbors = Int[], unvisited
        while !isempty(neighbors)
            current = pop!(neighbors)
            push!(this_cycle, current)
            if length(this_cycle) > 1
                pop!(unvisited, current)
            end
            neighbors = [j for (i, j) in edges if i == current && j in unvisited]
        end
        if length(this_cycle) < length(shortest_subtour)
            shortest_subtour = this_cycle
        end
    end
    return shortest_subtour
end

function selected_edges(x::Matrix{Float64}, n)
    return Tuple{Int, Int}[(i, j) for i in 1:n, j in 1:n if x[i, j] > 0.5]
end

function plot_tour(coords, x)
    plot = Plots.plot()
    for (i, j) in selected_edges(x, size(x, 1))
        Plots.plot!([coords[i][1], coords[j][1]], [coords[i][2], coords[j][2]]; legend = false)
    end
    display(plot)
    return plot
end

function build_vrp_model(instance)
    n = instance.n
    K = instance.K
    Q = instance.Q
    d = instance.d
    coords = instance.coords 

    model = Model(GLPK.Optimizer)

    @variable(model, x[1:n, 1:n, 1:K], Bin)

    @objective(model, Min, sum(d[i] * d[j] * x[i, j, k] for i in 1:n, j in 1:n, k in 1:K))

    for k in 1:instance.K
        for i in 1:instance.n
            @constraint(model, sum(x[i, j, k] for j in 1:instance.n if i != j) == 1)
        end
    end

    for k in 1:instance.K
        @constraint(model, sum(instance.d[i] * x[i, j, k] for i in 1:instance.n, j in 1:instance.n if i != j) <= instance.Q)
    end

    for k in 1:K
        for h in 2:n
            @constraint(model, sum(x[i, h, k] for i in 1:n if i != h) == sum(x[h, j, k] for j in 1:n if j != h))
        end
    end

    optimize!(model)

    @assert JuMP.termination_status(model) == MOI.OPTIMAL "Erro: Optimal solution not found !"

    tour_edges = selected_edges(value.(model[:x]), n)
    plot_tour(coords, value.(model[:x]))

    return tour_edges, objective_value(model)
end