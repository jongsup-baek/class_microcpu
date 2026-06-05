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

## 레퍼런스: Goal과 사용 명령어

> Goal: self-modifying code와 loop으로 배열의 이동합을 계산. y[n] = x[n] + x[n+1], 입력 8개에서 출력 7개

<div class="columns">
<div>

**사용 명령어**

| opc | 명령어 | 이 lab에서 사용 |
|-----|--------|----------------|
| 011 | LDA | mem/reg 모드 |
| 101 | ADD | mem/reg 모드 |
| 100 | STA | 결과 저장 + self-modify |
| 001 | BRZ | 루프 종료 |
| 010 | BRA | 섹션 이동 + loop back |
| 000 | WFR | 프로그램 종료 |

</div>
<div>

**레지스터 사용**

| reg | 용도 |
|-----|------|
| R0 | x[n] (이전 값) |
| R1 | x[n+1] (현재 값) |
| R2 | 임시 (합계, 명령어 수정) |
| R3 | 카운터 (7→0) |

</div>
</div>

---

## 레퍼런스: 메모리 맵

<style scoped>
table { width: 100%; }
</style>

<div class="columns">
<div>

**코드 영역**

| 주소 | 명령어 | 동작 |
|------|--------|------|
| 0x00 | LDA R0,[0x80] | R0 ← x[0] |
| 0x01 | LDA R3,[0xA0] | R3 ← 7 (카운터) |
| 0x02 | BRA 0x10 | loop 진입 |
| 0x10 | LDA R1,[0x81] | R1 ← x[n+1] ← **self-modify** |
| 0x11 | LDA R2,R0 (m=1) | R2 ← x[n] |
| 0x12 | ADD R2,R1 (m=1) | R2 ← x[n] + x[n+1] |
| 0x13 | LDA R0,R1 (m=1) | R0 ← x[n+1] (shift) |
| 0x14 | STA [0x90],R2 | y[n] ← R2 ← **self-modify** |
| 0x15 | BRA 0x20 | 다음 섹션 |
| 0x20~0x23 | self-modify | 0x10 addr +1 |
| 0x30~0x33 | self-modify | 0x14 addr +1 |
| 0x40 | ADD R3,[0xA2] | R3 + (-1) |
| 0x41 | BRZ R3 | R3=0 → done |
| 0x42 | BRA 0x10 | loop back |
| 0x43 | WFR | 완료 |

</div>
<div>

**데이터 영역**

| 주소 | 값 | 용도 |
|------|------|------|
| 0x80 | 3 | x[0] |
| 0x81 | 7 | x[1] |
| 0x82 | 2 | x[2] |
| 0x83 | 5 | x[3] |
| 0x84 | 8 | x[4] |
| 0x85 | 1 | x[5] |
| 0x86 | 4 | x[6] |
| 0x87 | 6 | x[7] |
| 0x90~0x96 | 0 | y[0]~y[6] 결과 |
| 0xA0 | 7 | 카운터 초기값 |
| 0xA1 | 1 | 주소 증분 |
| 0xA2 | -1 (0xFFFF) | 카운터 감소 |

</div>
</div>

---

## 검증 목표

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

## Step 3: test_movsum.dat — x[n+1] 주소 update

Comment #3: x[n+1] 주소를 +1 하여 다음 입력을 가리킨다

```
// Comment #3. x[n+1] 주소 update with +1
@20
011_0_10_00_00010000    //  0x20  LDA R2,[0x10]     R2 <- 0x10의 명령어
101_0_10_00_10100001    //  0x21  ADD R2,[0xA1]     R2 + 1 (addr 필드 +1)
100_0_10_00_00010000    //  0x22  STA [0x10],R2     0x10 갱신 (0x82,0x83,...)
010_0_00_00_00110000    //  0x23  BRA 0x30          다음 섹션
```

---

## Step 4: test_movsum.dat — y[n] 주소 update

Comment #4: y[n] 주소를 +1 하여 다음 출력 위치를 가리킨다

```
// Comment #4. y[n] 주소 update with +1
@30
011_0_10_00_00010100    //  0x30  LDA R2,[0x14]     R2 <- 0x14의 명령어
101_0_10_00_10100001    //  0x31  ADD R2,[0xA1]     R2 + 1 (addr 필드 +1)
100_0_10_00_00010100    //  0x32  STA [0x14],R2     0x14 갱신(0x91,0x92,...)
010_0_00_00_01000000    //  0x33  BRA 0x40          다음 섹션
```

---

## Step 5: test_movsum.dat — 카운터 + loop

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

## Step 6: 시뮬레이션

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
 time      pc   R0    R1    R2    R3
--------  --   ----  ----  ----  ----
    4500  00   0000  0000  0000  0000
   20500  01   0003  0000  0000  0000
   36500  02   0003  0000  0000  0007
   52500  10   0003  0000  0000  0007
   68500  11   0003  0007  0000  0007
   84500  12   0003  0007  0003  0007
  100500  13   0003  0007  000a  0007
  116500  14   0007  0007  000a  0007
  292500  41   0007  0007    *   0006
  372500  13   0007  0002  0009  0006
  644500  13   0002  0005  0007  0005
  916500  13   0005  0008  000d  0004
 1188500  13   0008  0001  0009  0003
 1460500  13   0001  0004  0005  0002
 1732500  13   0004  0006  000a  0001
 1924500  41   0006  0006    *   0000
 1940500  43   0006  0006    *   0000

 결과: y={10,9,7,13,9,5,10}
```

</div>
</div>

---

## Step 7: Git Checkin

```bash
git status
git add program_code/test_movsum.dat tb_cpu_top.sv
git commit -m "lab12: test_movsum 프로그램 작성 완료"
git push
```
