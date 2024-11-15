include("instance.jl")
include("model.jl")

export open_archive, solve_vrp, verify_costs, test_instance

file = "C:/Users/budun/OneDrive/Área de Trabalho/----/Estudos/GEEOC/PIBITI/Códigos estudos/Projeto 3/A/A-n32-k5.vrp"
file2 = "C:/Users/budun/OneDrive/Área de Trabalho/----/Estudos/GEEOC/PIBITI/Códigos estudos/Projeto 3/A/A-n33-k5.vrp"
file3 = "C:/Users/budun/OneDrive/Área de Trabalho/----/Estudos/GEEOC/PIBITI/Códigos estudos/Projeto 3/A/A-n62-k8.vrp"
coords, instance = open_archive(file)
coords1, instance1 = open_archive(file1)
coords2, instance2 = open_archive(file2)
test_instance(instance, 32, 100, 5, coords)
test_instance(instance1, 33, 100, 5, coords1)
test_instance(intance2, 62, 100, 8, coords1)

routes, total_cost = solve_vrp(instance)
routes1, total_cost1 = solve_vrp(instance1)
routes2, total_cost2 = solve_vrp(instance2)

verify_costs(routes)
verify_costs(routes1)
verify_costs(routes2)