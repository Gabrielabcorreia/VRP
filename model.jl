using GLPK
using JuMP

struct Results
    x::Matrix{Float64}
end

function solve_vrp(instance)
    model = Model(GLPK.Optimizer)

    @variable(model, x[1:instance.n, 1:instance.n], Bin)
    @variable(model, u[2:instance.n], Int)

    @objective(model, Min, sum(instance.c[i, j] * x[i, j] for i in 1:instance.n, j in 1:instance.n))

    valid_pairs = [(i, j) for i in 2:instance.n, j in 2:instance.n if i != j]

    @constraints(model, begin
        [j in 2:instance.n], sum(x[i, j] for i in 1:instance.n if i != j) == 1
        [i in 2:instance.n], sum(x[i, j] for j in 1:instance.n if i != j) == 1

        sum(x[1, j] for j in 2:instance.n) == instance.K
        sum(x[i, 1] for i in 2:instance.n) == instance.K
    end)

    for (i, j) in valid_pairs
        @constraint(model, u[j] ≥ u[i] + instance.d[j] - (instance.Q + 1) * (1 - x[i, j]))
    end

    @constraint(model, [i in 2:instance.n], u[i] ≥ instance.d[i])
    @constraint(model, [i in 2:instance.n], u[i] ≤ instance.Q)

    optimize!(model)

    if termination_status(model) == MOI.OPTIMAL
        total_distance = objective_value(model)
        println("Costs: $total_distance")
        return Results(value.(x))
    else
        println("No optimal solution found")
        return nothing
    end
end


function show_results(instance, model)
    x = value.(model[:x])
    routes = []

    for k in 1:instance.K
        route = []
        current_node = 1
        current_capacity = 0
        visited = falses(instance.n)
        push!(route, current_node)
        visited[current_node] = true

        while length(route) < instance.n + 1 
            for i in 1:instance.n
                for j in 1:instance.n
                    if i != j && !visited[j] && x[i, j] >= 0.5
                        push!(route, j)
                        visited[j] = true
                        current_capacity += instance.d[j]
                        break  
                    end
                end
            end
        end

        push!(routes, route) 
    end

    for (i, route) in enumerate(routes)
        println("Route #$i: ", join(route, " "))
    end

    total_cost = objective_value(model)
    println("Cost: $total_cost")

    save_archive(routes, total_cost)
    plot_routes(instance, routes)
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
end

function save_archive(routes, total_cost)
    open("Results", "w") do io
        for (i, route) in enumerate(routes)
            println(io, "Route $(i): ", join(route, " "))
        end
        println(io, "Costs: ", total_cost)
    end
end

function verify_costs(total_cost, costs)

   @test total_cost == costs || throw(AssertionError("Erro: Costs wrong"))

end