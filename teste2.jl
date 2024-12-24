include("instance.jl")
include("model.jl")

export open_archive, build_vrp_model, solve_vrp, show_results, create_test_instance

instance = create_test_instance()
result = solve_vrp(instance)          # This is a test with smaller instance for see how the results ends
show_results(instance, result)
