% Theorems, proved by exhaustion. Run: swipl -g main -t halt proofs/theorems.pl
:- module(theorems, [main/0]).
:- use_module(prove).
:- discontiguous theorem/1.
:- use_module(library(lists)).
:- use_module(library(apply)).
main :- prove_all(theorems).
:- use_module('../prolog/netbugs').

% Domain: every single-neuron net with weights -1..1 and bias -2..1, against every two-input spec.
net([[n([A, B], C)]]) :- between(-1, 1, A), between(-1, 1, B), between(-2, 1, C).
sp(S) :- member(S, [and, or, xor, first]).

% 1. The bugs are exactly the inputs where the net and the spec disagree.
theorem(bugs_are_disagreements) :- forall(( net(N), sp(S) ), ( bugs(N, S, Bs), forall(bits(2, I), ( spec(S, I, W), forward(N, I, G), iff(memberchk(I-_, Bs), G \== W) )) )).

% 2. Accuracy is the fraction of inputs without a bug.
theorem(accuracy_counts) :- forall(( net(N), sp(S) ), ( bugs(N, S, Bs), length(Bs, K), accuracy(N, S, A/B), A * 4 =:= (4 - K) * B )).

% 3. Repair never makes things worse, and its bug count is real.
theorem(repair_never_worse) :- forall(( net(N), sp(S) ), ( bugs(N, S, B0), length(B0, K0), repair(N, S, repaired(R, K)), K =< K0, bugs(R, S, B1), length(B1, K) )).

% 4. A net that implements its spec has no bugs and stays as it is.
theorem(correct_nets_untouched) :- forall(( net(N), sp(S), bugs(N, S, []) ), repair(N, S, repaired(N, 0))).

% 5. xor can't be fixed by one neuron's bias: some bug always remains.
theorem(xor_not_repairable) :- forall(net(N), ( repair(N, xor, repaired(_, K)), K >= 1 )).
