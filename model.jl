using GLPK
using JuMP
using Plots

function solve_vrp(instance)
    model = Model(GLPK.Optimizer)

    @variable(model, x[1:instance.n, 1:instance.n], Bin)
    @variable(model, u[1:instance.n], Int)

    @objective(model, Min, sum(instance.c[i, j] * x[i, j] for i in 1:instance.n, j in 1:instance.n if i != j))

    @constraint(model, sum(x[i, j] for i in 2:instance.n, j in 1:instance.n) == 1)

    for h in 2:instance.n
        @constraint(model, sum(x[i, h] for i in 1:instance.n if i != h) == sum(x[h, j] for j in 1:instance.n if j != h))
    end

    @constraint(model, sum(x[1, j] for j in 1:instance.n) == instance.K)

    for i in 2:instance.n, j in 2:instance.n
        if i != j
            @constraint(model, u[j] ≥ u[i] + instance.d[i] - (instance.Q + 1) * (1 - x[i, j]))
        end
    end

    optimize!(model)

    if termination_status(model) == MOI.OPTIMAL
        routes = []
        visited = Set()
        for k in 1:instance.K
            route = []
            current_node = 1
            while true
                push!(route, current_node)
                visited_node = findfirst(x[current_node, :] .> 0.5)
                if visited_node === nothing || visited_node in visited
                    break
                end
                current_node = visited_node
                push!(visited, visited_node)
            end
            push!(routes, route)
        end

        for (i, route) in enumerate(routes)
            println("Route #$i: ", join(route, " "))
        end

        total_cost = objective_value(model)
        println("Cost ", total_cost)

        plot_routes(instance, routes)
        return routes, total_cost
    else
        println("No optimal solution has found")
    end

end

function plot_routes(instance, routes)
    plot()
    for route in routes
        x_coords = [instance.coords[i][1] for i in route]
        y_coords = [instance.coords[i][2] for i in route]
        scatter!(x_coords, y_coords, label="", marker=:circle)
        plot!(x_coords, y_coords, label="Route", arrow=true)
    end
    scatter!([instance.coords[1][1]], [instance.coords[1][2]], label="Depot", marker=:star, color=:red)
    title!("VRP Solution")
    xlabel!("X")
    ylabel!("Y")
    grid!(true)
end

function save_archive(routes, total_cost)

    open("Results", "w") do io
        for (i, route) in enumerate(routes)
            println(io, "Route $(i): ", join(route, " -> "))
        end
        println(io, "Costs: ", total_cost)
    end
end

function verify_costs(total_cost, costs)

    @test total_cost == costs || throw(AssertionError("Erro: Costs wrong"))
end