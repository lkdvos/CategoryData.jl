const artifact_path = joinpath(artifact"fusiondata", "CategoryData.jl-data-v0.1.3", "data")

function list_fusionrings()
    foldername = joinpath(artifact_path, "Nsymbols")
    rings = Vector{Type{<:FusionRing}}()
    for file in readdir(foldername)
        m = match(r"FR_(?<R>\d+)_(?<M>\d+)_(?<N>\d+)_(?<I>\d+).txt", file)
        if !isnothing(m)
            R, M, N, I = parse.(Int, (m[:R], m[:M], m[:N], m[:I]))
            push!(rings, FR{R,M,N,I})
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

function list_fusioncategories()
    foldername = joinpath(artifact_path, "Fsymbols")
    categories = Vector{Type{<:FusionCategory}}()
    for file in readdir(foldername)
        m = match(r"FR_(?<R>\d+)_(?<M>\d+)_(?<N>\d+)_(?<I>\d+)_(?<D>\d+).txt", file)
        if !isnothing(m)
            R, M, N, I, D = parse.(Int, (m[:R], m[:M], m[:N], m[:I], m[:D]))
            push!(categories, UFC{R,M,N,I,D})
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
        m = match(r"FR_(?<R>\d+)_(?<M>\d+)_(?<N>\d+)_(?<I>\d+)_(?<D1>\d+)_(?<D2>\d+).txt",
                  file)
        if !isnothing(m)
            R, M, N, I, D₁, D₂ = parse.(Int, (m[:R], m[:M], m[:N], m[:I], m[:D1], m[:D2]))
            push!(categories, PMFC{R,M,N,I,D₁,D₂})
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

function N_artifact(::Type{F}) where {F<:Union{FR,UFC,PMFC}}
    return joinpath(artifact_path, "Nsymbols",
                    "FR_$(rank(F))_$(multiplicity(F))_$(selfduality(F))_$(ring_index(F)).txt")
end

const N_format = r"(?<a>\d+) (?<b>\d+) (?<c>\d+) (?<N>\d+)"

function parse_Nsymbol(line)
    m = match(N_format, line)
    local a, b, c, N
    try
        a, b, c = parse.(Int, (m[:a], m[:b], m[:c]))
        N = parse(Int, m[:N])
    catch
        throw(Meta.ParseError("invalid N pattern: $m"))
    end
    return a, b, c, N
end

function extract_Nsymbol(::Type{F}) where {F<:FusionRing}
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

@generated function TensorKitSectors.Nsymbol(a::Object{F}, b::Object{F},
                                             c::Object{F}) where {F<:FusionRing}
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

function F_artifact(::Type{F}) where {F<:Union{UFC,PMFC}}
    return joinpath(artifact_path, "Fsymbols",
                    "FR_$(rank(F))_$(multiplicity(F))_$(selfduality(F))_$(ring_index(F))_$(category_index(F)).txt")
end

const F_format = r"(?<a>\d+) (?<b>\d+) (?<c>\d+) (?<d>\d+) (?<α>\d+) (?<e>\d+) (?<β>\d+) (?<μ>\d+) (?<f>\d+) (?<ν>\d+) (?<re>-?\d+(\.\d+)?) (?<im>-?\d+(\.\d+)?)"

function parse_Fsymbol(line)
    m = match(F_format, line)
    local labels, val
    try
        labels = parse.(Int,
                        (m[:a], m[:b], m[:c], m[:d], m[:α], m[:e], m[:β], m[:μ], m[:f],
                         m[:ν]))
        val = complex(parse.(Float64, (m[:re], m[:im]))...)
    catch
        throw(Meta.ParseError("invalid F pattern: $m"))
    end
    return labels..., val
end

function extract_Fsymbol(::Type{F}) where {F<:FusionCategory}
    R = rank(F)
    M = multiplicity(F)
    filename = F_artifact(F)
    isfile(filename) || throw(LoadError(filename, 0, "Fsymbol file not found for $F"))

    if M == 1
        F_array = SparseArray{ComplexF64}(undef, (R, R, R, R, R, R))
        for line in eachline(filename)
            a, b, c, d, α, e, β, μ, f, ν, val = parse_Fsymbol(line)
            μ == ν == α == β == 1 || throw(DomainError("not multiplicity-free"))
            F_array[a, b, c, d, e, f] = val
        end
        return isreal(F_array) ? convert(SparseArray{Float64}, F_array) : F_array
    else
        F_dict = Dict{Tuple{Int,Int,Int,Int,Int,Int},SparseArray{ComplexF64,4}}()
        for line in eachline(filename)
            a, b, c, d, α, e, β, μ, f, ν, val = parse_Fsymbol(line)
            if !Base.haskey(F_dict, (a, b, c, d, e, f))
                F_dict[a, b, c, d, e, f] = generate_Farray(F, a, b, c, d, e, f)
            end
            F_dict[a, b, c, d, e, f][α, β, μ, ν] = val
        end
        return F_dict
    end
end

function generate_Farray(::Type{F}, a::Int, b::Int, c::Int, d::Int, e::Int,
                         f::Int) where {F<:FusionCategory}
    a, b, c, d, e, f = Object{F}(a), Object{F}(b), Object{F}(c), Object{F}(d),
                       Object{F}(e), Object{F}(f)
    N1 = Nsymbol(a, b, e)
    N2 = Nsymbol(e, c, d)
    N3 = Nsymbol(b, c, f)
    N4 = Nsymbol(a, f, d)
    return SparseArray{ComplexF64,4}(undef, (N1, N2, N3, N4))
end

@generated function TensorKitSectors.Fsymbol(a::Object{F}, b::Object{F}, c::Object{F},
                                             d::Object{F}, e::Object{F},
                                             f::Object{F}) where {F<:FusionCategory}
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
                return SparseArray{ComplexF64,4}(undef, (N1, N2, N3, N4))

            return $(F_array)[(a.id, b.id, c.id, d.id, e.id, f.id)]
        end
    end
end

# Rsymbols
# --------

function R_artifact(::Type{F}) where {F<:PMFC}
    return joinpath(artifact_path, "Rsymbols",
                    "FR_$(rank(F))_$(multiplicity(F))_$(selfduality(F))_$(ring_index(F))_$(category_index(F))_$(braid_index(F)).txt")
end

const R_format = r"(?<a>\d+) (?<b>\d+) (?<c>\d+) (?<μ>\d+) (?<ν>\d+) (?<re>-?\d+(\.\d+)?) (?<im>-?\d+(\.\d+)?)"

function parse_Rsymbol(line)
    m = match(R_format, line)
    local labels, val
    try
        labels = parse.(Int, (m[:a], m[:b], m[:c], m[:μ], m[:ν]))
        val = complex(parse.(Float64, (m[:re], m[:im]))...)
    catch
        throw(Meta.ParseError("invalid R pattern: $m"))
    end
    return labels..., val
end

function extract_Rsymbol(::Type{F}) where {F<:BraidedCategory}
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
        R_dict = Dict{Tuple{Int,Int,Int},SparseArray{ComplexF64,2}}()
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

function generate_Rarray(::Type{F}, a::Int, b::Int, c::Int) where {F<:BraidedCategory}
    a, b, c = Object{F}(a), Object{F}(b), Object{F}(c)
    N1 = Nsymbol(a, b, c)
    N2 = Nsymbol(b, a, c)
    return SparseArray{ComplexF64,2}(undef, (N1, N2))
end

@generated function TensorKitSectors.Rsymbol(a::Object{F}, b::Object{F},
                                             c::Object{F}) where {F<:BraidedCategory}
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
                return SparseArray{ComplexF64,2}(undef, (N1, N2))

            return $(R_array)[(a.id, b.id, c.id)]
        end
    end
end

# fusiontensors
# -------------

const fusionformat = r"(?<a>\d+) (?<b>\d+) (?<c>\d+) (?<m1>\d+) (?<m2>\d+) (?<m3>\d+) (?<μ>\d+) (?<re>-?\d+(\.\d+)?) (?<im>-?\d+(\.\d+)?)"

function fusiontensor_artifact(::Type{F}) where {F<:PMFC}
    return joinpath(artifact_path, "fusiontensors",
                    "FR_$(rank(F))_$(multiplicity(F))_$(selfduality(F))_$(ring_index(F))_$(category_index(F))_$(braid_index(F)).txt")
end

function parse_fusiontensor(line)
    m = match(fusionformat, line)
    local labels, val
    try
        labels = parse.(Int, (m[:a], m[:b], m[:c], m[:m1], m[:m2], m[:m3], m[:μ]))
        val = complex(parse.(Float64, (m[:re], m[:im]))...)
    catch
        throw(Meta.ParseError("invalid fusiontensor pattern: $line"))
    end
    return labels..., val
end

function extract_fusiontensor(::Type{F}) where {F<:BraidedCategory}
    filename = fusiontensor_artifact(F)
    isfile(filename) || throw(LoadError(filename, 0, "fusiontensor file not found for $F"))

    fusiontensor_dict = Dict{Tuple{Int,Int,Int},SparseArray{ComplexF64,4}}()
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

function generate_fusiontensor_array(::Type{F}, a::Int, b::Int,
                                     c::Int) where {F<:BraidedCategory}
    a, b, c = Object{F}(a), Object{F}(b), Object{F}(c)
    da = dim(a)
    db = dim(b)
    dc = dim(c)
    N = Nsymbol(a, b, c)
    return SparseArray{ComplexF64,4}(undef, (da, db, dc, N))
end

@generated function TensorKitSectors.fusiontensor(a::Object{F}, b::Object{F},
                                                  c::Object{F}) where {F<:BraidedCategory}
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
        N == 0 && return SparseArray{ComplexF64,4}(undef, (da, db, dc, N))
        return $(Fdict)[(a.id, b.id, c.id)]
    end
end
