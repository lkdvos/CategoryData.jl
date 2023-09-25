abstract type FusionRing end
abstract type FusionCategory <: FusionRing end
abstract type BraidedCategory <: FusionCategory end

abstract type FR{R,M,N,I} <: FusionRing end

rank(::Type{FR{R,M,N,I}}) where {R,M,N,I} = R
multiplicity(::Type{FR{R,M,N,I}}) where {R,M,N,I} = M
selfduality(::Type{FR{R,M,N,I}}) where {R,M,N,I} = N
ring_index(::Type{FR{R,M,N,I}}) where {R,M,N,I} = I

abstract type UFC{R,M,N,I,D} <: FusionCategory end

rank(::Type{UFC{R,M,N,I,D}}) where {R,M,N,I,D} = R
multiplicity(::Type{UFC{R,M,N,I,D}}) where {R,M,N,I,D} = M
selfduality(::Type{UFC{R,M,N,I,D}}) where {R,M,N,I,D} = N
ring_index(::Type{UFC{R,M,N,I,D}}) where {R,M,N,I,D} = I
category_index(::Type{UFC{R,M,N,I,D}}) where {R,M,N,I,D} = D

abstract type PMFC{R,M,N,I,D₁,D₂} <: BraidedCategory end

rank(::Type{PMFC{R,M,N,I,D₁,D₂}}) where {R,M,N,I,D₁,D₂} = R
multiplicity(::Type{PMFC{R,M,N,I,D₁,D₂}}) where {R,M,N,I,D₁,D₂} = M
selfduality(::Type{PMFC{R,M,N,I,D₁,D₂}}) where {R,M,N,I,D₁,D₂} = N
ring_index(::Type{PMFC{R,M,N,I,D₁,D₂}}) where {R,M,N,I,D₁,D₂} = I
category_index(::Type{PMFC{R,M,N,I,D₁,D₂}}) where {R,M,N,I,D₁,D₂} = D₁
braid_index(::Type{PMFC{R,M,N,I,D₁,D₂}}) where {R,M,N,I,D₁,D₂} = D₂

struct E6 <: FusionCategory end
rank(::Type{E6}) = 3
multiplicity(::Type{E6}) = 2
selfduality(::Type{E6}) = 0
N_artifact(::Type{E6}) = joinpath(artifact_path, "Nsymbols", "E6.txt")
F_artifact(::Type{E6}) = joinpath(artifact_path, "Fsymbols", "E6.txt")

struct A4 <: BraidedCategory end
rank(::Type{A4}) = 4
multiplicity(::Type{A4}) = 2
selfduality(::Type{A4}) = 2
N_artifact(::Type{A4}) = joinpath(artifact_path, "Nsymbols", "A4.txt")
F_artifact(::Type{A4}) = joinpath(artifact_path, "Fsymbols", "A4.txt")
R_artifact(::Type{A4}) = joinpath(artifact_path, "Rsymbols", "A4.txt")
