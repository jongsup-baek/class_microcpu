---
marp: true
theme: konyang
paginate: true
header: "Lab 12: 이동합 프로그램"
footer: "Copyright 2026. 건양대학교 국방반도체공학과. All rights reserved"
---

<!-- _class: title -->
<!-- _header: "" -->
<!-- _footer: "" -->
<!-- _paginate: false -->

# MicroCPU 설계 실무

Lab 12: 이동합 프로그램 (test_movsum)

<br><br><br><br><br><br>
건양대학교 국방반도체공학과<br>백종섭 교수

---

## 개요

self-modifying code와 loop으로 배열의 이동합을 계산한다.

y[n] = x[n] + x[n+1], 입력 8개 → 출력 7개

핵심: 명령어도 메모리의 데이터이므로 LDA로 읽고 ADD로 주소를 수정하고 STA로 다시 쓸 수 있다.

---

## Step 1: test_movsum.dat — 초기화

Comment #1 영역: R0=x[0], R3=카운터, BRA loop

```
// Comment #1. 초기화
@00
011_0_00_00_10000000    //  0x00  LDA R0,[0x80]  R0 <- x[0]
011_0_11_00_10100000    //  0x01  LDA R3,[0xA0]  R3 <- 7
010_0_00_00_00010000    //  0x02  BRA 0x10       loop 시작
```

---

## Step 2: test_movsum.dat — 이동합 계산

Comment #2 영역: y[n] = x[n] + x[n+1]

```
// Comment #2. y[n] = x[n] + x[n+1]
@10
011_0_01_00_10000001    //  0x10  LDA R1,[0x81]  ← self-modify
011_1_10_00_00000000    //  0x11  LDA R2,R0(m=1) R2 <- x[n]
101_1_10_01_00000000    //  0x12  ADD R2,R1(m=1) R2 <- x[n]+x[n+1]
011_1_00_01_00000000    //  0x13  LDA R0,R1(m=1) shift
100_0_10_00_10010000    //  0x14  STA [0x90],R2  ← self-modify
```

---

## Step 3: test_movsum.dat — self-modify

<div class="columns">
<div>

Comment #3: x[n+1] 주소 +1

```
// Comment #3. x[n+1] 주소 update +1
@20
011_0_10_00_00010000    //  LDA R2,[0x10]
101_0_10_00_10100001    //  ADD R2,[0xA1]
100_0_10_00_00010000    //  STA [0x10],R2
```

</div>
<div>

Comment #4: y[n] 주소 +1

```
// Comment #4. y[n] 주소 update +1
@30
011_0_10_00_00010100    //  LDA R2,[0x14]
101_0_10_00_10100001    //  ADD R2,[0xA1]
100_0_10_00_00010100    //  STA [0x14],R2
```

</div>
</div>

---

## Step 4: test_movsum.dat — 카운터 + loop

Comment #5: R3 -1 = 0이 도달할 때까지 loop back

```
// Comment #5. R3 -1 = 0 이 도달할 때까지 loop back
@40
101_0_11_00_10100010    //  ADD R3,[0xA2]  R3 + (-1)
001_0_11_00_00000000    //  BRZ R3         R3=0 -> done
010_0_00_00_00010000    //  BRA 0x10       loop back
000_0_00_00_00000000    //  WFR            이동합 완료!
```

결과: y = {10, 9, 7, 13, 9, 5, 10}

---

---

## 시뮬레이션

```bash
cd sim
xrun -f lab12_blank.f -input ../../shm.tcl
```

## Step 5: Git Checkin

```bash
git status
git add program_code/test_movsum.dat tb_cpu_top.sv
git commit -m "lab12: test_movsum 프로그램 작성 완료"
```
