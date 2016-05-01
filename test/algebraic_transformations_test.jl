@testex testUserSyms

#### Cancel

@testex Cancel( (2*x^2-2)/(x^2-2*x+1)) == (-1 + x) ^ (-1) * (2 + 2 * x)

#### Collect

@testex  Args(Collect(a*x^2 + b*x^2 + a*x - b*x + c, x)) == [c,(a + -b) * x,(a + b) * (x ^ 2)]
@testex  Args(Collect(x^2 + y*x^2 + x*y + y + a*y, [x, y])) == [x * y,(1 + a) * y,(x ^ 2) * (1 + y)]
@testex  Collect(a*Sin(2*x) + b*Sin(2*x), Sin(2*x)) == (a + b) * Sin(2 * x)
@testex  Collect(a*x*Log(x) + b*(x*Log(x)), x*Log(x)) == (a + b) * x * Log(x)

@testex Collect(a*x + b*y + c*x, x) == (a + c) * x + b * y

#### Factor, Expand

@testex  Factor(Expand( (a+b)^2 )) == (a+b)^2
@testex  Expand( (a + f(x)) ^2 ) == a ^ 2 + 2 * a * f(x) + f(x) ^ 2
@ex      p = Expand((x-1)*(x-2)*(x-3)*(x^2 + x + 1))
@testex  p == -6 + 5 * x + -1 * (x ^ 2) + 6 * (x ^ 3) + -5 * (x ^ 4) + x ^ 5
@testex  Factor(p) == (-3 + x) * (-2 + x) * (-1 + x) * (1 + x + x ^ 2)

@ex ClearAll(a,b,c,p,x,y,f)

@testex testUserSyms
