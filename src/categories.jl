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

struct RepA4 <: BraidedCategory end
rank(::Type{RepA4}) = 4
multiplicity(::Type{RepA4}) = 2
selfduality(::Type{RepA4}) = 2
N_artifact(::Type{RepA4}) = joinpath(artifact_path, "Nsymbols", "RepA4.txt")
F_artifact(::Type{RepA4}) = joinpath(artifact_path, "Fsymbols", "RepA4.txt")
R_artifact(::Type{RepA4}) = joinpath(artifact_path, "Rsymbols", "RepA4.txt")
fusiontensor_artifact(::Type{RepA4}) = joinpath(artifact_path, "fusiontensors", "RepA4.txt")

struct ZVecS3 <: BraidedCategory end
rank(::Type{ZVecS3}) = 8
multiplicity(::Type{ZVecS3}) = 1
selfduality(::Type{ZVecS3}) = 8
N_artifact(::Type{ZVecS3}) = joinpath(artifact_path, "Nsymbols", "ZVecS3.txt")
F_artifact(::Type{ZVecS3}) = joinpath(artifact_path, "Fsymbols", "ZVecS3.txt")
R_artifact(::Type{ZVecS3}) = joinpath(artifact_path, "Rsymbols", "ZVecS3.txt")

struct ZVecD4 <: BraidedCategory end
rank(::Type{ZVecD4}) = 22
multiplicity(::Type{ZVecD4}) = 1
selfduality(::Type{ZVecD4}) = 22
N_artifact(::Type{ZVecD4}) = joinpath(artifact_path, "Nsymbols", "ZVecD4.txt")
F_artifact(::Type{ZVecD4}) = joinpath(artifact_path, "Fsymbols", "ZVecD4.txt")
R_artifact(::Type{ZVecD4}) = joinpath(artifact_path, "Rsymbols", "ZVecD4.txt")
