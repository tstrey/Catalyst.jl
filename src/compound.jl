const MT = ModelingToolkit
struct CompoundSpecies end
struct CompoundComponents end
struct CompoundCoefficients end

Symbolics.option_to_metadata_type(::Val{:iscompound}) = CompoundSpecies
Symbolics.option_to_metadata_type(::Val{:components}) = CompoundComponents
Symbolics.option_to_metadata_type(::Val{:coefficients}) = CompoundCoefficients


macro compound(species_expr, arr_expr...)
    if !(species_expr isa Expr && species_expr.head == :call)
        error("Invalid species name in @compound macro")
    end

    species_name = species_expr.args[1]
    species_arg = species_expr.args[2]


    species_expr = Expr(:macrocall, Symbol("@species"), LineNumberNode(0), Expr(:call, species_name, species_arg))

    setmetadata_expr = :($(species_name) = MT.setmetadata($(species_name), Catalyst.CompoundSpecies, true))
    escaped_species_expr = esc(species_expr)

    coefficients = Int[]
    components = Num[]

    for expr in arr_expr
        coeff, comp = match(r"(\d+)(\D+)", string(expr)).captures
        push!(coefficients, parse(Int, coeff))

        # Directly push the species into the components vector
        push!(components, eval(Symbol(comp)))
    end

    setcomponents_expr = :($(species_name) = MT.setmetadata($(species_name), Catalyst.CompoundComponents, $components))
    setcoefficients_expr = :($(species_name) = MT.setmetadata($(species_name), Catalyst.CompoundCoefficients, $coefficients))
    
    escaped_setmetadata_expr = esc(setmetadata_expr)
    escaped_setcomponents_expr = esc(setcomponents_expr)
    escaped_setcoefficients_expr = esc(setcoefficients_expr)

    return Expr(:block, escaped_species_expr, escaped_setmetadata_expr, escaped_setcomponents_expr, escaped_setcoefficients_expr)
end


# Check if a species is a compound
iscompound(s::Num) = iscompound(MT.value(s))
function iscompound(s)
    MT.getmetadata(s, CompoundSpecies, false)
end

# Get the components of a species
components(s::Num) = components(MT.value(s))
function components(s)
    MT.getmetadata(s, CompoundComponents)
end

# Get the coefficients of a species
coefficients(s::Num) = coefficients(MT.value(s))
function coefficients(s)
    MT.getmetadata(s, CompoundCoefficients)
end


# # @variables t
# # @parameters k
# # @species C(t) H(t) O(t)
# # @compound C6H12O2(t) 6C 12H 2O #C6H12O2(t)

# # iscompound(C6H12O2) #true
# # typeof(C6H12O2) #Num
# # components(C6H12O2) #3-element Vector{Num}
# # coefficients(C6H12O2) #3-element Vector{Int64}

# struct CompoundSpecies end
# Symbolics.option_to_metadata_type(::Val{:iscompound}) = CompoundSpecies

# struct CompoundComponents end
# Symbolics.option_to_metadata_type(::Val{:components}) = CompoundComponents


# macro compound(species_expr, arr_expr...)
#     # Ensure the species name is a valid expression
#     if !(species_expr isa Expr && species_expr.head == :call)
#         error("Invalid species name in @compound macro")
#     end

#     # Parse the species name to extract the species name and argument
#     species_name = species_expr.args[1]
#     species_arg = species_expr.args[2]

#     # Construct the expressions that define the species
#     species_expr = Expr(:macrocall, Symbol("@species"), LineNumberNode(0), Expr(:call, species_name, species_arg))

#     # Construct the expression to set the iscompound metadata
#     setmetadata_expr = :($(species_name) = ModelingToolkit.setmetadata($(species_name), Catalyst.CompoundSpecies, true))

#     # Ensure the expressions are evaluated in the correct scope by escaping them
#     escaped_species_expr = esc(species_expr)
#     escaped_setmetadata_expr = esc(setmetadata_expr)

#     # Construct the array from the remaining arguments
#     arr = Expr(:vect,(arr_expr)...)

#     # Construct the expression to set the components metadata
#     setcomponents_expr = :($(species_name) = ModelingToolkit.setmetadata($(species_name), Catalyst.CompoundComponents, $arr))

#     # Ensure the expression is evaluated in the correct scope by escaping it
#     escaped_setcomponents_expr = esc(setcomponents_expr)

#     # Return a block that contains the escaped expressions
#     return Expr(:block, escaped_species_expr, escaped_setmetadata_expr, escaped_setcomponents_expr)
# end


# iscompound(s::Num) = iscompound(ModelingToolkit.value(s))
# function iscompound(s)
#     getmetadata(s, CompoundSpecies, false)
# end

# function components(s)
#     getmetadata(s, CompoundComponents)
# end
