include("instance.jl")
include("teste.jl")
include("model.jl")

export open_archive, build_vrp_model, solve_vrp

file = "C:/Users/budun/OneDrive/Área de Trabalho/----/Estudos/GEEOC/PIBITI/Códigos estudos/Projeto 3/A/A-n32-k5.vrp"
coords, instance = open_archive(file)
test_instance(instance, 32, 100, 5, coords)
rotas, results = build_vrp_model(instance)

###################################
# rotas, results = solve_vrp(instance)
