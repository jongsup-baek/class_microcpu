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

## 개요: 메모리 맵과 레지스터

> Goal: self-modifying code와 loop으로 배열의 이동합을 계산. y[n] = x[n] + x[n+1], 입력 8개에서 출력 7개

<style scoped>
table { width: 100%; }
</style>

<div class="columns">
<div>

**메모리 맵**

| 주소 | 용도 |
|------|------|
| 0x00~0x02 | 초기화 |
| 0x10~0x15 | 이동합 계산 |
| 0x20~0x23 | x[n+1] 주소 update |
| 0x30~0x33 | y[n] 주소 update |
| 0x40~0x43 | 카운터 + loop |
| 0x80~0x87 | x[8] = {3,7,2,5,8,1,4,6} |
| 0x90~0x96 | y[7] = 결과 저장 |
| 0xA0~0xA2 | 상수 (7, 1, -1) |

</div>
<div>

**레지스터 사용**

| reg | 용도 |
|-----|------|
| R0 | x[n] (이전 값) |
| R1 | x[n+1] (현재 값) |
| R2 | 임시 (합계, 명령어 수정) |
| R3 | 카운터 (7→0) |

**self-modifying code**

- 0x10: `LDA R1,[addr]` → 매 반복 addr +1
- 0x14: `STA [addr],R2` → 매 반복 addr +1

</div>
</div>

---

## 개요: 검증 실행 흐름

<div class="columns">
<div>

**초기화**

```
PC=0x00 LDA R0,[0x80] -> R0=x[0]=3
PC=0x01 LDA R3,[0xA0] -> R3=7 (카운터)
PC=0x02 BRA 0x10 -> loop 시작
```

**이동합 계산 (loop)**

```
PC=0x10 LDA R1,[x+n+1] <- self-modify
PC=0x11 LDA R2,R0 (m=1) -> R2=x[n]
PC=0x12 ADD R2,R1 (m=1) -> R2=x[n]+x[n+1]
PC=0x13 LDA R0,R1 (m=1) -> shift
PC=0x14 STA [y+n],R2 <- self-modify
PC=0x15 BRA 0x20
```

</div>
<div>

**self-modify + 카운터**

```
PC=0x20 LDA R2,[0x10] -> 명령어 읽기
PC=0x21 ADD R2,[0xA1] -> addr +1
PC=0x22 STA [0x10],R2 -> 명령어 갱신
PC=0x23 BRA 0x30 -> 다음 섹션
PC=0x30 LDA R2,[0x14] -> 명령어 읽기
PC=0x31 ADD R2,[0xA1] -> addr +1
PC=0x32 STA [0x14],R2 -> 명령어 갱신
PC=0x33 BRA 0x40 -> 다음 섹션
PC=0x40 ADD R3,[0xA2] -> R3 + (-1)
PC=0x41 BRZ R3 -> R3=0이면 done
PC=0x42 BRA 0x10 -> loop back
PC=0x43 WFR -> 이동합 완료!
```

**결과: y = {10, 9, 7, 13, 9, 5, 10}**

</div>
</div>

---

## Step 1: test_movsum.dat — 초기화

Comment #1 영역: R0=x[0], R3=카운터, BRA loop

```
// Comment #1. 초기화
@00
011_0_00_00_10000000    //  0x00  LDA R0,[0x80]     R0 <- x[0] = 3
011_0_11_00_10100000    //  0x01  LDA R3,[0xA0]     R3 <- 7 (카운터)
010_0_00_00_00010000    //  0x02  BRA 0x10          loop 시작
```

---

## Step 2: test_movsum.dat — 이동합 계산

Comment #2 영역: y[n] = x[n] + x[n+1]

```
// Comment #2. y[n] = x[n] + x[n+1]
@10
011_0_01_00_10000001    //  0x10  LDA R1,[0x81]     ← self-modify (x 주소)
011_1_10_00_00000000    //  0x11  LDA R2,R0 (m=1)   R2 <- x[n]
101_1_10_01_00000000    //  0x12  ADD R2,R1 (m=1)   R2 <- x[n] + x[n+1]
011_1_00_01_00000000    //  0x13  LDA R0,R1 (m=1)   R0 <- x[n+1] (shift)
100_0_10_00_10010000    //  0x14  STA [0x90],R2     ← self-modify (y 주소)
010_0_00_00_00100000    //  0x15  BRA 0x20          다음 섹션
```

---

## Step 3: test_movsum.dat — self-modify

<div class="columns">
<div>

Comment #3: x[n+1] 주소 +1

```
// Comment #3. x[n+1] 주소 update with +1
@20
011_0_10_00_00010000    //  0x20  LDA R2,[0x10]     R2 <- 0x10의 명령어
101_0_10_00_10100001    //  0x21  ADD R2,[0xA1]     R2 + 1 (addr 필드 +1)
100_0_10_00_00010000    //  0x22  STA [0x10],R2     0x10 갱신 (0x82,0x83,...)
010_0_00_00_00110000    //  0x23  BRA 0x30          다음 섹션
```

</div>
<div>

Comment #4: y[n] 주소 +1

```
// Comment #4. y[n] 주소 update with +1
@30
011_0_10_00_00010100    //  0x30  LDA R2,[0x14]     R2 <- 0x14의 명령어
101_0_10_00_10100001    //  0x31  ADD R2,[0xA1]     R2 + 1 (addr 필드 +1)
100_0_10_00_00010100    //  0x32  STA [0x14],R2     0x14 갱신(0x91,0x92,...)
010_0_00_00_01000000    //  0x33  BRA 0x40          다음 섹션
```

</div>
</div>

---

## Step 4: test_movsum.dat — 카운터 + loop

Comment #5: R3 -1 = 0이 도달할 때까지 loop back

```
// Comment #5. R3 -1 = 0 이 도달할 때까지 loop back
@40
101_0_11_00_10100010    //  0x40  ADD R3,[0xA2]     R3 + (-1)
001_0_11_00_00000000    //  0x41  BRZ R3            R3=0 -> skip to done
010_0_00_00_00010000    //  0x42  BRA 0x10          loop back
000_0_00_00_00000000    //  0x43  WFR               이동합 완료!
```

결과: y = {10, 9, 7, 13, 9, 5, 10}

---

## Step 5: 시뮬레이션

<div class="columns">
<div>

- 시뮬레이션하여 이동합 결과를 파형으로 확인한다.

```bash
cd sim
xrun -f lab12_blank.f -input ../../shm.tcl
```

</div>
<div>

Expected Waveform:

```
 time  rst_n  halt  pc    설명
-----  -----  ----  ----  ----
   50      0     0    00  reset
 1650      1     0    01  LDA R3,[0xA0]
 3250      1     0    02  BRA 0x10
--- 1회차 (R3=7) ---
 4850      1     0    10  LDA R1,[0x81]  x[1]=7
 6450      1     0    11  LDA R2,R0
 8050      1     0    12  ADD R2,R1      y[0]=3+7=10
 9650      1     0    13  LDA R0,R1      shift
11250      1     0    14  STA [0x90],R2
12850      1     0    20  self-modify x addr
17650      1     0    30  self-modify y addr
22450      1     0    40  ADD R3,[0xA2]  R3=6
24050      1     0    42  BRA 0x10
--- 2회차 (R3=6) ---
25650      1     0    10  LDA R1,[0x82]  x[2]=2
27250      1     0    11  LDA R2,R0
28850      1     0    12  ADD R2,R1      y[1]=7+2=9
30450      1     0    13  LDA R0,R1      shift
32050      1     0    14  STA [0x91],R2
          ...
--- 7회차 (R3=1) → done ---
          1     0    41  BRZ R3 (skip)
          1     0    43  WFR
          1     1    43  halt
```

</div>
</div>

---

## Step 6: Git Checkin

```bash
git status
git add program_code/test_movsum.dat tb_cpu_top.sv
git commit -m "lab12: test_movsum 프로그램 작성 완료"
git push
```
