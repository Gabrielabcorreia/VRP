struct VRP_instances
    n::Int64
    K::Int64
    Q::Int64
    coords::Vector{Tuple{Int64, Int64}}
    d::Vector{Int64}
    c::Matrix{Float64}
end

function open_demands(file::String)
    d1 = Int64[]
    open(file, "r") do io
        in_demand_section = false
        for line in eachline(io)
            if occursin("DEMAND_SECTION", line)
                in_demand_section = true
            elseif occursin("DEPOT_SECTION", line)
                break
            elseif in_demand_section
                push!(d1, parse(Int, split(line)[2]))
            end
        end
    end
    return d1
end

function calculate_costs(coords)
    num_points = length(coords)
    costs = zeros(Float64, num_points, num_points)
    for i in 1:num_points
        for j in 1:num_points
            costs[i, j] = round(sqrt((coords[i][1] - coords[j][1])^2 + (coords[i][2] - coords[j][2])^2), digits=1)
        end
    end
    return costs
end

function test_instance(instance, n1, Q1, k1, coords1::Vector{Tuple{Int64, Int64}})
    @assert instance.n == n1 "Erro: Number of customers wrong"
    @assert instance.Q == Q1 "Erro: Capacity wrong"
    @assert instance.K == k1 "Erro: Number of veichles wrong"
    @assert instance.coords == coords1 "Erro: Coords wrong"
end

function open_archive(file::String)
    coords1 = Vector{Tuple{Int64, Int64}}()
    n1, Q1, k1 = 0, 0, 0

    open(file, "r") do io
        in_coord_section = false
        for line in eachline(io)
            if occursin("DIMENSION", line)
                n1 = parse(Int, split(line)[end])
            elseif occursin("CAPACITY", line)
                Q1 = parse(Int, split(line)[end])
            elseif occursin("NODE_COORD_SECTION", line)
                in_coord_section = true
            elseif occursin("DEMAND_SECTION", line)
                break
            elseif in_coord_section
                coords_parts = split(line)
                push!(coords1, (parse(Int, coords_parts[2]), parse(Int, coords_parts[3])))
            end
        end
    end

    d1 = open_demands(file)
    total_demand = sum(d1[2:end])
    k1 = ceil(Int, total_demand / Q1)
    c1 = calculate_costs(coords1)

    return coords1, VRP_instances(n1, k1, Q1, coords1, d1, c1)

end
