using JuMP, Ipopt
include("data.jl")       # like `from data import *`: runs data.jl here

model = Model(Ipopt.Optimizer)

# ---------- Decision variables, with bounds ----------
@variable(model, 0 <= P[i in gens] <= P_max[i])                        # active power
@variable(model, -0.03*P_max[i] <= Q[i in gens] <= 0.03*P_max[i])      # reactive power
@variable(model, 0.98 <= v[k in nodes] <= 1.02)                        # voltage amplitude
@variable(model, -pi <= theta[k in nodes] <= pi)                       # voltage angle

# ---------- Objective ----------
@objective(model, Min, sum(cost[i] * P[i] for i in gens))



# ---------- Active power flow on arc (k,l) ----------
p_flow(k, l) = v[k]^2 * g[(k,l)] -
               v[k]*v[l]*g[(k,l)]*cos(theta[k] - theta[l]) -
               v[k]*v[l]*b[(k,l)]*sin(theta[k] - theta[l])

# ---------- Active power balance at every node ----------
@constraint(model, active_balance[k in nodes],
    sum(P[i] for i in gens_at(k); init = 0) - D[k] ==
    sum(p_flow(k, l) for l in neighbors(k)))

# ---------- Reactive power flow on arc (k,l) ----------
q_flow(k, l) = -v[k]^2 * b[(k,l)] +
               v[k]*v[l]*b[(k,l)]*cos(theta[k] - theta[l]) -
               v[k]*v[l]*g[(k,l)]*sin(theta[k] - theta[l])

# ---------- Reactive power balance at every node ----------
@constraint(model, reactive_balance[k in nodes],
    sum(Q[i] for i in gens_at(k); init = 0) ==
    sum(q_flow(k, l) for l in neighbors(k)))

@constraint(model, reference_angle, theta[1] == 0)


# ---------- Solve and print ----------
optimize!(model)

println("Total production: ", sum(value.(P)))
println("Status: ", termination_status(model))
println("Cost: ", objective_value(model))
println("P = ", value.(P))
println("Q = ", value.(Q))

println("theta = ", round.(value.(theta), digits = 5))

println("\nEdge      p_kl      p_lk      p_kl+p_lk   q_kl      q_lk")
for (k, l) in edges
    pkl = value(p_flow(k, l));  plk = value(p_flow(l, k))
    qkl = value(q_flow(k, l));  qlk = value(q_flow(l, k))
    println("($k,$l)   ", round(pkl, digits=5), "   ", round(plk, digits=5), "   ",
            round(pkl + plk, digits=6), "   ", round(qkl, digits=5), "   ", round(qlk, digits=5))
end
total_loss = sum(value(p_flow(k, l)) + value(p_flow(l, k)) for (k, l) in edges)
println("Total active losses: ", total_loss)