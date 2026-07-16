const artifact_path = joinpath(artifact"fusiondata", "CategoryData.jl-data-temp", "data")

const fusionring_format = r"FR_(?<R>\d+)_(?<M>\d+)_(?<N>\d+)_(?<I>\d+).txt"
const fusioncategory_format = r"FR_(?<R>\d+)_(?<M>\d+)_(?<N>\d+)_(?<I>\d+)_(?<D1>\d+)_(?<D2>\d+).txt"
const braidedcategory_format = r"FR_(?<R>\d+)_(?<M>\d+)_(?<N>\d+)_(?<I>\d+)_(?<D1>\d+)_(?<D2>\d+).txt" # same as fusion category, but for clarity

function list_fusionrings()
    foldername = joinpath(artifact_path, "Nsymbols")
    rings = Vector{Type{<:FusionRing}}()
    for file in readdir(foldername)
        m = match(fusionring_format, file)
        if !isnothing(m)
            R, M, N, I = parse.(Int, (m[:R], m[:M], m[:N], m[:I]))
            push!(rings, FR{R, M, N, I})
        else
            try
                push!(rings, eval(Meta.parse(splitext(file)[1])))
            catch
                @warn "could not parse $file"
            end
        end
    end
    return rings
end

function list_fusioncategories() # strictly fusion categories, not braided
    foldername = joinpath(artifact_path, "Fsymbols")
    categories = Vector{Type{<:FusionCategory}}()
    for file in readdir(foldername)
        m = match(fusioncategory_format, file)
        if !isnothing(m)
            R, M, N, I, D₁, D₂ = parse.(Int, (m[:R], m[:M], m[:N], m[:I], m[:D1], m[:D2]))
            if iszero(D₂) # _0 means it's unbraided, so it's a UFC
                push!(categories, UFC{R, M, N, I, D₁})
            end
        else
            try
                push!(categories, eval(Meta.parse(splitext(file)[1])))
            catch
                @warn "could not parse $file"
            end
        end
    end
    return categories
end

function list_braidedcategories()
    foldername = joinpath(artifact_path, "Rsymbols")
    categories = Vector{Type{<:BraidedCategory}}()
    for file in readdir(foldername)
        m = match(braidedcategory_format, file)
        if !isnothing(m)
            R, M, N, I, D₁, D₂ = parse.(Int, (m[:R], m[:M], m[:N], m[:I], m[:D1], m[:D2]))
            push!(categories, PMFC{R, M, N, I, D₁, D₂})
        else
            try
                push!(categories, eval(Meta.parse(splitext(file)[1])))
            catch
                @warn "could not parse $file"
            end
        end
    end
    return categories
end

# Nsymbols
# --------

function N_artifact(::Type{F}) where {F <: Union{FR, UFC, PMFC}}
    return joinpath(
        artifact_path, "Nsymbols",
        "FR_$(rank(F))_$(multiplicity(F))_$(selfduality(F))_$(ring_index(F)).txt"
    )
end

const N_format_multfree = r"^(?<a>\d+) (?<b>\d+) (?<c>\d+)$"
const N_format = r"^(?<a>\d+) (?<b>\d+) (?<c>\d+) (?<N>\d+)$" # for old or newer multiplicity-full data

function parse_Nsymbol(line)
    m = match(N_format_multfree, line)
    if !isnothing(m)
        a, b, c = parse.(Int, (m[:a], m[:b], m[:c]))
        return a, b, c, 1 # manually add multiplicity-free if N not given
    end

    m = match(N_format, line)
    isnothing(m) && throw(Meta.ParseError("invalid N pattern: $line"))

    a, b, c, N = parse.(Int, (m[:a], m[:b], m[:c], m[:N]))
    return a, b, c, N
end

function extract_Nsymbol(::Type{F}) where {F <: FusionRing}
    R = rank(F)
    filename = N_artifact(F)
    isfile(filename) || throw(LoadError(filename, 0, "Nsymbol file not found for $F"))
    N_array = SparseArray{Int}(undef, (R, R, R))
    for line in eachline(filename)
        a, b, c, N = parse_Nsymbol(line)
        N_array[a, b, c] = N
    end
    return N_array
end

@generated function TensorKitSectors.Nsymbol(
        a::Object{F}, b::Object{F}, c::Object{F}
    ) where {F <: FusionRing}
    local N_array
    try
        N_array = extract_Nsymbol(F)
    catch e
        if e isa LoadError
            return :(throw(MethodError(TensorKitSectors.Nsymbol, (a, b, c))))
        else
            rethrow(e)
        end
    end
    return :(getindex($(N_array), a.id, b.id, c.id))
end

# Fsymbols
# --------

# unbraided fusion categories are still stored with braid index 0
function F_artifact(::Type{F}) where {F <: UFC}
    return joinpath(
        artifact_path, "Fsymbols",
        "FR_$(rank(F))_$(multiplicity(F))_$(selfduality(F))_$(ring_index(F))_$(category_index(F))_0.txt"
    )
end

# distinct braided categories sharing the same pentagon index can have distinct Fsymbols,
# so both the pentagon and braid index are needed in the filename
function F_artifact(::Type{F}) where {F <: PMFC}
    return joinpath(
        artifact_path, "Fsymbols",
        "FR_$(rank(F))_$(multiplicity(F))_$(selfduality(F))_$(ring_index(F))_$(category_index(F))_$(braid_index(F)).txt"
    )
end

const F_format_multfree = r"^(?<a>\d+) (?<b>\d+) (?<c>\d+) (?<d>\d+) (?<e>\d+) (?<f>\d+) (?<re>-?\d+\.?\d*) (?<im>-?\d+\.?\d*)$"
const F_format = r"^(?<a>\d+) (?<b>\d+) (?<c>\d+) (?<d>\d+) (?<e>\d+) (?<f>\d+) (?<α>\d+) (?<β>\d+) (?<μ>\d+) (?<ν>\d+) (?<re>-?\d+\.?\d*) (?<im>-?\d+\.?\d*)$"

function parse_Fsymbol(line)
    m = match(F_format_multfree, line)
    if !isnothing(m)
        a, b, c, d, e, f = parse.(Int, (m[:a], m[:b], m[:c], m[:d], m[:e], m[:f]))
        labels = (a, b, c, d, e, f, 1, 1, 1, 1)
        val = complex(parse.(Float64, (m[:re], m[:im]))...)
        return labels..., val
    end

    m = match(F_format, line)
    isnothing(m) && throw(Meta.ParseError("invalid F pattern: $line"))

    labels = parse.(Int, (m[:a], m[:b], m[:c], m[:d], m[:e], m[:f], m[:α], m[:β], m[:μ], m[:ν]))
    val = complex(parse.(Float64, (m[:re], m[:im]))...)
    return labels..., val
end

function extract_Fsymbol(::Type{F}) where {F <: FusionCategory}
    R = rank(F)
    M = multiplicity(F)
    filename = F_artifact(F)
    isfile(filename) || throw(LoadError(filename, 0, "Fsymbol file not found for $F"))

    if M == 1
        F_array = SparseArray{ComplexF64}(undef, (R, R, R, R, R, R))
        for line in eachline(filename)
            a, b, c, d, e, f, α, β, μ, ν, val = parse_Fsymbol(line)
            μ == ν == α == β == 1 || throw(DomainError("not multiplicity-free"))
            F_array[a, b, c, d, e, f] = val
        end
        return isreal(F_array) ? convert(SparseArray{Float64}, F_array) : F_array
    else
        F_dict = Dict{Tuple{Int, Int, Int, Int, Int, Int}, SparseArray{ComplexF64, 4}}()
        for line in eachline(filename)
            a, b, c, d, e, f, α, β, μ, ν, val = parse_Fsymbol(line)
            if !Base.haskey(F_dict, (a, b, c, d, e, f))
                F_dict[a, b, c, d, e, f] = generate_Farray(F, a, b, c, d, e, f)
            end
            F_dict[a, b, c, d, e, f][α, β, μ, ν] = val
        end
        return F_dict
    end
end

function generate_Farray(
        ::Type{F}, a::Int, b::Int, c::Int, d::Int, e::Int, f::Int
    ) where {F <: FusionCategory}
    a, b, c, d, e, f = Object{F}(a), Object{F}(b), Object{F}(c), Object{F}(d), Object{F}(e), Object{F}(f)
    N1 = Nsymbol(a, b, e)
    N2 = Nsymbol(e, c, d)
    N3 = Nsymbol(b, c, f)
    N4 = Nsymbol(a, f, d)
    return SparseArray{ComplexF64, 4}(undef, (N1, N2, N3, N4))
end

@generated function TensorKitSectors.Fsymbol(
        a::Object{F}, b::Object{F}, c::Object{F},
        d::Object{F}, e::Object{F}, f::Object{F}
    ) where {F <: FusionCategory}
    local F_array
    try
        F_array = extract_Fsymbol(F)
    catch e
        if e isa LoadError
            return :(throw(MethodError(TensorKitSectors.Fsymbol, (a, b, c, d, e, f))))
        else
            rethrow(e)
        end
    end
    if TensorKitSectors.FusionStyle(Object{F}) isa TensorKitSectors.MultiplicityFreeFusion
        return :(getindex($(F_array), a.id, b.id, c.id, d.id, e.id, f.id))
    else
        return quote
            N1 = Nsymbol(a, b, e)
            N2 = Nsymbol(e, c, d)
            N3 = Nsymbol(b, c, f)
            N4 = Nsymbol(a, f, d)

            (N1 == 0 || N2 == 0 || N3 == 0 || N4 == 0) &&
                return SparseArray{ComplexF64, 4}(undef, (N1, N2, N3, N4))

            return $(F_array)[(a.id, b.id, c.id, d.id, e.id, f.id)]
        end
    end
end

# remove the view calls
function TensorKitSectors.Fsymbol_from_fusiontensor(
        a::Object{I}, b::Object{I}, c::Object{I},
        d::Object{I}, e::Object{I}, f::Object{I}
    ) where {I <: FusionCategory}
    T = fusionscalartype(Object{I})
    Nabe, Necd, Nbcd, Nafd = Nsymbol(a, b, e), Nsymbol(e, c, d), Nsymbol(b, c, f), Nsymbol(a, f, d)
    if iszero(Nabe * Necd * Nbcd * Nafd)
        return TensorKitSectors.FusionStyle(Object{I}) isa TensorKitSectors.MultiplicityFreeFusion ? zero(T) : zeros(T, Nabe, Necd, Nbcd, Nafd)
    else
        A = fusiontensor(a, b, e)
        B = fusiontensor(e, c, d)[:, :, 1, :]
        C = fusiontensor(b, c, f)
        D = fusiontensor(a, f, d)[:, :, 1, :]

        @tensor F[-1, -2, -3, -4] := conj(D[1, 5, -4]) * conj(C[2, 4, 5, -3]) * A[1, 2, 3, -1] * B[3, 4, -2]
        return TensorKitSectors.FusionStyle(Object{I}) isa TensorKitSectors.MultiplicityFreeFusion ? only(F) : F
    end
end
function TensorKitSectors.Asymbol_from_fusiontensor(a::Object{F}, b::Object{F}, c::Object{F}) where {F <: FusionCategory}
    Nabc = Nsymbol(a, b, c)
    T = fusionscalartype(Object{F})
    if Nabc == 0
        return TensorKitSectors.FusionStyle(Object{F}) isa TensorKitSectors.MultiplicityFreeFusion ? zero(T) : zeros(T, 0, 0)
    else
        C1 = fusiontensor(a, b, c)[:, 1, :, :]
        C2 = fusiontensor(dual(a), c, b)[:, :, 1, :]
        Za = sqrtdim(a) * fusiontensor(a, dual(a), leftunit(a))[:, :, 1, 1]
        @tensor A[-1, -2] := sqrtdim(b) / sqrtdim(c) * conj(Za[1, 2]) * C1[1, 3, -1] * C2[2, 3, -2]
        return TensorKitSectors.FusionStyle(Object{F}) isa TensorKitSectors.MultiplicityFreeFusion ? only(A) : A
    end
end
function TensorKitSectors.Bsymbol_from_fusiontensor(a::Object{F}, b::Object{F}, c::Object{F}) where {F <: FusionCategory}
    Nabc = Nsymbol(a, b, c)
    T = fusionscalartype(Object{F})
    if Nabc == 0
        return TensorKitSectors.FusionStyle(Object{F}) isa TensorKitSectors.MultiplicityFreeFusion ? zero(T) : zeros(T, 0, 0)
    else
        C1 = fusiontensor(a, b, c)[1, :, :, :]
        C2 = fusiontensor(c, dual(b), a)[:, :, 1, :]
        Zb = sqrtdim(b) * fusiontensor(b, dual(b), leftunit(b))[:, :, 1, 1]
        @tensor B[-1, -2] := sqrtdim(a) / sqrtdim(c) * conj(Zb[1, 2]) * C1[1, 3, -1] * C2[3, 2, -2]
        return TensorKitSectors.FusionStyle(Object{F}) isa TensorKitSectors.MultiplicityFreeFusion ? only(B) : B
    end
end


# Rsymbols
# --------

function R_artifact(::Type{F}) where {F <: PMFC}
    return joinpath(
        artifact_path, "Rsymbols",
        "FR_$(rank(F))_$(multiplicity(F))_$(selfduality(F))_$(ring_index(F))_$(category_index(F))_$(braid_index(F)).txt"
    )
end

const R_format_multfree = r"^(?<a>\d+) (?<b>\d+) (?<c>\d+) (?<re>-?\d+\.?\d*) (?<im>-?\d+\.?\d*)$"
const R_format = r"^(?<a>\d+) (?<b>\d+) (?<c>\d+) (?<μ>\d+) (?<ν>\d+) (?<re>-?\d+\.?\d*) (?<im>-?\d+\.?\d*)$" # for old or newer multiplicity-full data

function parse_Rsymbol(line)
    m = match(R_format_multfree, line)
    if !isnothing(m)
        a, b, c = parse.(Int, (m[:a], m[:b], m[:c]))
        labels = (a, b, c, 1, 1) # manually add multiplicity labels 1 if not given
        val = complex(parse.(Float64, (m[:re], m[:im]))...)
        return labels..., val
    end

    m = match(R_format, line)
    isnothing(m) && throw(Meta.ParseError("invalid R pattern: $line"))

    labels = parse.(Int, (m[:a], m[:b], m[:c], m[:μ], m[:ν]))
    val = complex(parse.(Float64, (m[:re], m[:im]))...)
    return labels..., val
end

function extract_Rsymbol(::Type{F}) where {F <: BraidedCategory}
    R = rank(F)
    filename = R_artifact(F)
    isfile(filename) || throw(LoadError(filename, 0, "Rsymbol file not found for $F"))

    if multiplicity(F) == 1
        R_array = SparseArray{ComplexF64}(undef, (R, R, R))
        for line in eachline(filename)
            a, b, c, μ, ν, val = parse_Rsymbol(line)
            μ == ν == 1 || throw(DomainError("R should not be a matrix"))
            R_array[a, b, c] = val
        end
        return isreal(R_array) ? convert(SparseArray{Float64}, R_array) : R_array
    else
        R_dict = Dict{Tuple{Int, Int, Int}, SparseArray{ComplexF64, 2}}()
        for line in eachline(filename)
            a, b, c, μ, ν, val = parse_Rsymbol(line)
            if !Base.haskey(R_dict, (a, b, c))
                R_dict[a, b, c] = generate_Rarray(F, a, b, c)
            end
            R_dict[a, b, c][μ, ν] = val
        end
        return R_dict
    end
end

function generate_Rarray(::Type{F}, a::Int, b::Int, c::Int) where {F <: BraidedCategory}
    a, b, c = Object{F}(a), Object{F}(b), Object{F}(c)
    N1 = Nsymbol(a, b, c)
    N2 = Nsymbol(b, a, c)
    return SparseArray{ComplexF64, 2}(undef, (N1, N2))
end

@generated function TensorKitSectors.Rsymbol(
        a::Object{F}, b::Object{F}, c::Object{F}
    ) where {F <: BraidedCategory}
    local R_array
    try
        R_array = extract_Rsymbol(F)
    catch e
        if e isa LoadError
            return :(throw(MethodError(TensorKitSectors.Rsymbol, (a, b, c))))
        else
            rethrow(e)
        end
    end

    if TensorKitSectors.FusionStyle(Object{F}) isa TensorKitSectors.MultiplicityFreeFusion
        return :(getindex($(R_array), a.id, b.id, c.id))
    else
        return quote
            N1 = Nsymbol(a, b, c)
            N2 = Nsymbol(b, a, c)

            (N1 == 0 || N2 == 0) &&
                return SparseArray{ComplexF64, 2}(undef, (N1, N2))

            return $(R_array)[(a.id, b.id, c.id)]
        end
    end
end

# remove view calls
function TensorKitSectors.Rsymbol_from_fusiontensor(a::Object{F}, b::Object{F}, c::Object{F}) where {F <: BraidedCategory}
    Nabc = Nsymbol(a, b, c)
    T = braidingscalartype(Object{F})
    if Nabc == 0
        return TensorKitSectors.FusionStyle(Object{F}) isa TensorKitSectors.MultiplicityFreeFusion ? zero(T) : zeros(T, 0, 0)
    else
        A = fusiontensor(a, b, c)[:, :, 1, :]
        B = fusiontensor(b, a, c)[:, :, 1, :]
        @tensor R[-1 -2] := conj(B[1 2 -2]) * A[2 1 -1]
        return TensorKitSectors.FusionStyle(Object{F}) isa TensorKitSectors.MultiplicityFreeFusion ? only(R) : R
    end
end

# fusiontensors
# -------------

const fusiontensor_format = r"^(?<a>\d+) (?<b>\d+) (?<c>\d+) (?<m1>\d+) (?<m2>\d+) (?<m3>\d+) (?<μ>\d+) (?<re>-?\d+(\.\d+)?) (?<im>-?\d+(\.\d+)?)$"

function fusiontensor_artifact(::Type{F}) where {F <: PMFC}
    return joinpath(
        artifact_path, "fusiontensors",
        "FR_$(rank(F))_$(multiplicity(F))_$(selfduality(F))_$(ring_index(F))_$(category_index(F))_$(braid_index(F)).txt"
    )
end

function parse_fusiontensor(line)
    m = match(fusiontensor_format, line)
    local labels, val
    try
        labels = parse.(Int, (m[:a], m[:b], m[:c], m[:m1], m[:m2], m[:m3], m[:μ]))
        val = complex(parse.(Float64, (m[:re], m[:im]))...)
    catch
        throw(Meta.ParseError("invalid fusiontensor pattern: $line"))
    end
    return labels..., val
end

function extract_fusiontensor(::Type{F}) where {F <: BraidedCategory}
    filename = fusiontensor_artifact(F)
    isfile(filename) || throw(LoadError(filename, 0, "fusiontensor file not found for $F"))

    fusiontensor_dict = Dict{Tuple{Int, Int, Int}, SparseArray{ComplexF64, 4}}()
    for line in eachline(filename)
        a, b, c, m1, m2, m3, μ, val = parse_fusiontensor(line)

        μ <= multiplicity(F) ||
            throw(DomainError("multiplicity of fusiontensor should be less than or equal to that of the category"))

        if !Base.haskey(fusiontensor_dict, (a, b, c))
            fusiontensor_dict[a, b, c] = generate_fusiontensor_array(F, a, b, c)
        end
        fusiontensor_dict[a, b, c][m1, m2, m3, μ] = val
    end
    return fusiontensor_dict
end

function generate_fusiontensor_array(
        ::Type{F}, a::Int, b::Int, c::Int
    ) where {F <: BraidedCategory}
    a, b, c = Object{F}(a), Object{F}(b), Object{F}(c)
    da = dim(a)
    db = dim(b)
    dc = dim(c)
    N = Nsymbol(a, b, c)
    return SparseArray{ComplexF64, 4}(undef, (da, db, dc, N))
end

@generated function TensorKitSectors.fusiontensor(
        a::Object{F}, b::Object{F}, c::Object{F}
    ) where {F <: BraidedCategory}
    local Fdict
    try
        Fdict = extract_fusiontensor(F)
    catch e
        if e isa LoadError
            return :(throw(MethodError(TensorKitSectors.fusiontensor, (a, b, c))))
        else
            rethrow(e)
        end
    end

    return quote
        da = dim(a)
        db = dim(b)
        dc = dim(c)
        N = Nsymbol(a, b, c)
        N == 0 && return SparseArray{ComplexF64, 4}(undef, (da, db, dc, N))
        return $(Fdict)[(a.id, b.id, c.id)]
    end
end
