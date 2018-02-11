__precompile__()

module DiffEqBiological

using Reexport
using DiffEqBase
using DiffEqJump
using SymEngine
using MacroTools
using DataStructures
@reexport using DiffEqJump

using Compat
abstract type AbstractReactionNetwork end

include("ReactionNetwork.jl")
include("maketype.jl")
include("problem.jl")

export AbstractReactionNetwork

export @reaction_network, @reaction_func
export ODEProblem, SDEProblem, JumpProblem

end # module
