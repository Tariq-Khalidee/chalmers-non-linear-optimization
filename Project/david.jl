using JuMP
using Ipopt
# --------------------------------------------------
# NETWORK DATA
# --------------------------------------------------

nb = 11

# Endpoints of each undirected transmission line
edge_from = [
    1, 1, 2, 2, 3, 3, 4, 5, 5, 6, 7, 7, 8, 9, 10
]

edge_to = [
    2, 11, 3, 11, 4, 9, 5, 6, 8, 7, 8, 9, 9, 10, 11
]

# Line conductance
g_edge = [
    4.12, 5.67, 2.41, 2.78, 1.98,
    3.23, 1.59, 1.71, 1.26, 1.11,
    1.32, 2.01, 4.41, 2.14, 5.06
]

# Line susceptance
b_edge = [
    -20.1, -22.3, -16.8, -17.2, -11.7,
    -19.4, -10.8, -12.3, -9.2, -13.9,
    -8.7, -11.3, -7.7, -13.5, -26.7
]

# Represent each physical line in both directions
from_node = vcat(edge_from, edge_to)
to_node = vcat(edge_to, edge_from)
g_line = vcat(g_edge, g_edge)
b_line = vcat(b_edge, b_edge)

na = length(from_node)

# Voltage magnitude bounds
vmin = 0.98
vmax = 1.02

# --------------------------------------------------
# GENERATORS AND DEMAND
# --------------------------------------------------

ng = 9
gen_node = [2, 2, 2, 3, 4, 5, 7, 9, 9]

# Maximum active generation
pmax = [
    0.02, 0.15, 0.08, 0.07, 0.04,
    0.17, 0.17, 0.26, 0.05
]

# Production costs
cost = [
    175.0, 100.0, 150.0, 150.0, 300.0,
    350.0, 400.0, 300.0, 200.0
]

# Reactive generation bounds
qmax = 0.03 .* pmax

# Active power demand
demand = zeros(nb)
demand[1] = 0.10
demand[4] = 0.19
demand[6] = 0.11
demand[8] = 0.09
demand[9] = 0.21
demand[10] = 0.05
demand[11] = 0.04

# Generators connected to each node
gens_at_node = [
    [g for g in 1:ng if gen_node[g] == k]
    for k in 1:nb
]

# Outgoing arcs at each node
arcs_out = [
    [a for a in 1:na if from_node[a] == k]
    for k in 1:nb
]

# --------------------------------------------------
# OPTIMIZATION MODEL
# --------------------------------------------------

model = Model(Ipopt.Optimizer)

# Generator output
@variable(model, 0 <= Pg[g = 1:ng] <= pmax[g])
@variable(model, -qmax[g] <= Qg[g = 1:ng] <= qmax[g])

# Node voltage magnitudes and phase angles
@variable(model, vmin <= voltage[k = 1:nb] <= vmax)
@variable(model, -pi <= theta[k = 1:nb] <= pi)

# Active and reactive flows on directed arcs
@variable(model, p[1:na])
@variable(model, q[1:na])

# Initial values for the nonlinear solver
for k in 1:nb
    set_start_value(voltage[k], 1.0)
    set_start_value(theta[k], 0.0)
end

for g in 1:ng
    initial_power = pmax[g] * sum(demand) / sum(pmax)
    set_start_value(Pg[g], initial_power)
    set_start_value(Qg[g], 0.0)
end

for a in 1:na
    set_start_value(p[a], 0.0)
    set_start_value(q[a], 0.0)
end

# Reference angle
@constraint(model, theta[1] == 0.0)

# Active power flow equations
@NLconstraint(model, active_flow[a = 1:na],
    p[a] == voltage[from_node[a]]^2 * g_line[a] -
        voltage[from_node[a]] * voltage[to_node[a]] * (
            g_line[a] *
            cos(theta[from_node[a]] - theta[to_node[a]]) +
            b_line[a] *
            sin(theta[from_node[a]] - theta[to_node[a]])
        )
)

# Reactive power flow equations
@NLconstraint(model, reactive_flow[a = 1:na],
    q[a] == -voltage[from_node[a]]^2 * b_line[a] +
        voltage[from_node[a]] * voltage[to_node[a]] * (
            b_line[a] *
            cos(theta[from_node[a]] - theta[to_node[a]]) -
            g_line[a] *
            sin(theta[from_node[a]] - theta[to_node[a]])
        )
)

# Active power balance at each node
@constraint(model, active_balance[k = 1:nb],
    sum(Pg[g] for g in gens_at_node[k]) - demand[k] ==
    sum(p[a] for a in arcs_out[k])
)

# Reactive power balance at each node
@constraint(model, reactive_balance[k = 1:nb],
    sum(Qg[g] for g in gens_at_node[k]) ==
    sum(q[a] for a in arcs_out[k])
)

# Minimize total generation cost
@objective(model, Min,
    sum(cost[g] * Pg[g] for g in 1:ng)
)

# Solve the optimization problem
optimize!(model)

# --------------------------------------------------
# RESULTS
# --------------------------------------------------

println("Termination status: ", termination_status(model))
println("Primal status: ", primal_status(model))

# Report results when a feasible solution is available
if primal_status(model) == JuMP.MOI.FEASIBLE_POINT
    println("Production cost [SEK]: ", objective_value(model))
    println("Active generation [pu]: ", value.(Pg))
    println("Reactive generation [pu]: ", value.(Qg))
    println("Voltage magnitudes [vu]: ", value.(voltage))
    println("Phase angles [rad]: ", value.(theta))

    println("\nDirected line flows [pu]:")
    for a in 1:na
        println(
            from_node[a], " -> ", to_node[a],
            ": active = ", value(p[a]),
            ", reactive = ", value(q[a])
        )
    end

    total_generation = sum(value.(Pg))
    total_demand = sum(demand)

    println("\nTotal active generation [pu]: ", total_generation)
    println("Total active demand [pu]: ", total_demand)
    println(
        "Total active line losses [pu]: ",
        total_generation - total_demand
    )
else
    println("No feasible solution was returned.")
end