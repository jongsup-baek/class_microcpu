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

---

## 시뮬레이션

```bash
cd sim
xrun -f lab11_blank.f -input ../../shm.tcl
```

## Step 4: Git Checkin

```bash
git status
git add program_code/test_arith.dat tb_cpu_top.sv
git commit -m "lab11: test_arith 프로그램 작성 완료"
```
