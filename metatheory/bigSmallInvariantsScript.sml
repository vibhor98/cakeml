(*Generated by Lem from bigSmallInvariants.lem.*)
open HolKernel Parse boolLib bossLib;
open lem_pervasivesTheory libTheory astTheory semanticPrimitivesTheory smallStepTheory bigStepTheory;

val _ = numLib.prefer_num();



val _ = new_theory "bigSmallInvariants"

(*open import Pervasives*)
(*open import Lib*)
(*open import Ast*)
(*open import SemanticPrimitives*)
(*open import SmallStep*)
(*open import BigStep*)

(* ------ Auxiliary relations for proving big/small step equivalence ------ *)

(*val evaluate_state : state -> count_store store_v * result v v -> bool*)

val _ = Hol_reln ` (! env s v.
T
==>
evaluate_ctxt env s (Craise () ) v (s, Rerr (Rraise v)))

/\ (! env s v pes.
T
==>
evaluate_ctxt env s (Chandle ()  pes) v (s, Rval v))

/\ (! env e v vs1 vs2 es env' bv s1 s2.
(evaluate_list F env s1 es (s2, Rval vs2) /\
(do_opapp ((REVERSE vs1 ++ [v]) ++ vs2) = SOME (env',e)) /\
evaluate F env' s2 e bv)
==>
evaluate_ctxt env s1 (Capp Opapp vs1 ()  es) v bv)

/\ (! env v vs1 vs2 es s1 s2.
(evaluate_list F env s1 es (s2, Rval vs2) /\
(do_opapp ((REVERSE vs1 ++ [v]) ++ vs2) = NONE))
==>
evaluate_ctxt env s1 (Capp Opapp vs1 ()  es) v (s2, Rerr Rtype_error))

/\ (! env op v vs1 vs2 es res s1 s2 s3 count.
((op <> Opapp) /\
evaluate_list F env s1 es ((count,s2), Rval vs2) /\
(do_app s2 op ((REVERSE vs1 ++ [v]) ++ vs2) = SOME (s3,res)))
==>
evaluate_ctxt env s1 (Capp op vs1 ()  es) v ((count,s3), res))

/\ (! env op v vs1 vs2 es s1 s2 count.
((op <> Opapp) /\
evaluate_list F env s1 es ((count,s2), Rval vs2) /\
(do_app s2 op ((REVERSE vs1 ++ [v]) ++ vs2) = NONE))
==>
evaluate_ctxt env s1 (Capp op vs1 ()  es) v ((count,s2), Rerr Rtype_error))

/\ (! env op es vs v err s s'.
(evaluate_list F env s es (s', Rerr err))
==>
evaluate_ctxt env s (Capp op vs ()  es) v (s', Rerr err))

/\ (! env op e2 v e' bv s.
((do_log op v e2 = SOME e') /\
evaluate F env s e' bv)
==>
evaluate_ctxt env s (Clog op ()  e2) v bv)

/\ (! env op e2 v s.
(do_log op v e2 = NONE)
==>
evaluate_ctxt env s (Clog op ()  e2) v (s, Rerr Rtype_error))

/\ (! env e2 e3 v e' bv s.
((do_if v e2 e3 = SOME e') /\
evaluate F env s e' bv)
==>
evaluate_ctxt env s (Cif ()  e2 e3) v bv)

/\ (! env e2 e3 v s.
(do_if v e2 e3 = NONE)
==>
evaluate_ctxt env s (Cif ()  e2 e3) v (s, Rerr Rtype_error))

/\ (! env pes v bv s err_v.
(evaluate_match F env s v pes err_v bv)
==>
evaluate_ctxt env s (Cmat ()  pes err_v) v bv)

/\ (! menv cenv env n e2 v bv s.
(evaluate F (menv, cenv, opt_bind n v env) s e2 bv)
==>
evaluate_ctxt (menv,cenv,env) s (Clet n ()  e2) v bv)

/\ (! env cn es vs v vs' s1 s2 v'.
(do_con_check (all_env_to_cenv env) cn ((LENGTH vs + LENGTH es) + 1) /\
(build_conv (all_env_to_cenv env) cn ((REVERSE vs ++ [v]) ++ vs') = SOME v') /\
evaluate_list F env s1 es (s2, Rval vs'))
==>
evaluate_ctxt env s1 (Ccon cn vs ()  es) v (s2, Rval v'))

/\ (! env cn es vs v s.
(~ (do_con_check (all_env_to_cenv env) cn ((LENGTH vs + LENGTH es) + 1)))
==>
evaluate_ctxt env s (Ccon cn vs ()  es) v (s, Rerr Rtype_error))

/\ (! env cn es vs v err s s'.
(do_con_check (all_env_to_cenv env) cn ((LENGTH vs + LENGTH es) + 1) /\
evaluate_list F env s es (s', Rerr err))
==>
evaluate_ctxt env s (Ccon cn vs ()  es) v (s', Rerr err))`;

val _ = Hol_reln ` (! res s.
T
==>
evaluate_ctxts s [] res (s, res))

/\ (! c cs env v res bv s1 s2.
(evaluate_ctxt env s1 c v (s2, res) /\
evaluate_ctxts s2 cs res bv)
==>
evaluate_ctxts s1 ((c,env)::cs) (Rval v) bv)

/\ (! c cs env err s bv.
(evaluate_ctxts s cs (Rerr err) bv /\
((! pes. c <> Chandle ()  pes) \/
 (! v. err <> Rraise v)))
==>
evaluate_ctxts s ((c,env)::cs) (Rerr err) bv)

/\ (! cs env s s' res1 res2 pes v.
(evaluate_match F env s v pes v (s', res1) /\
evaluate_ctxts s' cs res1 res2)
==>
evaluate_ctxts s ((Chandle ()  pes,env)::cs) (Rerr (Rraise v)) res2)`;

val _ = Hol_reln ` (! env e c res bv s1 s2.
(evaluate F env ( 0,s1) e (s2, res) /\
evaluate_ctxts s2 c res bv)
==>
evaluate_state (env, s1, Exp e, c) bv)

/\ (! env s v c bv.
(evaluate_ctxts ( 0,s) c (Rval v) bv)
==>
evaluate_state (env, s, Val v, c) bv)`;
val _ = export_theory()

