# Test that timestamp of symbols that an expression depends on are
# tracked and used correctly. This means, in particular that getting
# one part of a large expression that is 'fixed' say the part m[1] of
# m, requires evaluating neither m nor m1, but merely retrieving m[1].

@ex Clear(m,a,b,c,d)
@ex m = Expand((a+b)^2)
@testex Syms(m) == HoldForm([a,b])
@ex m = Expand((a*c + b*d)^2)
@testex Syms(m) == HoldForm([a,b,c,d])
@testex Fixed(m)
@ex a = 1
@ex Length(m)
@testex Fixed(m) == false
@ex Clear(a)
@ex Length(m)
@testex Fixed(m)
@ex m = Range(10) # depends on no symbols, should never be dirty.
@testex DirtyQ(m) == false
@ex Clear(m)

## more testing of dirty symbols
@ex Clear(a)
@ex m = Cos(3*a)
@ex a = Pi
@testex m == -1

@ex ClearAll(a,b,c,d,m)