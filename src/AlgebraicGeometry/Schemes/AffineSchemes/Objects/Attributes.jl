########################################################################
# (1) Attributes of AbsSpec
#     coordinate ring and ambient space related methods
########################################################################

# Here is the interface for AbsSpec

@doc raw"""
    coordinate_ring(X::AbsSpec)

On an affine scheme ``X = Spec(R)``, return the ring ``R``.

# Examples
```jldoctest
julia> X = affine_space(QQ,3)
Affine space of dimension 3
  over rational field
with coordinates [x1, x2, x3]

julia> coordinate_ring(X)
Multivariate polynomial ring in 3 variables x1, x2, x3
  over rational field
```
We allow the shortcut `OO`

```jldoctest
julia> X = affine_space(QQ,3)
Affine space of dimension 3
  over rational field
with coordinates [x1, x2, x3]

julia> OO(X)
Multivariate polynomial ring in 3 variables x1, x2, x3
  over rational field
```
"""
coordinate_ring(X::AbsSpec) = OO(X)

@doc raw"""
    OO(X::AbsSpec)

On an affine scheme ``X = Spec(R)``, return the ring ``R``.
"""
function OO(X::AbsSpec{BRT, RT}) where {BRT, RT}
  OO(underlying_scheme(X))::RT
end

@doc raw"""
    total_ring_of_fractions(X::AbsSpec)

Return the total ring of fractions of the coordinate ring of `X`.
"""
@attr function total_ring_of_fractions(X::AbsSpec)
  return total_ring_of_fractions(OO(X))
end

@doc raw"""
    ambient_space(X::AbsSpec)

Return the ambient affine space of ``X``. 

Use [`ambient_embedding(::AbsSpec)`](@ref) to obtain the embedding of ``X`` in
its ambient affine space.

# Examples
```jldoctest
julia> X = affine_space(QQ, [:x,:y])
Affine space of dimension 2
  over rational field
with coordinates [x, y]

julia> ambient_space(X) == X
true

julia> (x, y) = coordinates(X);

julia> Y = subscheme(X, [x])
Spectrum
  of quotient
    of multivariate polynomial ring in 2 variables x, y
      over rational field
    by ideal(x)

julia> X == ambient_space(Y)
true

julia> Z = subscheme(Y, y)
Spectrum
  of quotient
    of multivariate polynomial ring in 2 variables x, y
      over rational field
    by ideal(x, y)

julia> ambient_space(Z) == X
true

julia> V = hypersurface_complement(Y, y)
Spectrum
  of localization
    of quotient
      of multivariate polynomial ring in 2 variables x, y
        over rational field
      by ideal(x)
    at products of (y)

julia> ambient_space(V) == X
true
```

We can create ``X``, ``Y`` and ``Z`` also by first constructing the corresponding
coordinate rings. The subset relations are inferred from the coordinate rings.
More precisely, for a polynomial ring ``P`` an ideal ``I ⊆ P `` and a multiplicatively closed subset
``U`` of ``P`` let ``R`` be one of ``P``, ``U^{-1}P``, ``P/I`` or ``U^{-1}(P/I)``.
In each case the ambient affine space is given by `Spec(P)`.

# Examples
```jldoctest ambient_via_spec
julia> P, (x, y) = polynomial_ring(QQ, [:x, :y])
(Multivariate polynomial ring in 2 variables over QQ, QQMPolyRingElem[x, y])

julia> X = Spec(P)
Spectrum
  of multivariate polynomial ring in 2 variables x, y
    over rational field

julia> I = ideal(P, x)
ideal(x)

julia> RmodI, quotient_map = quo(P, I);

julia> Y = Spec(RmodI)
Spectrum
  of quotient
    of multivariate polynomial ring in 2 variables x, y
      over rational field
    by ideal(x)

julia> ambient_space(Y) == X
true

julia> J = ideal(RmodI, y);

julia> RmodJ, quotient_map2 = quo(RmodI, J);

julia> Z = Spec(RmodJ)
Spectrum
  of quotient
    of multivariate polynomial ring in 2 variables x, y
      over rational field
    by ideal(x, y)

julia> ambient_space(Z) == X
true

julia> U = powers_of_element(y)
Multiplicative subset
  of multivariate polynomial ring in 2 variables over QQ
  given by the products of [y]

julia> URmodI, _ = localization(RmodI, U);

julia> V = Spec(URmodI)
Spectrum
  of localization
    of quotient
      of multivariate polynomial ring in 2 variables x, y
        over rational field
      by ideal(x)
    at products of (y)

julia> ambient_space(V) == X
true
```

Note: compare with `==`, as the same affine space could be represented
internally by different objects for technical reasons.
# Examples
```jldoctest ambient_via_spec
julia> AX = ambient_space(X);

julia> AY = ambient_space(Y);

julia> AX == AY
true

julia> AX === AY
false
```
"""
function ambient_space(X::AbsSpec)
  error("$X does not have an ambient affine space")
end

function ambient_space(X::AbsSpec{BRT, RT}) where {BRT, RT<:MPolyRing}
  return X
end

@attr function ambient_space(X::Spec{BRT,RT}) where {BRT<:Field, RT <: Union{MPolyQuoRing,MPolyLocRing,MPolyQuoLocRing}}
  return variety(Spec(ambient_coordinate_ring(X)), check=false)
end

@attr function ambient_space(X::Spec{BRT,RT}) where {BRT, RT <: Union{MPolyQuoRing,MPolyLocRing,MPolyQuoLocRing}}
  return Spec(ambient_coordinate_ring(X))
end

@attr function ambient_space(X::AbsSpec{BRT,RT}) where {BRT, RT <: Union{MPolyQuoRing,MPolyLocRing,MPolyQuoLocRing}}
  return ambient_space(underlying_scheme(X))
end

@doc raw"""
    ambient_embedding(X::AbsSpec)

Return the embedding of ``X`` in its ambient affine space.

# Examples
```jldoctest
julia> X = affine_space(QQ, [:x,:y])
Affine space of dimension 2
  over rational field
with coordinates [x, y]

julia> (x, y) = coordinates(X);

julia> Y = subscheme(X, [x])
Spectrum
  of quotient
    of multivariate polynomial ring in 2 variables x, y
      over rational field
    by ideal(x)

julia> inc = ambient_embedding(Y)
Affine scheme morphism
  from [x, y]  V(x)
  to   [x, y]  affine 2-space over QQ
given by the pullback function
  x -> 0
  y -> y

julia> inc == inclusion_morphism(Y, X)
true
```
"""
function ambient_embedding(X::AbsSpec)
  return inclusion_morphism(X, ambient_space(X), check=false)
end

@doc raw"""
    ambient_coordinate_ring(X::AbsSpec)

Return the coordinate ring of the ambient affine space of ``X``.

See also [`ambient_space(::AbsSpec)`](@ref).

# Examples
```jldoctest
julia> X = affine_space(QQ, [:x,:y])
Affine space of dimension 2
  over rational field
with coordinates [x, y]

julia> (x,y) = coordinates(X);

julia> Y = subscheme(X, [x])
Spectrum
  of quotient
    of multivariate polynomial ring in 2 variables x, y
      over rational field
    by ideal(x)

julia> ambient_coordinate_ring(Y)
Multivariate polynomial ring in 2 variables x, y
  over rational field
```
"""
function ambient_coordinate_ring(X::AbsSpec)
  return ambient_coordinate_ring(underlying_scheme(X))::MPolyRing
end

@doc raw"""
    ambient_coordinates(X::AbsSpec)

Return the coordinate functions of the ambient affine space of ``X``.

See also [`ambient_space(::AbsSpec)`](@ref).

# Examples
```jldoctest
julia> X = affine_space(QQ, [:x,:y])
Affine space of dimension 2
  over rational field
with coordinates [x, y]

julia> (x,y) = coordinates(X);

julia> Y = subscheme(X, [x])
Spectrum
  of quotient
    of multivariate polynomial ring in 2 variables x, y
      over rational field
    by ideal(x)

julia> coordinates(X) == ambient_coordinates(Y)
true

julia> [x,y] == ambient_coordinates(Y)
true

```
"""
ambient_coordinates(X::AbsSpec) = gens(ambient_coordinate_ring(X))

@doc raw"""
    coordinates(X::AbsSpec)

Return the coordinate functions of ``X`` as elements of its coordinate ring.

For ``X`` a subscheme of an ambient affine space, the coordinate functions are induced
by the ambient affine space.

# Examples
```jldoctest
julia> X = affine_space(QQ, [:x,:y])
Affine space of dimension 2
  over rational field
with coordinates [x, y]

julia> (x, y) = coordinates(X)
2-element Vector{QQMPolyRingElem}:
 x
 y

julia> Y = subscheme(X, [x])
Spectrum
  of quotient
    of multivariate polynomial ring in 2 variables x, y
      over rational field
    by ideal(x)

julia> (xY, yY) = coordinates(Y)
2-element Vector{MPolyQuoRingElem{QQMPolyRingElem}}:
 x
 y

julia> parent(xY) == coordinate_ring(Y)
true
```
"""
coordinates(X::AbsSpec) = gens(OO(X))

@doc raw"""
    base_ring(X::AbsSpec)

On an affine scheme ``X/𝕜`` over ``𝕜`` this returns the ring ``𝕜``.

# Examples
```jldoctest
julia> X = affine_space(QQ,3)
Affine space of dimension 3
  over rational field
with coordinates [x1, x2, x3]

julia> base_ring(X)
Rational field
```
"""
function base_ring(X::AbsSpec{BRT, RT}) where {BRT, RT}
  return base_ring(underlying_scheme(X))::BRT
end

##############################################################################
# (2) Attributes of AbsSpec
#     dimension, codimension, name
##############################################################################

@doc raw"""
    dim(X::AbsSpec)

Return the dimension the affine scheme ``X = Spec(R)``.

By definition, this is the Krull dimension of ``R``.

# Examples
```jldoctest
julia> X = affine_space(QQ,3)
Affine space of dimension 3
  over rational field
with coordinates [x1, x2, x3]

julia> dim(X)
3

julia> Y = affine_space(ZZ, 2)
Spectrum
  of multivariate polynomial ring in 2 variables x1, x2
    over integer ring

julia> dim(Y) # one dimension comes from ZZ and two from x1 and x2
3
```
"""
dim(X::AbsSpec)

@attr function dim(X::AbsSpec{<:Ring, <:MPolyQuoLocRing})
  error("Not implemented")
end

@attr function dim(X::AbsSpec{<:Ring, <:MPolyQuoLocRing{<:Any,<:Any,<:MPolyRing,<:MPolyRingElem, <:MPolyPowersOfElement}})
  return dim(closure(X))
end

@attr function dim(X::AbsSpec{<:Ring, <:MPolyQuoLocRing{<:Any,<:Any,<:MPolyRing,<:MPolyRingElem, <:Union{MPolyComplementOfPrimeIdeal, MPolyComplementOfKPointIdeal}}})
  # Spec (R / I)_P
  R = OO(X)
  P = prime_ideal(inverted_set(R))
  I = saturated_ideal(modulus(R))
  return dim(I) - dim(P)
end

@attr function dim(X::AbsSpec{<:Ring, <:MPolyLocRing})
  error("Not implemented")
end

@attr function dim(X::AbsSpec{<:Ring, <:MPolyLocRing{<:Any,<:Any,<:MPolyRing,<:MPolyRingElem, <:MPolyPowersOfElement}})
  # zariski open subset of A^n
  return dim(closure(X))
end

@attr function dim(X::AbsSpec{<:Ring, <:MPolyLocRing{<:Any,<:Any,<:MPolyRing,<:MPolyRingElem, <:Union{MPolyComplementOfPrimeIdeal, MPolyComplementOfKPointIdeal}}})
  P = prime_ideal(inverted_set(OO(X)))
  return codim(P)
end

@attr function dim(X::AbsSpec{<:Ring, <:MPolyRing})
  return dim(ideal(ambient_coordinate_ring(X), [zero(ambient_coordinate_ring(X))]))
end

@attr function dim(X::AbsSpec{<:Ring, <:MPolyQuoRing})
  return dim(modulus(OO(X)))
end

@doc raw"""
    codim(X::AbsSpec)

Return the codimension of ``X`` in its ambient affine space.

Throws and error if ``X`` does not have an ambient affine space.

# Examples
```jldoctest
julia> X = affine_space(QQ,3)
Affine space of dimension 3
  over rational field
with coordinates [x1, x2, x3]

julia> codim(X)
0

julia> R = OO(X)
Multivariate polynomial ring in 3 variables x1, x2, x3
  over rational field

julia> (x1,x2,x3) = gens(R)
3-element Vector{QQMPolyRingElem}:
 x1
 x2
 x3

julia> Y = subscheme(X, x1)
Spectrum
  of quotient
    of multivariate polynomial ring in 3 variables x1, x2, x3
      over rational field
    by ideal(x1)

julia> codim(Y)
1
```
"""
@attr function codim(X::AbsSpec)
  return dim(ideal(ambient_coordinate_ring(X), [zero(ambient_coordinate_ring(X))])) - dim(X)
end


@doc raw"""
    name(X::AbsSpec)

Return the current name of an affine scheme.

This name can be specified via `set_name!`.

# Examples
```jldoctest
julia> X = affine_space(QQ, 3)
Affine space of dimension 3
  over rational field
with coordinates [x1, x2, x3]

julia> name(X)
"unnamed affine variety"

julia> set_name!(X, "affine 3-dimensional space")

julia> name(X)
"affine 3-dimensional space"
```
"""
@attr String function name(X::AbsSpec)
  return "unnamed affine variety"
end


function set_name!(X::AbsSpec, name::String)
  return set_attribute!(X, :name, name)
end

#############################################################################
# (3) Attributes of AbsSpec
#     reduced scheme and singular locus
#############################################################################
# TODO: projective schemes, covered schemes

@doc raw"""
   reduced_scheme(X::AbsSpec{<:Field, <:MPolyAnyRing})

Return the induced reduced scheme of `X`.

Currently, this command is available for affine schemes and space germs.
 
This command relies on [`radical`](@ref).

# Examples
```jldoctest
julia> R, (x, y) = polynomial_ring(QQ, ["x", "y"])
(Multivariate polynomial ring in 2 variables over QQ, QQMPolyRingElem[x, y])

julia> J = ideal(R,[(x-y)^2])
ideal(x^2 - 2*x*y + y^2)

julia> X = Spec(R,J)
Spectrum
  of quotient
    of multivariate polynomial ring in 2 variables x, y
      over rational field
    by ideal(x^2 - 2*x*y + y^2)

julia> U = complement_of_point_ideal(R, [0,0])
Complement
  of maximal ideal corresponding to rational point with coordinates (0, 0)
  in multivariate polynomial ring in 2 variables over QQ

julia> Y = Spec(R,J,U)
Spectrum
  of localization
    of quotient
      of multivariate polynomial ring in 2 variables x, y
        over rational field
      by ideal(x^2 - 2*x*y + y^2)
    at complement of maximal ideal of point (0, 0)

julia> reduced_scheme(X)
(V(x^2 - 2*x*y + y^2, x - y), Hom: V(x^2 - 2*x*y + y^2, x - y) -> V(x^2 - 2*x*y + y^2))

julia> reduced_scheme(Y)
(Spec of localization of quotient of multivariate polynomial ring at complement of maximal ideal, Hom: Spec of localization of quotient of multivariate polynomial ring at complement of maximal ideal -> Spec of localization of quotient of multivariate polynomial ring at complement of maximal ideal)

```
"""
@attr function reduced_scheme(X::AbsSpec{<:Field, <:MPolyQuoLocRing})
  if has_attribute(X, :is_reduced) && is_reduced(X)
    return X, identity_map(X)
  end
  I = modulus(OO(X))
  J = radical(pre_saturated_ideal(I))
  inc = ClosedEmbedding(X, ideal(OO(X), OO(X).(gens(J))), check=false)
  Xred, inc = domain(inc), inc
  set_attribute!(Xred, :is_reduced=>true)
  return Xred, inc
end

@attr function reduced_scheme(X::AbsSpec{<:Field, <:MPolyQuoRing})
  if has_attribute(X, :is_reduced) && is_reduced(X)
    return X, identity_map(X)
  end
  J = radical(modulus(OO(X)))
  inc = ClosedEmbedding(X, ideal(OO(X), OO(X).(gens(J))), check=false)
  Xred, inc = domain(inc), inc
  set_attribute!(Xred, :is_reduced=>true)
  return Xred, inc
end

## to make reduced_scheme agnostic for quotient ring
@attr function reduced_scheme(X::AbsSpec{<:Field, <:MPAnyNonQuoRing})
  return X, ClosedEmbedding(X, ideal(OO(X), one(OO(X))), check=false)
end

function reduced_scheme(X::AbsSpec)
  error("method 'reduced_scheme(X)' currently only implemented for affine Schemes and Space Germs over a field")
end

### TODO: The following two functions (singular_locus, 
###       singular_locus_reduced) need to be made type-sensitive 
###       and reduced=true needs to be set automatically for varieties 
###       as soon as not only schemes, but also varieties as separate
###       type have been introduced in OSCAR
### TODO: Make singular locus also available for projective schemes and
###       for covered schemes (using the workhorse here...).
 
@doc raw"""
    singular_locus(X::Scheme{<:Field}) -> (Scheme, SchemeMor)

Return the singular locus of `X`.

For computing the singular locus of the reduced scheme induced by `X`,
please use [`singular_locus_reduced`](@ref).

Currently this command is available for affine schemes and for space germs.

Over non-perfect fields, this command returns the non-smooth locus and `X`
may still be regular at some points of the returned subscheme.

See also [`is_smooth`](@ref).

# Examples
```jldoctest
julia> R, (x,y,z) = QQ["x", "y", "z"]
(Multivariate polynomial ring in 3 variables over QQ, QQMPolyRingElem[x, y, z])

julia> I = ideal(R, [x^2 - y^2 + z^2])
ideal(x^2 - y^2 + z^2)

julia> A3 = Spec(R)
Spectrum
  of multivariate polynomial ring in 3 variables x, y, z
    over rational field

julia> X = Spec(R,I)
Spectrum
  of quotient
    of multivariate polynomial ring in 3 variables x, y, z
      over rational field
    by ideal(x^2 - y^2 + z^2)

julia> singular_locus(A3)
(V(1), Hom: V(1) -> affine 3-space)

julia> singular_locus(X)
(V(x^2 - y^2 + z^2, z, y, x), Hom: V(x^2 - y^2 + z^2, z, y, x) -> V(x^2 - y^2 + z^2))

julia> U = complement_of_point_ideal(R, [0,0,0])
Complement
  of maximal ideal corresponding to rational point with coordinates (0, 0, 0)
  in multivariate polynomial ring in 3 variables over QQ

julia> Y = Spec(R,I,U)
Spectrum
  of localization
    of quotient
      of multivariate polynomial ring in 3 variables x, y, z
        over rational field
      by ideal(x^2 - y^2 + z^2)
    at complement of maximal ideal of point (0, 0, 0)

julia> singular_locus(Y)
(Spec of localization of quotient of multivariate polynomial ring at complement of maximal ideal, Hom: Spec of localization of quotient of multivariate polynomial ring at complement of maximal ideal -> Spec of localization of quotient of multivariate polynomial ring at complement of maximal ideal)

```
"""
function singular_locus(X::AbsSpec{<:Field, <:MPAnyQuoRing})
  comp = _singular_locus_with_decomposition(X,false)
  if length(comp) == 0
    set_attribute!(X, :is_smooth, true)
    inc = ClosedEmbedding(X, ideal(OO(X), one(OO(X))))
    return domain(inc), inc
  end
  R = base_ring(OO(X))
  I = prod([modulus(underlying_quotient(OO(Y))) for Y in comp])
  I = radical(I)
  set_attribute!(X, :is_smooth, false)
  inc = ClosedEmbedding(X, ideal(OO(X), OO(X).(gens(I))))
  return domain(inc), inc
end

# make singular_locus agnostic to quotient
function singular_locus(X::AbsSpec{<:Field, <:MPAnyNonQuoRing})
  set_attribute!(X, :is_smooth,true)
  inc = ClosedEmbedding(X, ideal(OO(X), one(OO(X))))
  return domain(inc), inc
end

# TODO: Covered schemes, projective schemes

@doc raw"""
    singular_locus_reduced(X::Scheme{<:Field}) -> (Scheme, SchemeMor)

Return the singular locus of the reduced scheme ``X_{red}`` induced by `X`.

For computing the singular locus of `X` itself, please use 
['singular_locus](@ref)'.

Currently this command is available for affine schemes and for space germs.

Over non-perfect fields, this command returns the non-smooth locus and
`X_{red}` may still be regular at some points of the returned subscheme.

See also [`is_smooth`](@ref).

# Examples
```jldoctest
julia> R, (x,y,z) = QQ["x", "y", "z"]
(Multivariate polynomial ring in 3 variables over QQ, QQMPolyRingElem[x, y, z])

julia> I = ideal(R, [(x^2 - y^2 + z^2)^2])
ideal(x^4 - 2*x^2*y^2 + 2*x^2*z^2 + y^4 - 2*y^2*z^2 + z^4)

julia> X = Spec(R,I)
Spectrum
  of quotient
    of multivariate polynomial ring in 3 variables x, y, z
      over rational field
    by ideal(x^4 - 2*x^2*y^2 + 2*x^2*z^2 + y^4 - 2*y^2*z^2 + z^4)

julia> singular_locus_reduced(X)
(V(x^4 - 2*x^2*y^2 + 2*x^2*z^2 + y^4 - 2*y^2*z^2 + z^4, z, y, x), Hom: V(x^4 - 2*x^2*y^2 + 2*x^2*z^2 + y^4 - 2*y^2*z^2 + z^4, z, y, x) -> V(x^4 - 2*x^2*y^2 + 2*x^2*z^2 + y^4 - 2*y^2*z^2 + z^4))

julia> singular_locus(X)
(V(x^4 - 2*x^2*y^2 + 2*x^2*z^2 + y^4 - 2*y^2*z^2 + z^4, x^2 - y^2 + z^2), Hom: V(x^4 - 2*x^2*y^2 + 2*x^2*z^2 + y^4 - 2*y^2*z^2 + z^4, x^2 - y^2 + z^2) -> V(x^4 - 2*x^2*y^2 + 2*x^2*z^2 + y^4 - 2*y^2*z^2 + z^4))

```
"""
function singular_locus_reduced(X::AbsSpec{<:Field, <:MPAnyQuoRing})
  comp =  _singular_locus_with_decomposition(X, true)
  I= ideal(ambient_coordinate_ring(X),one(ambient_coordinate_ring(X)))
  for Z in comp
    I = intersect(I, modulus(underlying_quotient(OO(Z))))
    # TODO: Already compute intermediate radicals?
  end
  I = radical(I)
  inc = ClosedEmbedding(X, ideal(OO(X), OO(X).(gens(I))))
  return domain(inc), inc
end

# make singular_locus_reduced agnostic to quotient
function singular_locus_reduced(X::AbsSpec{<:Field, <:MPAnyNonQuoRing})
  inc = ClosedEmbedding(X, ideal(OO(X), one(OO(X))))
  return domain(inc), inc
end

# internal workhorse, not user-facing
function _singular_locus_with_decomposition(X::AbsSpec{<:Field, <:MPAnyQuoRing}, reduced::Bool=true)
  I = saturated_ideal(modulus(OO(X)))
  empty = typeof(X)[]
  result = empty

# equidimensional decomposition to allow Jacobian criterion on each component
  P = Ideal[]

  if has_attribute(X, :is_equidimensional) && is_equidimensional(X) && !reduced 
    push!(P, I)
  else 
    if reduced
      P = equidimensional_decomposition_radical(I)
    else
      P = equidimensional_decomposition_weak(I)
    end
  end

# if irreducible, just do Jacobian criterion
  if length(P)==1 && !reduced
    d = dim(X)
    R = base_ring(I)
    n = nvars(R) 
    M = _jacobian_matrix_modulus(X)
    minvec = minors(M, n-d)
    J = ideal(R, minvec)
    JX = ideal(OO(X),minvec)
    one(OO(X)) in JX && return empty
    return [subscheme(X, J)]
  else
# if reducible, determine pairwise intersection loci
    components = [subscheme(X, J) for J in P]
    for i in 1:length(components)
      for j in (i+1):length(components)
        W = intersect(components[i],components[j])
        if !isempty(W) 
          push!(result, W)
        end
      end
    end
# and singular loci of components
    for Y in components
      result = vcat(result, singular_locus(Y)[1])
    end
  one(OO(X)) in result && return empty
  end
  return result
end

## cheaper version of jacobian_matrix specifically for Jacobian matrix of modulus
## compute *some* representative of the Jacobian matrix of gens(modulus),
## forgetting about the denominators (contribution killed by modulus anyway)

function _jacobian_matrix_modulus(X::AbsSpec{<:Ring, <:MPAnyQuoRing})
  g = gens(modulus(underlying_quotient(OO(X))))
  L = base_ring(underlying_quotient(OO(X)))
  n = nvars(L)
  M = matrix(L, n, length(g),[derivative(f,i) for i=1:n for f in g])
  return M
end

########################################################################
# (X) Attributes for AbsSpec   to be deleted
#     
########################################################################

# TODO: ambient_closure_ideal should be deleted

@doc raw"""
    ambient_closure_ideal(X::AbsSpec{<:Any, <:MPolyRing})

Return the defining ideal of the closure of ``X`` in its ambient affine space.

# Examples
```jldoctest
julia> X = affine_space(QQ,3)
Affine space of dimension 3
  over rational field
with coordinates [x1, x2, x3]

julia> R = OO(X)
Multivariate polynomial ring in 3 variables x1, x2, x3
  over rational field

julia> (x1,x2,x3) = gens(R)
3-element Vector{QQMPolyRingElem}:
 x1
 x2
 x3

julia> Y = subscheme(X, ideal(R, [x1*x2]))
Spectrum
  of quotient
    of multivariate polynomial ring in 3 variables x1, x2, x3
      over rational field
    by ideal(x1*x2)

julia> I = Oscar.ambient_closure_ideal(Y)
ideal(x1*x2)

julia> base_ring(I) == OO(Y)
false

julia> base_ring(I) == R
true
```
"""
@attr ambient_closure_ideal(X::AbsSpec{<:Any, <:MPolyRing}) = ideal(OO(X), [zero(OO(X))])
ambient_closure_ideal(X::AbsSpec{<:Any, <:MPolyQuoRing}) = modulus(OO(X))
@attr ambient_closure_ideal(X::AbsSpec{<:Any, <:MPolyLocRing}) = ideal(ambient_coordinate_ring(X), [zero(ambient_coordinate_ring(X))])
ambient_closure_ideal(X::AbsSpec{<:Any, <:MPolyQuoLocRing}) = saturated_ideal(modulus(OO(X)))


########################################################################
# (4) Implementation of the AbsSpec interface for the basic Spec
########################################################################

OO(X::Spec) = X.OO
base_ring(X::Spec) = X.kk
ambient_coordinate_ring(X::Spec{<:Any, <:MPolyRing}) = OO(X)
ambient_coordinate_ring(X::Spec{<:Any, <:MPolyQuoRing}) = base_ring(OO(X))
ambient_coordinate_ring(X::Spec{<:Any, <:MPolyLocRing}) = base_ring(OO(X))
ambient_coordinate_ring(X::Spec{<:Any, <:MPolyQuoLocRing}) = base_ring(OO(X))
ambient_coordinate_ring(X::Spec{T, T}) where {T<:Field} = base_ring(X)



########################################################################
# (5) Type getters
########################################################################

# TODO: Needed?

ring_type(::Type{SpecType}) where {BRT, RT, SpecType<:AbsSpec{BRT, RT}} = RT
ring_type(X::AbsSpec) = ring_type(typeof(X))

base_ring_type(::Type{SpecType}) where {BRT, RT, SpecType<:AbsSpec{BRT, RT}} = BRT
base_ring_type(X::AbsSpec) = base_ring_type(typeof(X))
base_ring_elem_type(::Type{SpecType}) where {BRT, RT, SpecType<:AbsSpec{BRT, RT}} = elem_type(BRT)
base_ring_elem_type(X::AbsSpec) = base_ring_elem_type(typeof(X))

poly_type(::Type{SpecType}) where {BRT, RT<:MPolyRing, SpecType<:AbsSpec{BRT, RT}} = elem_type(RT)
poly_type(::Type{SpecType}) where {BRT, T, RT<:MPolyQuoRing{T}, SpecType<:AbsSpec{BRT, RT}} = T
poly_type(::Type{SpecType}) where {BRT, T, RT<:MPolyLocRing{<:Any, <:Any, <:Any, T}, SpecType<:AbsSpec{BRT, RT}} = T
poly_type(::Type{SpecType}) where {BRT, T, RT<:MPolyQuoLocRing{<:Any, <:Any, <:Any, T}, SpecType<:AbsSpec{BRT, RT}} = T
poly_type(X::AbsSpec) = poly_type(typeof(X))

ring_type(::Type{Spec{BRT, RT}}) where {BRT, RT} = RT
ring_type(X::Spec) = ring_type(typeof(X))
base_ring_type(::Type{Spec{BRT, RT}}) where {BRT, RT} = BRT
base_ring_type(X::Spec) = base_ring_type(typeof(X))

