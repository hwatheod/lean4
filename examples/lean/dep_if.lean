import macros
import tactic

-- "Dependent" if-then-else (dep_if c t e)
-- The then-branch t gets a proof for c, and the else-branch e gets a proof for ¬ c
-- We also prove that
--  1)  given H : c,      (dep_if c t e) = t H
--  2)  given H : ¬ c,    (dep_if c t e) = e H

-- We define the "dependent" if-then-else using Hilbert's choice operator ε.
-- Note that ε is only applicable to non-empty types. Thus, we first
-- prove the following auxiliary theorem.
theorem nonempty_resolve {A : TypeU} {c : Bool} (t : c → A) (e : ¬ c → A) : nonempty A
:= or_elim (em c)
      (λ Hc,  nonempty_range (nonempty_intro t) Hc)
      (λ Hnc, nonempty_range (nonempty_intro e) Hnc)

-- The actual definition
definition dep_if {A : TypeU} (c : Bool) (t : c → A) (e : ¬ c → A) : A
:= ε (nonempty_resolve t e) (λ r, (∀ Hc : c, r = t Hc) ∧ (∀ Hnc : ¬ c, r = e Hnc))

theorem then_simp (A : TypeU) (c : Bool) (r : A) (t : c → A) (e : ¬ c → A) (H : c)
                  : (∀ Hc : c, r = t Hc) ∧ (∀ Hnc : ¬ c, r = e Hnc) ↔ r = t H
:= let s1 : (∀ Hc : c, r = t Hc) ↔ r = t H
          := iff_intro
                (assume Hl : (∀ Hc : c, r = t Hc),
                    Hl H)
                (assume Hr : r = t H,
                    λ Hc : c, subst Hr (proof_irrel H Hc)),
       s2 : (∀ Hnc : ¬ c, r = e Hnc) ↔ true
          := eqt_intro (λ Hnc : ¬ c, absurd_elim (r = e Hnc) H Hnc)
   in by simp

-- Given H : c,    (dep_if c t e) = t H
theorem dep_if_true  {A : TypeU} (c : Bool) (t : c → A) (e : ¬ c → A) (H : c)   : dep_if c t e = t H
:= let s1 : (λ r, (∀ Hc : c, r = t Hc) ∧ (∀ Hnc : ¬ c, r = e Hnc)) = (λ r, r = t H)
          := funext (λ r, then_simp A c r t e H)
   in calc dep_if c t e  =  ε (nonempty_resolve t e) (λ r, (∀ Hc : c, r = t Hc) ∧ (∀ Hnc : ¬ c, r = e Hnc)) : refl (dep_if c t e)
                  ...    =  ε (nonempty_resolve t e) (λ r, r = t H) : { s1 }
                  ...    =  t H                                     : eps_singleton (nonempty_resolve t e) (t H)

theorem else_simp (A : TypeU) (c : Bool) (r : A) (t : c → A) (e : ¬ c → A) (H : ¬ c)
                  : (∀ Hc : c, r = t Hc) ∧ (∀ Hnc : ¬ c, r = e Hnc) ↔ r = e H
:= let s1 : (∀ Hc : c, r = t Hc) ↔ true
          := eqt_intro (λ Hc : c, absurd_elim (r = t Hc) Hc H),
       s2 : (∀ Hnc : ¬ c, r = e Hnc) ↔ r = e H
          := iff_intro
                (assume Hl : (∀ Hnc : ¬ c, r = e Hnc),
                   Hl H)
                (assume Hr : r = e H,
                   λ Hnc : ¬ c, subst Hr (proof_irrel H Hnc))
   in by simp

-- Given H : ¬ c,  (dep_if c t e) = e H
theorem dep_if_false {A : TypeU} (c : Bool) (t : c → A) (e : ¬ c → A) (H : ¬ c) : dep_if c t e = e H
:= let s1 : (λ r, (∀ Hc : c, r = t Hc) ∧ (∀ Hnc : ¬ c, r = e Hnc)) = (λ r, r = e H)
          := funext (λ r, else_simp A c r t e H)
   in calc dep_if c t e = ε (nonempty_resolve t e) (λ r, (∀ Hc : c, r = t Hc) ∧ (∀ Hnc : ¬ c, r = e Hnc)) : refl (dep_if c t e)
                    ... = ε (nonempty_resolve t e) (λ r, r = e H) : { s1 }
                    ... = e H                                     : eps_singleton (nonempty_resolve t e) (e H)

import cast

theorem dep_if_congr {A : TypeM} (c1 c2 : Bool)
                     (t1 :   c1 → A) (t2 :   c2 → A)
                     (e1 : ¬ c1 → A) (e2 : ¬ c2 → A)
                     (Hc : c1 = c2)
                     (Ht : t1 = cast (by simp) t2)
                     (He : e1 = cast (by simp) e2)
    : dep_if c1 t1 e1 = dep_if c2 t2 e2
:= by simp
