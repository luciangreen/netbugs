% netbugs: list the inputs where a net disagrees with the code it is meant to implement, which
% shows where the model is wrong; give its accuracy; and try the smallest repair (changing one
% neuron's bias) that removes the most disagreements.
% A spec is a named Prolog function on bit lists.
%?- bugs([[n([1,1],0)]], and, B).                 % B = [[0,1]-(want(0)-got(1)), [1,0]-(want(0)-got(1))]
%?- accuracy([[n([1,1],0)]], and, A).             % A = 1/2
%?- repair([[n([1,1],0)]], and, R).               % R = repaired([[n([1,1],-1)]], 0 bugs)
:- module(netbugs, [neuron/3, forward/3, bits/2, truth/3, spec/3, bugs/3, accuracy/3, repair/3]).
:- use_module(library(lists)).
:- use_module(library(apply)).

neuron(n(Ws, B), Xs, Y) :- foldl([W, X, A0, A]>>(A is A0 + W * X), Ws, Xs, B, S), ( S > 0 -> Y = 1 ; Y = 0 ).
forward([], Xs, Xs).
forward([L|Ls], Xs, Out) :- maplist([N, Y]>>neuron(N, Xs, Y), L, Ys), forward(Ls, Ys, Out).
bits(K, Bs) :- length(Bs, K), maplist([X]>>member(X, [0, 1]), Bs).
truth(Net, K, T) :- findall(O, ( bits(K, I), forward(Net, I, O) ), T).

spec(and, [A, B], [Y]) :- Y is A * B.
spec(or, [A, B], [Y]) :- Y is max(A, B).
spec(xor, [A, B], [Y]) :- Y is A xor B.
spec(majority3, [A, B, C], [Y]) :- ( A + B + C >= 2 -> Y = 1 ; Y = 0 ).
spec(first, [A|_], [A]).
arity(majority3, 3) :- !.
arity(_, 2).

bugs(Net, S, Bs) :- arity(S, K), findall(I-(want(W)-got(G)), ( bits(K, I), spec(S, I, W), forward(Net, I, G), G \== W ), Bs).
accuracy(Net, S, N/D) :- arity(S, K), bugs(Net, S, Bs), length(Bs, Nb), D0 is 1 << K, R is D0 - Nb, G is gcd(R, D0), ( G =:= 0 -> N = 0, D = 1 ; N is R // G, D is D0 // G ).

% repair(+Net, +Spec, -Result): try every bias -4..4 for every neuron; keep the change with fewest bugs (none better: unchanged).
repair(Net, S, repaired(Best, Nb)) :- bugs(Net, S, B0), length(B0, N0),
    findall(K-Net2, ( variant(Net, Net2), bugs(Net2, S, Bs), length(Bs, K) ), Cands), keysort(Cands, [K1-Net1|_]),
    ( K1 < N0 -> Best = Net1, Nb = K1 ; Best = Net, Nb = N0 ).
variant(Net, Net2) :- nth0(L, Net, Layer), nth0(J, Layer, n(Ws, _)), between(-4, 4, B), set(J, Layer, n(Ws, B), Layer2), set(L, Net, Layer2, Net2).
set(I, L, V, L2) :- length(Pre, I), append(Pre, [_|Post], L), append(Pre, [V|Post], L2).
