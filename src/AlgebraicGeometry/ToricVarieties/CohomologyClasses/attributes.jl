########################
# Attributes of cohomology classes
########################

@doc raw"""
    toric_variety(c::CohomologyClass)

Return the normal toric variety of the cohomology class `c`.

# Examples
```jldoctest
julia> dP2 = del_pezzo_surface(NormalToricVariety, 2)
Normal toric variety

julia> d = toric_divisor(dP2, [1, 2, 3, 4, 5])
Torus-invariant, non-prime divisor on a normal toric variety

julia> cc = cohomology_class(d)
Cohomology class on a normal toric variety given by 6*x3 + e1 + 7*e2

julia> toric_variety(cc)
Normal, simplicial, complete toric variety
```
"""
toric_variety(c::CohomologyClass) = c.v


@doc raw"""
    coefficients(c::CohomologyClass)

Return the coefficients of the cohomology class `c`.

# Examples
```jldoctest
julia> dP2 = del_pezzo_surface(NormalToricVariety, 2)
Normal toric variety

julia> d = toric_divisor(dP2, [1, 2, 3, 4, 5])
Torus-invariant, non-prime divisor on a normal toric variety

julia> cc = cohomology_class(d)
Cohomology class on a normal toric variety given by 6*x3 + e1 + 7*e2

julia> coefficients(cc)
3-element Vector{QQFieldElem}:
 6
 1
 7
```
"""
coefficients(c::CohomologyClass) = [coefficient_ring(toric_variety(c))(k) for k in AbstractAlgebra.coefficients(polynomial(c).f)]


@doc raw"""
    exponents(c::CohomologyClass)

Return the exponents of the cohomology class `c`.

# Examples
```jldoctest
julia> dP2 = del_pezzo_surface(NormalToricVariety, 2)
Normal toric variety

julia> d = toric_divisor(dP2, [1, 2, 3, 4, 5])
Torus-invariant, non-prime divisor on a normal toric variety

julia> cc = cohomology_class(d)
Cohomology class on a normal toric variety given by 6*x3 + e1 + 7*e2

julia> exponents(cc)
[0   0   1   0   0]
[0   0   0   1   0]
[0   0   0   0   1]
```
"""
function exponents(c::CohomologyClass) 
  simplify!(c)
  matrix(ZZ, [k for k in AbstractAlgebra.exponent_vectors(polynomial(c).f)])
end

function simplify!(c::CohomologyClass)
  c.p = simplify(c.p)
end

@doc raw"""
    polynomial(c::CohomologyClass)

Return the polynomial in the cohomology ring of the normal
toric variety `toric_variety(c)` which corresponds to `c`.

# Examples
```jldoctest
julia> dP2 = del_pezzo_surface(NormalToricVariety, 2)
Normal toric variety

julia> d = toric_divisor(dP2, [1, 2, 3, 4, 5])
Torus-invariant, non-prime divisor on a normal toric variety

julia> cc = cohomology_class(d)
Cohomology class on a normal toric variety given by 6*x3 + e1 + 7*e2

julia> polynomial(cc)
6*x3 + e1 + 7*e2
```
"""
polynomial(c::CohomologyClass) = c.p


@doc raw"""
    polynomial(c::CohomologyClass, ring::MPolyQuoRing)

Return the polynomial in `ring` corresponding
to the cohomology class `c`.

# Examples
```jldoctest
julia> dP2 = del_pezzo_surface(NormalToricVariety, 2)
Normal toric variety

julia> d = toric_divisor(dP2, [1, 2, 3, 4, 5])
Torus-invariant, non-prime divisor on a normal toric variety

julia> cc = cohomology_class(d)
Cohomology class on a normal toric variety given by 6*x3 + e1 + 7*e2

julia> R, _ = polynomial_ring(QQ, 5)
(Multivariate polynomial ring in 5 variables over QQ, QQMPolyRingElem[x1, x2, x3, x4, x5])

julia> (x1, x2, x3, x4, x5) = gens(R)
5-element Vector{QQMPolyRingElem}:
 x1
 x2
 x3
 x4
 x5

julia> sr_and_linear_relation_ideal = ideal([x1*x3, x1*x5, x2*x4, x2*x5, x3*x4, x1 + x2 - x5, x2 + x3 - x4 - x5])
ideal(x1*x3, x1*x5, x2*x4, x2*x5, x3*x4, x1 + x2 - x5, x2 + x3 - x4 - x5)

julia> R_quo = quo(R, sr_and_linear_relation_ideal)[1]
Quotient
  of multivariate polynomial ring in 5 variables x1, x2, x3, x4, x5
    over rational field
  by ideal(x1*x3, x1*x5, x2*x4, x2*x5, x3*x4, x1 + x2 - x5, x2 + x3 - x4 - x5)

julia> polynomial(R_quo, cc)
6*x3 + x4 + 7*x5
```
"""
function polynomial(ring::MPolyQuoRing, c::CohomologyClass)
    p = polynomial(c)
    if iszero(p)
        return zero(ring)
    end
    coeffs = [k for k in AbstractAlgebra.coefficients(p.f)]
    expos = matrix(ZZ, [k for k in AbstractAlgebra.exponent_vectors(p.f)])
    indets = gens(ring)
    monoms = [prod(indets[j]^expos[k, j] for j in 1:ncols(expos)) for k in 1:nrows(expos)]
    return sum(coeffs[k]*monoms[k] for k in 1:length(monoms))
end
