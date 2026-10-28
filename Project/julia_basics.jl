# I will use Python as reference
using JuMP, Ipopt # This works like import jump, ipopt 

model = Model(Ipopt.Optimizer) # empty model that uses Ipopt solver 

@variable(model, x >= 0) # decision variable x with lower bound 0 
@variable(model, y >= 0) # decision variable y with lower bound 0 

@objective(model, Min, (x - 1)^2 + (y - 2)^2) # minimize this 
@constraint(model, x + y == 2) # subject to this 

optimize!(model) # solve 

println("Status: ", termination_status(model)) 
println("x = ", value(x), ", y = ", value(y))

