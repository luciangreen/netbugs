:- module(cases, [title/1, case/3]).
:- use_module('../prolog/netbugs').
:- use_module(engine).
title('netbugs').
n_g(K, n(Ws, B)) :- length(Ws, K), maplist([W]>>rnd_int(-2, 2, W), Ws), rnd_int(-3, 3, B).
case(bugs, [[[N]], S], bugs) :- rnd_pick([and, or, xor, first], S), n_g(2, N).
case(bugs3, [[[N]], majority3], bugs) :- n_g(3, N).
case(accuracy, [[[N]], S], accuracy) :- rnd_pick([and, or, xor, first], S), n_g(2, N).
case(repair, [[[N]], S], repair) :- rnd_pick([and, or, xor, first], S), n_g(2, N).
