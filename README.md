# netbugs

list the inputs where a net disagrees with the code it is meant to implement, which shows where the model is wrong; give its accuracy; and try the smallest repair (changing one neuron's bias) that removes the most disagreements. A spec is a named Prolog function on bit lists.

## Use

```prolog
?- use_module(prolog/netbugs).
?- bugs([[n([1,1],0)]], and, B).                 % B = [[0,1]-(want(0)-got(1)), [1,0]-(want(0)-got(1))]
?- accuracy([[n([1,1],0)]], and, A).             % A = 1/2
?- repair([[n([1,1],0)]], and, R).               % R = repaired([[n([1,1],-1)]], 0 bugs)
```

## Proofs

`proofs/theorems.pl` proves 5 theorems by exhaustion: each one is checked for every case in a finite domain that covers every branch of the definitions. every single-neuron net with weights -1..1 and bias -2..1, against every two-input spec.

1. The bugs are exactly the inputs where the net and the spec disagree.
2. Accuracy is the fraction of inputs without a bug.
3. Repair never makes things worse, and its bug count is real.
4. A net that implements its spec has no bugs and stays as it is.
5. xor can't be fixed by one neuron's bias: some bug always remains.

```sh
swipl -g main -t halt proofs/theorems.pl
```

## 200 inputs and outputs

`io/ios.txt` lists 200 inputs and outputs from real runs, and `io/ios.pl` has the same as Prolog facts. The inputs come from a fixed seed (`io/cases.pl`). `swipl -g check -t halt io/run.pl` runs them again. It fails if any output changes, or if a predicate doesn't confirm its own recorded output, which checks steadfastness. GitHub Actions runs the proofs and the examples on every push, and records the examples on the first push.

Licence: BSD-3-Clause.
