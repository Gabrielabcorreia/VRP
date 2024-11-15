include("instance.jl")
include("model.jl")

export open_archive, build_vrp_model, solve_vrp

file = "C:/Users/budun/OneDrive/Área de Trabalho/----/Estudos/GEEOC/PIBITI/Códigos estudos/Projeto 3/A/A-n32-k5.vrp"
coords, instance = open_archive(file)
routes, total_cost = solve_vrp(instance)