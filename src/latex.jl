# Is import file-scoped ? If not, we need to do something else
import Symata.SymataIO: WORational, WOComplexRational, Istring, outsym, FUNCR, FUNCL, LISTR, LISTL, needsparen

const llparen = "\\left("
const lrparen = "\\right)"

const LFUNCL = "\\left("
const LFUNCR = "\\right)"
const LLISTL = '['
const LLISTR = ']'


Ilatexstring() = "\\mathbb{i}"

#  display("text/latex", L"$$\int_0 \text{cos}(x)^2  b \ y \ r$$")

#######################################################################

# Following copied from LaTeXString. We surely need almost none of this.
# But, there is something magic here that makes IJulia render the strings
# as LaTeX. I don't yet know where it is.

immutable MyLaTeXString <: AbstractString
    s::String
end

# coercing constructor:
function latexstring(s::String)
    # the only point of using MyLaTeXString to represent equations, since
    # IJulia doesn't support MyLaTeX output other than equations, so add $'s
    # around the string if they aren't there (ignoring \$)
    return ismatch(r"[^\\]\$|^\$", s) ?
        MyLaTeXString(s) :  MyLaTeXString(string("\$", s, "\$"))
end
latexstring(s::AbstractString) = latexstring(String(s))
latexstring(args...) = latexstring(string(args...))

macro L_str(s, flags...) latexstring(s) end
macro L_mstr(s, flags...) latexstring(s) end

import Base: write, endof, getindex, sizeof, search, rsearch, isvalid, next, length, bytestring, IOBuffer, pointer
@compat import Base.show

write(io::IO, s::MyLaTeXString) = write(io, s.s)
@compat show(io::IO, ::MIME"application/x-latex", s::MyLaTeXString) = write(io, s)
@compat show(io::IO, ::MIME"text/latex", s::MyLaTeXString) = write(io, s)

function show(io::IO, s::MyLaTeXString)
    print(io, "L")
    Base.print_quoted_literal(io, s.s)
end

bytestring(s::MyLaTeXString) = bytestring(s.s)
endof(s::MyLaTeXString) = endof(s.s)
next(s::MyLaTeXString, i::Int) = next(s.s, i)
length(s::MyLaTeXString) = length(s.s)
getindex(s::MyLaTeXString, i::Int) = getindex(s.s, i)
getindex(s::MyLaTeXString, i::Integer) = getindex(s.s, i)
getindex(s::MyLaTeXString, i::Real) = getindex(s.s, i)
getindex(s::MyLaTeXString, i::UnitRange{Int}) = getindex(s.s, i)
getindex{T<:Integer}(s::MyLaTeXString, i::UnitRange{T}) = getindex(s.s, i)
getindex(s::MyLaTeXString, i::AbstractVector) = getindex(s.s, i)
sizeof(s::MyLaTeXString) = sizeof(s.s)
search(s::MyLaTeXString, c::Char, i::Integer) = search(s.s, c, i)
rsearch(s::MyLaTeXString, c::Char, i::Integer) = rsearch(s.s, c, i)
isvalid(s::MyLaTeXString, i::Integer) = isvalid(s.s, i)
pointer(s::MyLaTeXString) = pointer(s.s)
IOBuffer(s::MyLaTeXString) = IOBuffer(s.s)

# conversion to pass MyLaTeXString to ccall arguments
if VERSION >= v"0.4.0-dev+3710"
    import Base.unsafe_convert
else
    import Base.convert
    const unsafe_convert = Base.convert
end
@compat unsafe_convert(T::Union{Type{Ptr{UInt8}},Type{Ptr{Int8}}}, s::MyLaTeXString) = convert(T, s.s)
if VERSION >= v"0.4.0-dev+4603"
    unsafe_convert(::Type{Cstring}, s::MyLaTeXString) = unsafe_convert(Cstring, s.s)
end

#######################################################################

function latex_display(x)
#    LaTeXStrings.LaTeXString("\$\$ " * latex_string(x) *  " \$\$")
    MyLaTeXString("\$\$ " * latex_string(x) *  " \$\$")
end

latex_string(x) = string(x)

function latex_string(s::Mxpr)
    if getoptype(mhead(s)) == :binary
        return latex_string_binary(s)
    elseif getoptype(mhead(s)) == :infix
        return latex_string_infix(s)
    end
    latex_string_prefix_function(s)
end

latex_string_binary(s) = s
latex_string_infix(s) = s

function latex_string_mathop(ins)
    s = string(ins)
    isempty(s) && return ""
    islower(s[1]) && return s  # if Heasd begins lower case print in math italic, e.g. f(x)
    "\\text{" * s  * "}"       # if upper case print, like mathops. e.g. Table(...)
end

function latex_string_prefix_function(mx::Mxpr)
#    s = is_Mxpr(mx,:List) ? ""  : latex_string(outsym(mhead(mx)))
    s = is_Mxpr(mx,:List) ? ""  : latex_string_mathop(outsym(mhead(mx))) * " \\! "  # ipython inserts a space that we don't want
    args = margs(mx)
    s *= latex_string(mhead(mx) == getsym(:List) ? LISTL : LFUNCL)
    wantparens = mhead(mx) == :List ? false : true
    for i in 1:length(args)-1
        if needsparen(args[i]) && wantparens
            s *= llparen
        end
        s *= latex_string(args[i])
        if needsparen(args[i]) && wantparens
            s *= lrparen
        end
        s *=  ","
    end
    if  ! isempty(args) s *= latex_string(args[end]) end
    s *= latex_string(mx.head == getsym(:List) ? LISTR : LFUNCR)
    s
end


function latex_string(mx::Mxpr{:Plus})
    terms = margs(mx) # why does terms(mx) not work ?
    if length(terms) < 1
        error("show: can't display Plus with no terms.")
    end
    s = latex_string(terms[1])
    for i in 2:length(terms)
        if is_type(terms[i],Mxpr{:Minus})
            s *=  " - " * latex_string((terms[i]).terms[1])
        else
            s *= " + " * latex_string(terms[i])
        end
    end
    s
end


latex_string(mx::Mxpr{:Power}) =  latex_string(base(mx)) * "^{" * latex_string(exponent(mx)) * "}"

function separate_negative_powers(facs)
    other = Array(Any,0)
    negpows = Array(Any,0)
    rationals = Array(Any,0)
    for x in facs
        t = typeof(x)
        if t <: Rational
            push!(rationals,x)
        elseif t <: WORational
            push!(rationals,x.x)
        elseif t == Mxpr{:Power} && typeof(exponent(x)) <: Number && exponent(x) < 0
            push!(negpows,x)
        else
            push!(other,x)
        end
    end
    return (other, negpows, rationals)
end

function get_nums_dens(other, negpows, rationals)
    nums = Array(Any,0)
    dens = Array(Any,0)
    for x in rationals
        if num(x) != 1 push!(nums, num(x)) end
        push!(dens, den(x))
    end
    for x in negpows
        e = -exponent(x)
        if e == 1
            push!(dens, base(x))
        else
            push!(dens, mxpr(:Power, base(x), -exponent(x)))
        end
    end
    append!(nums, other)
    (nums,dens)
end

function latex_string_factors(facs)
    join([latex_string(x) for x in facs], " \\ ")
end

# LaTeX does not put spaces between factors. But, Symata has multicharacter symbols, so we need spaces to distinguish them
function latex_string(mx::Mxpr{:Times})
    (other, negpows, rationals) = separate_negative_powers(factors(mx))
    if ( isempty(negpows) && isempty(rationals) )
        latex_string_factors(factors(mx))
    else
        (nums,dens) = get_nums_dens(other,negpows, rationals)
        "\\frac{" * latex_string_factors(nums) * "}{" * latex_string_factors(dens) * "}"
    end
end

function latex_string(x::WORational)
    r = x.x
    latex_string(r)
end

function latex_string{T<:Real}(z::Rational{T})
    "\\frac{" * latex_string(num(z)) * "}{" * latex_string(den(z)) * "}"
end

function latex_string(x::WOComplexRational)
    z = x.x
    s = ""
    if real(z) != 0
        s *= latex_string(real(z)) * " + "
    end
    if imag(z) == 1
        s *= Ilatexstring()
    else
        s *=   latex_string(imag(z)) *  " \\ " * Ilatexstring()
    end
    s
end