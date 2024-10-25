using GLPK
using JuMP
using Plots

function add_lazy_constraints(model, instance, x, u)
    n = instance.n
    for k in 1:instance.K
        for i in 1:n
            for j in 1:n
                if i != j
                    value_x = value(x[i, j, k])
                    if value_x > 0.5
                        @constraint(model, u[i] - u[j] + (n - 1) * x[i, j, k] <= (n - 2))
                    end
                end
            end
        end
    end
end

function solve_vrp(instance)
    model = Model(GLPK.Optimizer)

    @variable(model, x[1:instance.n, 1:instance.n, 1:instance.K], Bin)
    @variable(model, u[1:instance.n], Int)

    @objective(model, Min, sum(instance.c[i, j] * x[i, j, k] for i in 1:instance.n, j in 1:instance.n, k in 1:instance.K))

    for k in 1:instance.K
        for i in 1:instance.n
            @constraint(model, sum(x[i, j, k] for j in 1:instance.n if i != j) == 1)
        end
    end

    for k in 1:instance.K
        @constraint(model, sum(instance.d[i] * x[i, j, k] for i in 1:instance.n, j in 1:instance.n if i != j) <= instance.Q)
    end

    for k in 1:instance.K
        @constraint(model, sum(x[1, j, k] for j in 2:instance.n) == 1)
    end

    for k in 1:instance.K
        for h in 2:instance.n
            @constraint(model, sum(x[i, h, k] for i in 1:instance.n if i != h) == sum(x[h, j, k] for j in 1:instance.n if j != h))
        end
    end

    optimize!(model)
    add_lazy_constraints(model, instance, x, u)

    optimize!(model)

    return value.(x)
end