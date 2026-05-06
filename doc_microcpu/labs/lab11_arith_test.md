---
marp: true
theme: konyang
paginate: true
header: "Lab 11: 연산 검증 프로그램"
footer: "Copyright 2026. 건양대학교 국방반도체공학과. All rights reserved"
---

<!-- _class: title -->
<!-- _header: "" -->
<!-- _footer: "" -->
<!-- _paginate: false -->

# MicroCPU 설계 실무

Lab 11: 연산 검증 프로그램 (test_arith)

<br><br><br><br><br><br>
건양대학교 국방반도체공학과<br>백종섭 교수

---

## Step 1: test_arith.dat — NOT 검증

`test_arith_blank.dat`를 열고 Comment #1 영역에 바이너리를 작성한다.

NOT(NOT(x)) == x를 확인.

```
// Comment #1. NOT 검증
@00
011_0_00_00_10000000    //  0x00  LDA R0,[0x80]  R0 <- 0x00AA
111_0_00_00_00000000    //  0x01  NOT R0
111_0_00_00_00000000    //  0x02  NOT R0 (원복)
101_0_00_00_10000010    //  0x03  ADD R0,[0x82]
001_0_00_00_00000000    //  0x04  BRZ R0         skip
...
010_0_00_00_00100000    //  0x06  BRA 0x20
```

---

## Step 2: test_arith.dat — AND + ADD 검증

Comment #2 영역에 바이너리를 추가한다.

```
// Comment #2. AND + ADD 검증 (메모리 모드)
@20
011_0_00_00_10000001    //  0x20  LDA R0,[0x81]
110_0_00_00_10000000    //  0x21  AND R0,[0x80]
...
010_0_00_00_01000000    //  0x28  BRA 0x40
```

---

## Step 3: test_arith.dat — ADD 레지스터 모드 + 뺄셈

Comment #3 영역에 바이너리를 추가한다. mode=1 레지스터 연산 + NOT+ADD 뺄셈.

```
// Comment #3. ADD 검증 (레지스터 모드 + 뺄셈)
@40
011_0_00_00_10000100    //  0x40  LDA R0,[0x84]  R0 <- 5
011_0_01_00_10000101    //  0x41  LDA R1,[0x85]  R1 <- 3
111_0_01_00_00000000    //  0x42  NOT R1
101_0_01_00_10000001    //  0x43  ADD R1,[0x81]  R1 <- -3
101_1_00_01_00000000    //  0x44  ADD R0,R1(m=1) R0 <- 5+(-3)=2
...
000_0_00_00_00000000    //  0x48  WFR
```

---

## Step 4: 시뮬레이션

- 시뮬레이션하여 NOT/AND/ADD 연산 결과를 파형으로 확인한다.

```bash
cd sim
xrun -f lab11_blank.f -input ../../shm.tcl
```

Expected Waveform:

```
 time  rst_n  halt  pc    설명
-----  -----  ----  ----  ----
   50      0     0    00  reset
 1650      1     0    01  [1] NOT R0
 3250      1     0    02  NOT R0 (원복)
 4850      1     0    03  ADD R0,[0x82]
 6450      1     0    04  BRZ R0 (skip)
 8050      1     0    06  BRA 0x20
 9650      1     0    20  [2] LDA R0,[0x81]
11250      1     0    21  AND R0,[0x80]
12850      1     0    22  BRZ R0 (skip)
14450      1     0    24  ADD R0,[0x81]
16050      1     0    25  ADD R0,[0x83]
17650      1     0    26  BRZ R0 (skip)
19250      1     0    28  BRA 0x40
20850      1     0    40  [3] LDA R0,[0x84]
22450      1     0    41  LDA R1,[0x85]
24050      1     0    42  NOT R1
25650      1     0    43  ADD R1,[0x81]
27250      1     0    44  ADD R0,R1 (m=1)
28850      1     0    45  ADD R0,[0x86]
30450      1     0    46  BRZ R0 (skip)
32050      1     0    48  WFR
32850      1     1    48  halt
```

---

## Step 5: Git Checkin

```bash
git status
git add program_code/test_arith.dat tb_cpu_top.sv
git commit -m "lab11: test_arith 프로그램 작성 완료"
```
