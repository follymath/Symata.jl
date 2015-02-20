include("mxpr_util.jl")
include("mxpr_type.jl")
include("sjiterator.jl")
include("sortpattern.jl")
include("predicates.jl")
include("arithmetic.jl")
include("julia_level_math.jl")
include("mxpr_top.jl")
include("julia_level.jl")
include("namedparts.jl")
include("parse.jl")
include("evaluation.jl")
include("expression_utils.jl")
include("alteval.jl")
include("doc.jl")
include("misc_doc.jl")
include("apprules.jl")
include("measurements.jl")
include("flowcontrol.jl")
include("output.jl")
include("mpatrule.jl")
include("pattern.jl")
include("parts.jl")
include("lists.jl")
include("expressions.jl")
include("flatten.jl")
include("sortorderless.jl")
include("module.jl")
include("trig.jl")
include("protected_symbols.jl")
include("math_functions.jl")
include("strings.jl")
# This last file loads slowly because it has to jit a lot of code
#include("code_in_SJulia.jl")
nothing
