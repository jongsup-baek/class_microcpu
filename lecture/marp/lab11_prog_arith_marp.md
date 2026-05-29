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

## 개요: 메모리 맵과 검증 대상

> Goal: MicroCPU의 연산 명령어(ADD, AND, NOT)를 검증. 메모리 모드와 레지스터 모드를 모두 사용

<div class="columns">
<div>

**메모리 맵**

| 주소 | 용도 |
|------|------|
| 0x00~0x0F | 1) NOT 검증 |
| 0x20~0x2F | 2) AND + ADD 검증 |
| 0x40~0x4F | 3) ADD 레지스터 모드 + 뺄셈 |
| 0x80~0x86 | 데이터 영역 |

</div>
<div>

**검증 대상 명령어**

| opc | 명령어 | 이 lab에서 검증 |
|-----|--------|----------------|
| 101 | ADD | 메모리 모드 + 레지스터 모드 |
| 110 | AND | 메모리 모드 |
| 111 | NOT | 이중 반전 |

</div>
</div>

---

## 개요: 검증 실행 흐름

<div class="columns">
<div>

**1) NOT 검증: NOT(NOT(x)) == x**

```
PC=0x00 LDA R0,[0x80] -> R0=0x00AA
PC=0x01 NOT R0 -> R0=0xFF55
PC=0x02 NOT R0 -> R0=0x00AA (원복)
PC=0x03 ADD R0,[0x82] -> R0=0x00AA+0xFF56=0x0000
PC=0x04 BRZ R0 -> skip (R0=0)
PC=0x06 BRA 0x20 -> 2)로 이동
```

**2) AND + ADD 검증 (메모리 모드)**

```
PC=0x20 LDA R0,[0x81] -> R0=0x0001
PC=0x21 AND R0,[0x80] -> R0=0x0001&0x00AA=0x0000
PC=0x22 BRZ R0 -> skip (R0=0)
PC=0x24 ADD R0,[0x81] -> R0=0x0000+0x0001=0x0001
PC=0x25 ADD R0,[0x83] -> R0=0x0001+0xFFFF=0x0000
PC=0x26 BRZ R0 -> skip (R0=0)
PC=0x28 BRA 0x40 -> 3)으로 이동
```

</div>
<div>

**3) ADD 검증 (레지스터 모드 + 뺄셈): 5 - 3 = 2**

```
PC=0x40 LDA R0,[0x84] -> R0=0x0005
PC=0x41 LDA R1,[0x85] -> R1=0x0003
PC=0x42 NOT R1 -> R1=0xFFFC
PC=0x43 ADD R1,[0x81] -> R1=0xFFFC+1=0xFFFD (-3)
PC=0x44 ADD R0,R1 (m=1) -> R0=0x0005+0xFFFD=0x0002
PC=0x45 ADD R0,[0x86] -> R0=0x0002+0xFFFE=0x0000
PC=0x46 BRZ R0 -> skip (R0=0)
PC=0x48 WFR -> 모든 테스트 통과!
```

</div>
</div>

---

## Step 1: test_arith.dat — NOT 검증

`test_arith_blank.dat`를 열고 Comment #1 영역에 바이너리를 작성한다.

NOT(NOT(x)) == x를 확인.

```
// Comment #1. NOT 검증
@00
011_0_00_00_10000000    //  0x00  LDA R0,[0x80]     R0 <- 0x00AA
111_0_00_00_00000000    //  0x01  NOT R0            R0 <- 0xFF55
111_0_00_00_00000000    //  0x02  NOT R0            R0 <- 0x00AA (원복)
101_0_00_00_10000010    //  0x03  ADD R0,[0x82]     R0 <- 0x00AA+0xFF56=0x0000
001_0_00_00_00000000    //  0x04  BRZ R0            R0=0 -> skip
000_0_00_00_00000000    //  0x05  WFR               -- (도달하면 안 됨)
010_0_00_00_00100000    //  0x06  BRA 0x20          2)로 이동
```

---

## Step 2: test_arith.dat — AND + ADD 검증

Comment #2 영역에 바이너리를 추가한다.

```
// Comment #2. AND + ADD 검증 (메모리 모드)
// opc_m_rd_rs_dddddddd  //  addr  asm               설명
@20
011_0_00_00_10000001    //  0x20  LDA R0,[0x81]     R0 <- 0x0001
110_0_00_00_10000000    //  0x21  AND R0,[0x80]     R0 <- 0x0001&0x00AA=0x0000
001_0_00_00_00000000    //  0x22  BRZ R0            R0=0 -> skip
000_0_00_00_00000000    //  0x23  WFR               -- (도달하면 안 됨)
101_0_00_00_10000001    //  0x24  ADD R0,[0x81]     R0 <- 0x0000+0x0001=0x0001
101_0_00_00_10000011    //  0x25  ADD R0,[0x83]     R0 <- 0x0001+0xFFFF=0x0000
001_0_00_00_00000000    //  0x26  BRZ R0            R0=0 -> skip
000_0_00_00_00000000    //  0x27  WFR               -- (도달하면 안 됨)
010_0_00_00_01000000    //  0x28  BRA 0x40          3)으로 이동
```

---

## Step 3: test_arith.dat — ADD 레지스터 모드 + 뺄셈

Comment #3 영역에 바이너리를 추가한다. mode=1 레지스터 연산 + NOT+ADD 뺄셈.

```
// Comment #3. ADD 검증 (레지스터 모드 + 뺄셈)
// opc_m_rd_rs_dddddddd  //  addr  asm               설명
@40
011_0_00_00_10000100    //  0x40  LDA R0,[0x84]     R0 <- 0x0005
011_0_01_00_10000101    //  0x41  LDA R1,[0x85]     R1 <- 0x0003
111_0_01_00_00000000    //  0x42  NOT R1            R1 <- 0xFFFC
101_0_01_00_10000001    //  0x43  ADD R1,[0x81]     R1 <- 0xFFFC+1=0xFFFD (-3)
101_1_00_01_00000000    //  0x44  ADD R0,R1 (m=1)   R0 <- 0x0005+0xFFFD=0x0002
101_0_00_00_10000110    //  0x45  ADD R0,[0x86]     R0 <- 0x0002+0xFFFE=0x0000
001_0_00_00_00000000    //  0x46  BRZ R0            R0=0 -> skip
000_0_00_00_00000000    //  0x47  WFR               -- (도달하면 안 됨)
000_0_00_00_00000000    //  0x48  WFR               모든 테스트 통과!
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
