# ---------- Generators (Table 3) ----------
# Position i in each list = generator Gi
gen_node = [2, 2, 2, 3, 4, 5, 7, 9, 9]                          # node where Gi sits
P_max    = [0.02, 0.15, 0.08, 0.07, 0.04, 0.17, 0.17, 0.26, 0.05] # capacity [pu]
cost     = [175, 100, 150, 150, 300, 350, 400, 300, 200]         # [SEK/pu]

# ---------- Demand per node (Table 4) ----------
# Position k = node k; 0.0 where there is no consumer
D = [0.10, 0.0, 0.0, 0.19, 0.0, 0.11, 0.0, 0.09, 0.21, 0.05, 0.04]

# ---------- Edges (Table 2) ----------
edges  = [(1,2), (1,11), (2,3), (2,11), (3,4), (3,9), (4,5), (5,6),
          (5,8), (6,7), (7,8), (7,9), (8,9), (9,10), (10,11)]
b_list = [-20.1, -22.3, -16.8, -17.2, -11.7, -19.4, -10.8, -12.3,
          -9.2, -13.9, -8.7, -11.3, -7.7, -13.5, -26.7]
g_list = [4.12, 5.67, 2.41, 2.78, 1.98, 3.23, 1.59, 1.71,
          1.26, 1.11, 1.32, 2.01, 4.41, 2.14, 5.06]

# b and g for BOTH directions -> this builds the arc set A
b = Dict{Tuple{Int,Int}, Float64}()      # empty dict: (k,l) -> number
g = Dict{Tuple{Int,Int}, Float64}()      # creates an empty dict key: Tuple(Int,Int) value: Float64
for e in 1:length(edges)                 # like: for e in range(1, len(edges)+1)
    (k, l) = edges[e]                    # unpack the tuple, like Python
    b[(k, l)] = b_list[e];  b[(l, k)] = b_list[e]
    g[(k, l)] = g_list[e];  g[(l, k)] = g_list[e]
end                                      # Julia blocks close with `end`, no indentation rule

# ---------- Sets ----------
nodes = 1:11                             # like range(1, 12)
gens  = 1:9
arcs  = collect(keys(b))                 # all 30 directed arcs (k, l)


gens_at(k)   = [i for i in gens if gen_node[i] == k]   # G_k  (one-line function) : like def gens_at(k): return... in Python
neighbors(k) = [l for (kk, l) in arcs if kk == k]      # N_k

println("Number of arcs: ", length(arcs))
println("Total demand: ", sum(D))
println("Total capacity: ", sum(P_max))
println("b(1,2) = ", b[(1,2)], ",  b(2,1) = ", b[(2,1)])
println("Generators at node 2: ", gens_at(2))
println("Neighbors of node 3: ", sort(neighbors(3)))