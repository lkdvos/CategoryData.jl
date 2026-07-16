# summary of code below:
# 1) extract labels of unitary fusion categories from anyonwiki data, check their properties
# 2) copy over the N/F/R-symbols from anyonwiki data to the `data` folder of this package
# 3) preprocess the N/F/R-symbols: replace tabs with spaces + truncate precision
# optional if necessary: permute columns of F-symbols to match the expected order
# optional: add multiplicity columns to N/F/R-symbols if they are missing (for multiplicity-free categories)

using DelimitedFiles

anyonwikipath = "C:\\Boris\\Unief\\PhD\\Data\\NumericCategories2\\FusionCategories\\"
const categorydatapath = joinpath(@__DIR__, "data")
const unitarydatapath = joinpath(@__DIR__, "unitarylabels.txt")

# provide the .txt file containing the unitary categories of anyonwiki
# data is a vector of vectors, the nested vector contain 7 elements:
# [rank, multiplicity, non-selfduality, ring index, pentagon, hexagon, pivotal]
function extract_unitary_categories(filepath::AbstractString)
    unitarydata = read(filepath, String)
    data = eval(Meta.parse(replace(unitarydata, "{" => "[", "}" => "]")))
    return data
end

# check that there's only 1 pivotal index for fixed pentagon and hexagon indices
function check_unitary_data(data)
    for (i, fusion_cat) in enumerate(data)
        @assert length(fusion_cat) == 7
        @assert fusion_cat[7] == 1 fusion_cat
        rank, mult, nonselfdual, ring, p, h, v = fusion_cat

        for fusion_cat2 in data
            rank2, mult2, nonselfdual2, ring2, p2, h2, v2 = fusion_cat2
            if rank == rank2 && mult == mult2 && nonselfdual == nonselfdual2 && ring == ring2 && p == p2 && h == h2
                @assert v == v2 fusion_cat i
            end
        end
    end
    return
end

# anyonwiki downloaded data takes the form `NumericCategories/FusionCategories`, which is a directory containing subdirectories for each category of the form `FR_rank_mult_nonselfdual_ring`. `anyonwikipath` is the path to this directory.
# this function copies over the N-symbols to the `data/Nsymbols` directory, but does not yet manipulate them to match the current format.
function copy_Nsymbols(data, anyonwikipath::AbstractString)
    for fusion_cat in data
        rank, mult, nonselfdual, ring, _, _, _ = fusion_cat
        file_loc = "FR_$(rank)_$(mult)_$(nonselfdual)_$(ring)"
        current_folder = joinpath(anyonwikipath, file_loc)
        Nfile = current_folder * "\\$(file_loc)_structconst.txt" # one Nsymbol file per category
        @assert isfile(Nfile) Nfile
        # need to check whether every Nfile only has 3 columns, or if some have 4 columns (for multiplicity > 1)
        Ndata = readdlm(Nfile)
        @assert size(Ndata, 2) == 3 Nfile
        newNfile = joinpath(categorydatapath, "Nsymbols", file_loc * ".txt")
        cp(Nfile, newNfile; force = true)
    end
    return
end

# similarly for F-symbols
# requires checking whether the category is braided or not
function copy_Fsymbols(data, anyonwikipath::AbstractString)
    for fusion_cat in data
        rank, mult, nonselfdual, ring, p, h, v = fusion_cat
        file_loc = "FR_$(rank)_$(mult)_$(nonselfdual)_$(ring)"
        current_folder = joinpath(anyonwikipath, file_loc)
        h_orig = h  # 0 = unbraided, ≥2 = braided for sure, but = 1 means it might be braided with one solution or unbraided; preserve for filename labeling
        iszero(h) && (h = 1) # folder lookup uses 1 even for non-braided
        folder = joinpath(current_folder, "cat_$(p)_$(h)_$(v)")
        Ffile = folder * "\\$(p)_$(h)_$(v)_pentsol.txt"
        Rfile = folder * "\\$(p)_$(h)_$(v)_hexsol.txt"
        @assert isfile(Ffile) Ffile
        if isfile(Rfile)
            newFfile = joinpath(categorydatapath, "Fsymbols", file_loc * "_$(p)_$(h_orig).txt")
        else
            newFfile = joinpath(categorydatapath, "Fsymbols", file_loc * "_$(p)_0.txt") # properly unbraided: save as h = 0
        end
        cp(Ffile, newFfile; force = true)
    end
    return
end

# and also for R-symbols
function copy_Rsymbols(data, anyonwikipath::AbstractString)
    for fusion_cat in data
        rank, mult, nonselfdual, ring, p, h, v = fusion_cat
        file_loc = "FR_$(rank)_$(mult)_$(nonselfdual)_$(ring)"
        current_folder = joinpath(anyonwikipath, file_loc)
        h_orig = h  # 0 = unbraided, ≥2 = braided for sure, but = 1 means it might be braided with one solution or unbraided; preserve for filename labeling
        iszero(h) && (h = 1) # folder lookup uses 1 even for non-braided
        folder = joinpath(current_folder, "cat_$(p)_$(h)_$(v)")
        Rfile = folder * "\\$(p)_$(h)_$(v)_hexsol.txt"
        if isfile(Rfile)
            newRfile = joinpath(categorydatapath, "Rsymbols", file_loc * "_$(p)_$(h_orig).txt")
            cp(Rfile, newRfile; force = true)
        end
    end
    return
end

for (i, fusion_cat) in enumerate(data)
    # @show fusion_cat, i
    rank, mult, nonselfdual, ring, p, h, v = fusion_cat
    file_loc = "FR_$(rank)_$(mult)_$(nonselfdual)_$(ring)"
    current_folder = joinpath(filepath, file_loc)
    Nfile = current_folder * "\\$(file_loc)_structconst.txt" # one Nsymbol file per category
    @assert isfile(Nfile)
    # need to check whether every Nfile only has 3 columns, or if some have 4 columns (for multiplicity > 1)
    Ndata = readdlm(Nfile)
    @assert size(Ndata, 2) == 3 # true: do we want to upload files with 4 columns, or just manually add it in `parse_Nsymbol`?
    newNfile = joinpath(categorydatapath, "Nsymbols", file_loc * ".txt")
    # cp(Nfile, newNfile; force = true)

    # different pents, hexs and pivs
    h_orig = h  # 0 = unbraided, ≥2 = braided for sure, but = 1 means it might be braided with one solution or unbraided; preserve for filename labeling
    iszero(h) && (h = 1) # folder lookup uses 1 even for non-braided
    folder = joinpath(current_folder, "cat_$(p)_$(h)_$(v)")
    Ffile = folder * "\\$(p)_$(h)_$(v)_pentsol.txt"
    Rfile = folder * "\\$(p)_$(h)_$(v)_hexsol.txt"
    # @show Rfile
    # pivfile = folder * "\\$(p)_$(h)_$(v)_pivsol.txt"
    @assert isfile(Ffile) Ffile
    # the pentagon solution differs per (p, h) pair (different gauge per braiding),
    # so the hexagon index must be part of the Fsymbol filename too, otherwise
    # categories sharing the same p but different h overwrite each other's Fsymbol file.
    # h_orig = 0 serves as the "unbraided" sentinel in filenames.
    if isfile(Rfile)
        newFfile = joinpath(categorydatapath, "Fsymbols", file_loc * "_$(p)_$(h_orig).txt")
        newRfile = joinpath(categorydatapath, "Rsymbols", file_loc * "_$(p)_$(h_orig).txt")
    else
        newFfile = joinpath(categorydatapath, "Fsymbols", file_loc * "_$(p)_0.txt") # properly unbraided: save as h = 0
    end
    cp(Ffile, newFfile; force = true)
    # (@isdefined newRfile) && cp(Rfile, newRfile; force = true)
end

const trunc_pattern = Regex("(\\.[0-9]{20})[0-9]+")

# preprocess the F-symbols and R-symbols to truncate the digits after the decimal point to 20 digits
# while also replacing tabs with spaces for these and the N-symbols
function process_Rsymbols!()
    Rsymbolpath = joinpath(categorydatapath, "Rsymbols")
    Rfilenames = readdir(Rsymbolpath, join = true)
    for filename in Rfilenames
        data = read(filename, String)
        tabs_to_spaces = replace(data, '\t' => ' ')
        truncated = replace(tabs_to_spaces, trunc_pattern => s"\1")
        write(filename, truncated)
    end
    return
end

function process_Fsymbols!()
    Fsymbolpath = joinpath(categorydatapath, "Fsymbols")
    Ffilenames = readdir(Fsymbolpath, join = true)
    for filename in Ffilenames
        data = read(filename, String)
        tabs_to_spaces = replace(data, '\t' => ' ')
        truncated = replace(tabs_to_spaces, trunc_pattern => s"\1")
        write(filename, truncated)
    end
    return
end

function process_Nsymbols!()
    Nsymbolpath = joinpath(categorydatapath, "Nsymbols")
    Nfilenames = readdir(Nsymbolpath, join = true)
    for filename in Nfilenames
        data = read(filename, String)
        tabs_to_spaces = replace(data, '\t' => ' ')
        write(filename, tabs_to_spaces)
    end
    return
end

# permuting the data of existing files with 12 columns
# in case the order of the columns is not consistent with the current format, we can permute them to match the expected order
# this was the case for some F-symbols gotten outside of the anyonwiki
# provide the permutation as a vector of indices
# e.g. [1, 2, 3, 4, 6, 9, 5, 7, 8, 10, 11, 12] to move the 5th column to the 7th position and so on
function permute_Fsymbols!(perm::Vector{Int})
    Fsymbolpath = joinpath(categorydatapath, "Fsymbols")
    Ffilenames = readdir(Fsymbolpath, join = true)
    for filename in Ffilenames
        lines = readlines(filename)
        length(split(lines[1])) == length(perm) || continue # 8 or 12 depending on whether multiplicity columns are present
        open(filename, "w") do f
            for line in lines
                isempty(strip(line)) && continue
                cols = split(line)
                println(f, join(cols[perm], " "))
            end
        end
    end
    return
end

# assuming the multiplicity-free data is ordered correctly, we can add multiplicity columns to the N-, F- and R-symbols by inserting 1's in the appropriate positions
function insert_Nsymbol_multiplicities()
    Nsymbolpath = joinpath(categorydatapath, "Nsymbols")
    Nfilenames = readdir(Nsymbolpath, join = true)
    for filename in Nfilenames
        lines = readlines(filename)
        length(split(lines[1])) == 3 || continue
        open(filename, "w") do f
            for line in lines
                isempty(strip(line)) && continue
                cols = split(line)
                println(f, join([cols[1:3]..., 1], " "))
            end
        end
    end
    return
end

function insert_Fsymbol_multiplicities()
    Fsymbolpath = joinpath(categorydatapath, "Fsymbols")
    Ffilenames = readdir(Fsymbolpath, join = true)
    for filename in Ffilenames
        lines = readlines(filename)
        length(split(lines[1])) == 8 || continue
        open(filename, "w") do f
            for line in lines
                isempty(strip(line)) && continue
                cols = split(line)
                println(f, join([cols[1:6]..., 1, 1, 1, 1, cols[7:8]...], " "))
            end
        end
    end
    return
end

function insert_Rsymbol_multiplicities()
    Rsymbolpath = joinpath(categorydatapath, "Rsymbols")
    Rfilenames = readdir(Rsymbolpath, join = true)
    for filename in Rfilenames
        lines = readlines(filename)
        length(split(lines[1])) == 5 || continue
        open(filename, "w") do f
            for line in lines
                isempty(strip(line)) && continue
                cols = split(line)
                println(f, join([cols[1:3]..., 1, 1, cols[4:5]...], " "))
            end
        end
    end
    return
end

#####################
data = extract_unitary_categories(unitarydatapath)
check_unitary_data(data)
anyonwikipath = "" # fill in
copy_Nsymbols(data, anyonwikipath)
process_Nsymbols!()

copy_Fsymbols(data, anyonwikipath)
process_Fsymbols!()

copy_Rsymbols(data, anyonwikipath)
process_Rsymbols!()
