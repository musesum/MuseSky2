ico {
    A <> (BEF, _012)
    B <> (ACG, _023)
    C <> (BHD, _034)
    D <> (CIE, _045)
    E <> (DJA, _051)
    F <> (AOK, _162)
    G <> (BKL, _273)
    H <> (CLM, _384)
    I <> (DMN, _495)
    J <> (ENO, _5a1)
    K <> (FGP, _267)
    L <> (GHQ, _378)
    M <> (HRI, _489)
    N <> (ISJ, _59a)
    O <> (JTF, _1a6)
    P <> (KTP, _6b7)
    Q <> (LPR, _7b8)
    R <> (MQS, _8b9)
    S <> (NTR, _9ba)
    T <> (OSP, _ab6)
    _0 <> (ABCDE, _12345)
    _1 <> (AFOJE, _5a620)
    _2 <> (BGKFA, _16730)
    _3 <> (CHLGB, _27840)
    _4 <> (DIMHC, _38950)
    _5 <> (EJNID, _49a10)
    _6 <> (KPTOF, _ab721)
    _7 <> (LQPKG, _6b832)
    _8 <> (MRQLH, _7b943)
    _9 <> (NSRMI, _8ba54)
    _a <> (OTSNJ, _9b615)
    _b <> (PQRST, _a9876)
}

0 ABCDE
    A _012 => 012
        0 ABCDE => -----
        1 AOFJE => -OF--
            O _1a6 => -a6
                a OTSNJ => -TS--
                    T _ab6 => -b-
                        b PQRST => -----
                    S _9ba => ---
                6 KPTOF => -P---
                    P _6b7 => ---
            F _162 => ---
        2 BGKFA => -GKF-
            G _273 => -7-
                7 LQPKG => -Q---
                    Q _7b8 => ---
            K _267 => ---
            F _162 => ---
    B _023 => --3
        3 CHLGB => -HLG-
            H _384 => -8-
                8 MRQLH => -----
            L _378 => ---
            G _273 => ---
    C _034 => --4
        4 DIMHC => -IM--
            I _495 => -9-
                9 NSRMI => --R--
                    R _8b9 => ---
            M _489 => ---
    D _045 => --5
        5 EJNID => -JN-
            J _5a1 => ---
            N _59a => ---

    E _051 => ---

ABCDE, OFGKFHLGIMJN, TSPQR



_0 {
    A _012 {
        O _1a6 {
            T _ab6
            S _9ba
            P _6b7
        }
        F _162
        G _273 {
            Q _7b8
        }
        K _267
        F _162
    }
    B _023 {
        H _384
        L _378
        G _273
    }
    C _034 {
        I _495 {
            R _8b9
        }
        M _489
    }
    D _045 {
        J _5a1
        N _59a
    }
    E _051
}



A (
   O (
      T
      S
      P )
   F
   G (
      Q )
   K )
B (
   H
   L
   G )
C (
   I (
      R )
   M )
D (
   J
   N )
E

A B C D E, O F G K H L G I M J N, T S P Q R

  0 1 2 3 4 5 6 7 8 9
0 A
1   B
2   E A
3   F C D   B
4     G J A E B   C
5       A O F H B I E   B
6         K   D K E N B E J
7               L   O E F T F
8                     F   F G
9                           P


BEF
ACG
DJA
AOK.
BEF
BHD
BKL
CIE
ENO
BEF
BEF
JTP
FGP

ico {
    A <> (B,E,F, _00,_01,_02)
    B <> (A,C,G, _00,_02,_03)
    C <> (B,H,D, _00,_03,_04)
    D <> (C,I,E, _00,_04,_05)
    E <> (D,J,A, _00,_05,_01)
    F <> (A,O,K, _01,_06,_02)
    G <> (B,K,L, _02,_07,_03)
    H <> (C,L,M, _03,_08,_04)
    I <> (D,M,N, _04,_09,_05)
    J <> (E,N,O, _05,_10,_01)
    K <> (F,G,P, _02,_06,_07)
    L <> (G,H,Q, _03,_07,_08)
    M <> (H,R,I, _04,_08,_09)
    N <> (I,S,J, _05,_09,_10)
    O <> (J,T,F, _01,_10,_06)
    P <> (K,T,P, _06,_11,_07)
    Q <> (L,P,R, _07,_11,_08)
    R <> (M,Q,S, _08,_11,_09)
    S <> (N,T,R, _09,_11,_10)
    T <> (O,S,P, _10,_11,_06)
    _00 <> (_01,_02,_03,_04,_05, A,B,C,D,E, )
    _01 <> (_05,_10,_06,_02,_00, A,F,O,J,E, )
    _02 <> (_01,_06,_07,_03,_00, B,G,K,F,A, )
    _03 <> (_02,_07,_08,_04,_00, C,H,L,G,B, )
    _04 <> (_03,_08,_09,_05,_00, D,I,M,H,C, )
    _05 <> (_04,_09,_10,_01,_00, E,J,N,I,D, )
    _06 <> (_10,_11,_07,_02,_01, K,P,T,O,F, )
    _07 <> (_06,_11,_08,_03,_02, L,Q,P,K,G, )
    _08 <> (_07,_11,_09,_04,_03, M,R,Q,L,H, )
    _09 <> (_08,_11,_10,_05,_04, N,S,R,M,I, )
    _10 <> (_09,_11,_06,_01,_05, O,T,S,N,J, )
    _11 <> (_10,_09,_08,_07,_06, P,Q,R,S,T, )
}


