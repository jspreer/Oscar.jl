########################################################################
# Finding patches                                                      #
########################################################################

function getindex(C::Covering, X::AbsSpec)
  for i in 1:length(patches(C))
    X === patches(C)[i] && return i
  end
  error("affine scheme could not be found among the patches")
end

function Base.in(U::AbsSpec, C::Covering)
  for i in 1:npatches(C)
    U === C[i] && return true
  end
  return false
  ### Affine refinements not implemented at the moment!
#  for i in 1:npatches(C)
#    if haskey(affine_refinements(C), C[i])
#      V = affine_refinements(C)[C[i]]
#      for (V, a) in affine_refinements(C)[C[i]]
#        U in affine_patches(V) && return true
#      end
#    end
#  end
#  return false
end

function Base.indexin(U::AbsSpec, C::Covering)
  for i in 1:npatches(C)
    U === C[i] && return (i, 0, 0)
  end
  return (0,0,0)
  ### Affine refinements not implemented at the moment!
#  for i in 1:npatches(C)
#    if haskey(affine_refinements(C), C[i])
#      V = affine_refinements(C)[C[i]]
#      for j in 1:length(V)
#        (W, a) = V[j]
#        for k in 1:ngens(W)
#          U === W[k] && return (i, j, k)
#        end
#      end
#    end
#  end
#  return (0,0,0)
end

########################################################################
# Functionality for lazy glueing                                       #
########################################################################
function neighbor_patches(C::Covering, U::AbsSpec)
  gg = glueing_graph(C)
  n = neighbors(gg, C[U])
  return [C[i] for i in n]
end

## compute the glueing graph for the given covering and store it
function update_glueing_graph(C::Covering; all_dense::Bool=false)
  n = npatches(C)
  gg = Graph{Undirected}(n)
  for (X, Y) in keys(glueings(C))
    if all_dense
      add_edge!(gg, C[X], C[Y])
      add_edge!(gg, C[Y], C[X])
    else
      (U, V) = glueing_domains(C[X,Y])
      is_dense(U) && add_edge!(gg, C[X], C[Y])
      is_dense(V) && add_edge!(gg, C[Y], C[X])
    end
  end
  C.glueing_graph = gg
  return gg
end

## prune the covering by throwing away empty charts and then compute
## the glueing graph afterwards 
## (relevant data for connectedness of glueing)
function pruned_glueing_graph(C::Covering)
  v = findall(U->!is_empty(U), C.patches)
  m = length(v)
  gt = Graph{Undirected}(m)
  for (X, Y) in keys(glueings(C))
    i = findfirst(==(C[X]),v)
    !isnothing(i) || continue
    j = findfirst(==(C[Y]),v)
    !isnothing(j) || continue
    (U, V) = glueing_domains(C[X,Y])
    is_dense(U) && add_edge!(gt, i, j)
    is_dense(V) && add_edge!(gt, j, i)
  end
  return gt
end

function transition_graph(C::Covering)
  if !isdefined(C, :transition_graph)
    p = length(keys(glueings(C)))
    edge_dict = Dict{Tuple{Int, Int}, Int}()
    edge_count = 1::Int
    C.transition_graph = Graph{Undirected}(0)
    for v in 1:nv(glueing_graph(C))
      W = neighbors(glueing_graph(C), v)
      for i in 1:length(W)-1
        for j in i+1:length(W)
          if is_dense(intersect(glueing_domains(C[W[i],v])[2], glueing_domains(C[v,W[j]])[1]))
            if !haskey(edge_dict, (W[i],v))
              edge_dict[(W[i],v)] = edge_dict[(v, W[i])] = edge_count
              edge_count+=1
              add_vertex!(C.transition_graph)
            end
            if !haskey(edge_dict, (v, W[j]))
              edge_dict[(v, W[j])] = edge_dict[(W[j], v)] = edge_count
              edge_count+=1
              add_vertex!(C.transition_graph)
            end
            add_edge!(C.transition_graph, edge_dict[(W[i],v)], edge_dict[(v,W[j])])
          end
        end
      end
    end
    C.edge_dict = edge_dict
  end
  return C.transition_graph
end

### fill transitions
# Whenever three schemes X ↩ U ↪ Y ↩ V ↪ Z are glued with 
# U ∩ V dense in both U and V, one can infer a glueing of 
# X and Z. This is done by crawling through the glueing graph, 
# updating the glueings, and proceeding until nothing more 
# can be done.
function fill_transitions!(C::Covering)
  gg = glueing_graph(C)
  dirty = true
  while dirty
    dirty = false
    for v in 1:nv(gg)
      W = neighbors(gg, v)
      for i in 1:length(W)-1
        for j in i+1:length(W)
          # TODO: replace the `is_dense` command by one that really checks that the 
          # intersection of U and V is dense in both U and V and not in their ambient 
          # variety. This implementation certainly works, but it is not as general 
          # as it could be, yet. 
          if !has_edge(gg, W[i], W[j]) && is_dense(intersect(glueing_domains(C[W[i],v])[2], glueing_domains(C[v,W[j]])[1]))
            new_glueing = maximal_extension(compose(C[W[i], v], C[v, W[j]]))
            add_glueing!(C, new_glueing)
            add_edge!(gg, W[i], W[j])
            dirty = true
          end
        end
      end
    end
  end
  return C
end

########################################################################
# Iteration over patches                                               #
########################################################################
function Base.length(C::Covering)
  result = 0
  for U in patches(C)
    result = result + 1
    if haskey(affine_refinements(C), U)
      for W in affine_refinements(C)[U]
        result = result + ngens(W)
      end
    end
  end
  return result
end

function all_patches(C::Covering)
  result = Vector{AbsSpec}()
  for U in patches(C)
    push!(result, U)
    if haskey(affine_refinements(C), U)
      for (W, a) in affine_refinements(C)[U]
        result = vcat(result, affine_patches(W))
      end
    end
  end
  return result
end

function Base.iterate(C::Covering, s::Int=1)
  U = all_patches(C)
  s > length(U) && return nothing
  return U[s], s+1
end

Base.eltype(C::Covering) = AbsSpec

########################################################################
# Building a Covering                                                  #
########################################################################
@doc raw"""
    add_glueing!(C::Covering, G::AbsGlueing)

Add a glueing `G` to the covering `C`. 

The `patches` of `G` must be among the `affine_charts` of `C`.

# Examples
```jldoctest
julia> P1, (x,y) = QQ["x", "y"];

julia> P2, (u,v) = QQ["u", "v"];

julia> U1 = Spec(P1);

julia> U2 = Spec(P2);

julia> C = Covering([U1, U2]) # A Covering with two disjoint affine charts
Covering
  described by patches
    1: affine 2-space
    2: affine 2-space
  in the coordinate(s)
    1: [x, y]
    2: [u, v]

julia> V1 = PrincipalOpenSubset(U1, x); # Preparations for glueing

julia> V2 = PrincipalOpenSubset(U2, u);

julia> f = SpecMor(V1, V2, [1//x, y//x]); # The glueing isomorphism

julia> g = SpecMor(V2, V1, [1//u, v//u]); # and its inverse

julia> G = Glueing(U1, U2, f, g); # Construct the glueing

julia> add_glueing!(C, G) # Make the glueing part of the Covering
Covering
  described by patches
    1: affine 2-space
    2: affine 2-space
  in the coordinate(s)
    1: [x, y]
    2: [u, v]

julia> C[U1, U2] == G # Check whether the glueing of U1 and U2 in C is G.
true
```
"""
function add_glueing!(C::Covering, G::AbsGlueing)
  (X, Y) = patches(G)
  C.glueings[(X, Y)] = G
  C.glueings[(Y, X)] = LazyGlueing(Y, X, inverse, G)
  return C
end

########################################################################
# Printing                                                             #
########################################################################

# We print the details on the charts, and we label them
#
# Note: we may more than 10 charts, so we decide to align the labels on the
# right and we need to take of a little left offset for small labels
function Base.show(io::IO, ::MIME"text/plain", C::Covering)
  io = pretty(io)
  if length(C) == 0
    print(io, "Empty covering")
  else
    l = ndigits(length(C))
    println(io, "Covering")
    print(io, Indent(), "described by patches") 
    print(io, Indent())
    for i in 1:length(C)
      li = ndigits(i)
      println(io)
      print(io, " "^(l-li)*"$(i): ", Lowercase(), C[i])
    end
    println(io)
    print(io, Dedent(), "in the coordinate(s)")
    print(io, Indent())
    for i in 1:length(C)
      li = ndigits(i)
      println(io)
      co = coordinates(C[i])
      str = "["*join(co, ", ")*"]"
      print(io, " "^(l-li)*"$(i): ", str)
    end
    print(io, Dedent())
    print(io, Dedent())
  end
end

function Base.show(io::IO, C::Covering)
  if get(io, :supercompact, false)
    print(io, "Covering")
  else
    print(io,  "Covering with ", ItemQuantity(npatches(C), "patch"))
  end
end

########################################################################
# Refinements                                                          #
########################################################################

@doc raw"""
    common_refinement(C::Covering, D::Covering)

For two `Covering`s `C` and `D`, calculate a common refinement 
`E` and return a triple ``(E, φ, ψ)`` with ``φ : E → C`` 
and ``ψ : E → D`` the `CoveringMorphism`s with the inclusion maps. 

!!! note Since the `Covering`s do not know about any `AbsCoveredScheme`, 
the computation of the refinement has to rely on the intrinsic tree
structure of their `patches`. Due to these limitations, only special 
cases are implemented; see the source code for details.
"""
function common_refinement(C::Covering, D::Covering)
  if C === D 
    phi = identity_map(C)
    return C, phi, phi
  end

  success, phi = is_refinement(C, D)
  success && return C, identity_map(C), phi

  success, phi = is_refinement(D, C)
  success && return D, phi, identity_map(D)

  error("case not implemented")
  # We still need to adjust the code below.
  dirty_C = copy(patches(C))
  dirty_D = copy(patches(D))

  map_dict_C = IdDict{AbsSpec, AbsSpecMor}()
  map_dict_D = IdDict{AbsSpec, AbsSpecMor}()
  for U in dirty_C
    if has_ancestor_in(patches(D), U)
      f, _ = _find_chart(U, D)
      map_dict_D[U] = f
      map_dict_C[U] = identity_map(U)
    end
  end
  for U in dirty_D
    if has_ancestor_in(patches(C), U)
      f, _ = _find_chart(U, C)
      map_dict_C[U] = f
      map_dict_D[U] = identity_map(U)
    end
  end

  dirty_C = filter!(x->!(x in keys(map_dict_C)), dirty_C)
  dirty_D = filter!(x->!(x in keys(map_dict_D)), dirty_D)

  #TODO: Check that all leftover dirty patches are already 
  #covered by those in the keysets. What if this is not the case?

  E = Covering(collect(keys(map_dict_C)))
  #TODO: How to inherit the glueings?
  phi = CoveringMorphism(E, C, map_dict_C, check=false)
  psi = CoveringMorphism(E, D, map_dict_D, check=false)
  return E, phi, psi
end

function has_ancestor_in(L::Vector, U::AbsSpec)
  return has_ancestor(x->any(y->(y===x), L), U)
end

function is_refinement(D::Covering, C::Covering)
  if !all(x->has_ancestor(u->any(y->(u===y), patches(C)), x), patches(D))
    return false, nothing
  end
  map_dict = IdDict{AbsSpec, AbsSpecMor}()
  for U in patches(D)
    f, _ = _find_chart(U, C)
    map_dict[U] = f
  end
  return true, CoveringMorphism(D, C, map_dict, check=false)
end

########################################################################
# Base change
########################################################################
function base_change(phi::Any, C::Covering)
  U = patches(C)
  patch_change = [base_change(phi, V) for V in U]

  glueing_dict = IdDict{Tuple{AbsSpec, AbsSpec}, AbsGlueing}()
  for i in 1:length(U)
    (A, map_A) = patch_change[i]
    for j in 1:length(U)
      (B, map_B) = patch_change[j]
      G = C[U[i], U[j]] # the glueing
      GG = base_change(phi, G, patch_change1=map_A, patch_change2=map_B)
      glueing_dict[A, B] = GG
    end
  end
  CC = Covering([V for (V, _) in patch_change], glueing_dict)

  mor_dict = IdDict{AbsSpec, AbsSpecMor}()
  for (V, phi) in patch_change
    mor_dict[V] = phi
  end

  # Maintain decomposition information if applicable
  decomp_dict = IdDict{AbsSpec, Vector{RingElem}}()
  if has_decomposition_info(C)
    for (U, psi) in patch_change
      V = codomain(psi)
      decomp_dict[U] = elem_type(OO(U))[pullback(psi)(a) for a in decomposition_info(C)[V]]
    end
  end
  set_decomposition_info!(CC, decomp_dict)

  return CC, CoveringMorphism(CC, C, mor_dict, check=false)
end
