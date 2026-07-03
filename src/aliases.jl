# Rep[Zₙ] ? Vec[Zₙ]
const Z2 = PMFC{2, 1, 0, 1, 0, 0}
const Z3 = PMFC{3, 1, 2, 1, 0, 0}
const Z4 = PMFC{4, 1, 2, 1, 0, 0}
const Z5 = PMFC{5, 1, 4, 1, 0, 0}
const Z6 = PMFC{6, 1, 4, 1, 0, 0}

const Z2xZ2 = PMFC{4, 1, 0, 1, 0, 0}

# Rep[Dₙ]
const RepD3 = PMFC{3, 1, 0, 2, 0, 0}
const RepD4 = PMFC{5, 1, 0, 1, 3, 0}
const RepD5 = PMFC{4, 1, 0, 3, 0, 0}
const RepD6 = PMFC{6, 1, 0, 2, 0, 0}
const RepD7 = PMFC{5, 1, 0, 4, 0, 0}

# Rep[Q₈]
# const RepQ8 = PMFC{5, 1, 0, 1, ?, ?}

# Vec[Dₙ]
const VecD3 = UFC{6, 1, 2, 1, 0}

# Rep[Sₙ]
const RepS3 = RepD3
const RepS4 = PMFC{5, 1, 0, 6, 1, 0}

# Vec[Sₙ]
const VecS3 = VecD3

# Haagerup
@objectnames H1 = UFC{4, 2, 0, 1, 0} I μ η ν
@objectnames H2 = UFC{6, 1, 2, 8, 2} I α α² ρ αρ α²ρ
@objectnames H3 = UFC{6, 1, 2, 8, 3} I α α² ρ αρ α²ρ

# Centers
Base.getindex(::CenterTable, ::Type{VecS3}) = ZVecS3
@objectnames ZVecS3 = ZVecS3 A B C F G H D E

# Varia

# --- SU2 ---
@objectnames SU2_1 = PMFC{2, 1, 0, 1, 1, 0} _0 _1
@objectnames SU2_2 = PMFC{3, 1, 0, 1, 0, 3} _0 _2 _1
@objectnames SU2_3 = PMFC{4, 1, 0, 2, 1, 3} _0 _3 _1 _2
@objectnames SU2_4 = PMFC{5, 1, 0, 3, 0, 0} _0 _4 _3 _1 _2
@objectnames SU2_5 = PMFC{6, 1, 0, 6, 0, 1} _0 _5 _1 _4 _2 _3

# --- PSU2 ---
@objectnames PSU2_3 = PMFC{2, 1, 0, 2, 0, 0} _0 _2
@objectnames PSU2_4 = PMFC{3, 1, 0, 2, 0, 1} _0 _4 _2 # Non-modular. {0, 4} form a Rep[Z₂] braided subcategory. Isomorphic to Rep[D₃] as UFC, but has different braiding.
@objectnames PSU2_5 = PMFC{3, 1, 0, 3, 0, 0} _0 _4 _2
@objectnames PSU2_6 = PMFC{4, 1, 0, 4, 0, 0} _0 _6 _4 _2 # Non-modular. Hard to distinguish 2 and 4. They seems to be equivalent. {0, 6} form a sVec braided subcategory.
@objectnames PSU2_7 = PMFC{4, 1, 0, 6, 0, 0} _0 _6 _2 _4
@objectnames PSU2_8 = PMFC{5, 1, 0, 7, 0, 0} _0 _8 _2 _6 _4 # Non-modular. Hard to distinguish 2 and 6. They seems to be equivalent. {0, 8} form a Rep[Z₂] braided subcategory.
@objectnames PSU2_9 = PMFC{5, 1, 0, 10, 0, 1} _0 _8 _2 _6 _4
@objectnames PSU2_10 = PMFC{6, 1, 0, 16, 0, 0} _0 _10 _8 _2 _6 _4 # Non-modular
@objectnames PSU2_11 = PMFC{6, 1, 0, 18, 0, 1} _0 _10 _2 _8 _4 _6

# --- Kitaev 16-fold way ---
@objectnames Kitaev16_0 = PMFC{4, 1, 0, 1, 0, 2} I e m ψ
@objectnames Kitaev16_1 = PMFC{3, 1, 0, 1, 1, 3} I ψ σ
@objectnames Kitaev16_2 = PMFC{4, 1, 2, 1, 2, 0} _0 _2 _1 _3
@objectnames Kitaev16_3 = PMFC{3, 1, 0, 1, 0, 3} I ψ σ
@objectnames Kitaev16_4 = PMFC{4, 1, 0, 1, 1, 1} II ϵI ϵϵ Iϵ
@objectnames Kitaev16_5 = PMFC{3, 1, 0, 1, 0, 0} I ψ σ
@objectnames Kitaev16_6 = PMFC{4, 1, 2, 1, 2, 1} _0 _2 _1 _3
@objectnames Kitaev16_7 = PMFC{3, 1, 0, 1, 1, 0} I ψ σ
@objectnames Kitaev16_8 = PMFC{4, 1, 0, 1, 0, :?} I e m ψ
@objectnames Kitaev16_9 = PMFC{3, 1, 0, 1, 1, 2} I ψ σ
@objectnames Kitaev16_10 = PMFC{4, 1, 2, 1, 2, 2} _0 _2 _1 _3
@objectnames Kitaev16_11 = PMFC{3, 1, 0, 1, 0, 2} I ψ σ
@objectnames Kitaev16_12 = PMFC{4, 1, 0, 1, 1, :?} II ϵI ϵϵ Iϵ
@objectnames Kitaev16_13 = PMFC{3, 1, 0, 1, 0, 1} I ψ σ
@objectnames Kitaev16_14 = PMFC{4, 1, 2, 1, 2, 3} _0 _2 _1 _3
@objectnames Kitaev16_15 = PMFC{3, 1, 0, 1, 1, 1} I ψ σ

# All rank-2 PMFCs are identified!
@objectnames Fib = PMFC{2, 1, 0, 2, 0, 0} I τ
@objectnames sVec = PMFC{2, 1, 0, 1, 0, 1} I ψ # Non-modular
@objectnames Semion = PMFC{2, 1, 0, 1, 1, 0} I ϵ
@objectnames U1_1 = PMFC{2, 1, 0, 1, 1, 0} 0 1



# All rank-3 PMFCs are identified!

@objectnames Ising = PMFC{3, 1, 0, 1, 1, 3} I ψ σ
@objectnames Ising1 = PMFC{3, 1, 0, 1, 1, 3} I ψ σ # c = 1//2 Ising type UMTC
@objectnames Ising3 = PMFC{3, 1, 0, 1, 0, 3} I ψ σ # c = 3//2 Ising type UMTC
@objectnames Ising5 = PMFC{3, 1, 0, 1, 0, 0} I ψ σ # c = 5//2 Ising type UMTC
@objectnames Ising7 = PMFC{3, 1, 0, 1, 1, 0} I ψ σ # c = 7//2 Ising type UMTC
 

@objectnames Z3MTC = PMFC{3, 1, 2, 1, 0, 1} 0 1 2

@objectnames Z2sVec = PMFC{4, 1, 0, 1, 0, 1} 0I 1I 0ψ 1ψ # Non-modular

# @objectnames ThreeFermion = PMFC{4, 1, 0, 1, 0, 3} I f1 f2 f3 # Not found. Should be here.
@objectnames ZSemion = PMFC{4, 1, 0, 1, 1, 0} II ϵI ϵϵ Iϵ
@objectnames SemionSemion = PMFC{4, 1, 0, 1, 1, 1} II ϵI ϵϵ Iϵ
@objectnames sVecSemion = PMFC{4, 1, 0, 1, 1, 2} II Iϵ ψI ψϵ # Non-modular
# @objectnames Z2Semion = PMFC{4, 1, 0, 1, 1, ?} # Non-modular and not found. Should be here.
@objectnames Z2Fib = PMFC{4, 1, 0, 2, 0, 2} 0I 1I 1τ 0τ # Non-modular.
@objectnames sVecFib = PMFC{4, 1, 0, 2, 0, 3} II ψI Iτ ψτ # Non-modular.
@objectnames SemionFib = PMFC{4, 1, 0, 2, 1, 1} II ϵI ϵτ Iτ # Others can be obtained by taking braided-reverse to each layers respectively.
# How to understand PMFC{4, 1, 0, 3, 0, 1} and PMFC{4, 1, 0, 3, 0, 2}? They are non-modular, isomorphic to Rep[D₅] as UFC, with the Muger center Rep[Z₂]. What is its minimal modular extension?

@objectnames ZFib = PMFC{4, 1, 0, 5, 0, 1} II τI Iτ ττ
# @objectnames FibFib = PMFC{4, 1, 0, 5, 0, 2} II τI Iτ ττ # Not found. Should be here.

@objectnames sRepZ4 = PMFC{4, 1, 2, 1, 0, 2} 0 2 1 3 # Non-modular. {0, 2} form a Rep[Z₂] braided subcategory.
# Some other Z4PMFCs are not identified: do not know how to understand. Some are not found.
@objectnames U1_2 = PMFC{4, 1, 2, 1, 2, 0} 0 2 1 3



# @objectnames JK4 = PMFC{5, 1, 0, 3, 1, 1} 0 4 3 1 2 # Not found. Should be here.

_umtcs_lowrank_centralcharge = [
    Dict(
        1 // 1 => PMFC{2, 1, 0, 1, 1, 0}, # Semion, U1_1, SU2_1
        -1 // 1 => PMFC{2, 1, 0, 1, 1, 1}, # TimeReversed{Semion}
        -14 // 5 => PMFC{2, 1, 0, 2, 0, 0}, # TimeReversed{Fib}
        14 // 5 => PMFC{2, 1, 0, 2, 0, 1}, # Fib, PSU2_3
    ),
    Dict(
        2 // 1 => PMFC{3, 1, 2, 1, 0, 1}, # Z3MTC
        -2 // 1 => PMFC{3, 1, 2, 1, 0, 2}, # TimeReversed{Z3MTC}
        5 // 2 => PMFC{3, 1, 0, 1, 0, 0}, # The following are 8-fold ways of Ising-type UMTCs
        -3 // 2 => PMFC{3, 1, 0, 1, 0, 1}, # TimeReversed{SU2_2}
        -5 // 2 => PMFC{3, 1, 0, 1, 0, 2},
        3 // 2 => PMFC{3, 1, 0, 1, 0, 3}, # SU2_2
        7 // 2 => PMFC{3, 1, 0, 1, 1, 0},
        -1 // 2 => PMFC{3, 1, 0, 1, 1, 1}, # TimeReversed{Ising}
        -7 // 2 => PMFC{3, 1, 0, 1, 1, 2},
        1 // 2 => PMFC{3, 1, 0, 1, 1, 3}, # Ising
        8 // 7 => PMFC{3, 1, 0, 3, 0, 0}, # PSU2_5
        -8 // 7 => PMFC{3, 1, 0, 3, 0, 1}, # TimeReversed{PSU2_5}
    ),
    Dict(
        (0 // 1, 1) => PMFC{4, 1, 0, 1, 0, 2}, # Toric code ≅ Z(Rep[Z₂])
        # 4//1 => PMFC{4, 1, 0, 1, 0, 3}, # ThreeFermion Not found. Should be here.
        (0 // 1, 2) => PMFC{4, 1, 0, 1, 1, 0}, # Z(Semion) ≅ Semion ⊠ TimeReversed{Semion}
        2 // 1 => PMFC{4, 1, 0, 1, 1, 1}, # Semion ⊠ Semion
        # -2//1 => PMFC{4, 1, 0, 1, 1, ?}, # TimeReversed{Semion} ⊠ TimeReversed{Semion} Not found. Should be here.
        1 // 1 => PMFC{4, 1, 2, 1, 2, 0}, # U1_2
        3 // 1 => PMFC{4, 1, 2, 1, 2, 1},
        -3 // 1 => PMFC{4, 1, 2, 1, 2, 2},
        -1 // 1 => PMFC{4, 1, 2, 1, 2, 3}, # TimeReversed{U1_2}
        -9 // 5 => PMFC{4, 1, 0, 2, 1, 0}, # Semion ⊠ TimeReversed{Fib}
        19 // 5 => PMFC{4, 1, 0, 2, 1, 1}, # Semion ⊠ Fib
        -19 // 5 => PMFC{4, 1, 0, 2, 1, 2}, # TimeReversed{Semion} ⊠ TimeReversed{Fib}
        9 // 5 => PMFC{4, 1, 0, 2, 1, 3}, # TimeReversed{Semion} ⊠ Fib
        12 // 5 => PMFC{4, 1, 0, 5, 0, 0}, # TimeReversed{Fib} ⊠ TimeReversed{Fib}
        (0 // 1, 3) => PMFC{4, 1, 0, 5, 0, 1}, # TimeReversed{Fib} ⊠ Fib
        # -12//5 => PMFC{4, 1, 0, 5, 0, 2}, # Fib ⊠ Fib Not found. Should be here.
        10 // 3 => PMFC{4, 1, 0, 6, 0, 0}, # PSU2_7
        -10 // 3 => PMFC{4, 1, 0, 6, 0, 1}, # TimeReversed{PSU2_7}
    ),
    Dict(
        4 // 1 => PMFC{5, 1, 4, 1, 0, 1},
        0 // 1 => PMFC{5, 1, 4, 1, 0, 2},
        (2 // 1, 1) => PMFC{5, 1, 0, 3, 0, 0}, # SU2_4
        # Cannot find TimeReversed{SU2_4}, but it should be here with PMFC{5, 1, 0, 3, 0, 1}
        (2 // 1, 2) => PMFC{5, 1, 0, 3, 1, 0}, # TimeReversed{JK4} http://dx.doi.org/10.1103/PhysRevA.92.012301
        # Cannot find JK4, but it should be here somewhere with PMFC{5, 1, 0, 3, 1, 1}
        -16 // 11 => PMFC{5, 1, 0, 10, 0, 0}, # TimeReversed{PSU2_9}
        16 // 11 => PMFC{5, 1, 0, 10, 0, 1}, # PSU2_9
        # Cannot find c = ± 18//7 UMTCs. They are not SimpleFusion. Should be PMFC{5, 2, ?, ?, ?, ?}
    ),
]
