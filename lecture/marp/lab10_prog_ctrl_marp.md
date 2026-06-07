---
marp: true
theme: konyang
paginate: true
header: "Lab 10: 제어 검증 프로그램"
footer: "Copyright 2026. 건양대학교 국방반도체공학과. All rights reserved"
---

<!-- _class: title -->
<!-- _header: "" -->
<!-- _footer: "" -->
<!-- _paginate: false -->

# MicroCPU 설계 실무

Lab 10: 제어 검증 프로그램 (test_ctrl)

<br><br><br><br><br><br>
건양대학교 국방반도체공학과<br>백종섭 교수

---

## 레퍼런스: 명령어 형식과 메모리 맵

> Goal: MicroCPU의 제어 및 메모리 명령어(BRA, BRZ, LDA, STA, WFR)를 검증

<style scoped>
table { width: 100%; }
</style>

<div class="columns">
<div>

**16비트 명령어 형식**

| 필드 | 비트 | 의미 |
|------|------|------|
| opc | [15:13] | 명령어 종류 (3비트) |
| m | [12] | 0: 메모리 모드, 1: 레지스터 모드 |
| rd | [11:10] | 대상 레지스터 (R0~R3) |
| rs | [9:8] | 소스 레지스터 (m=1일 때) |
| d | [7:0] | 메모리 주소 또는 즉시값 |

**메모리 맵**

| 주소 | 용도 |
|------|------|
| 0x00~0x0F | 1) BRA 검증 |
| 0x20~0x2F | 2) LDA + BRZ 검증 |
| 0x40~0x4F | 3) STA 검증 |
| 0x80~0x82 | 데이터 영역 |

</div>
<div>

**opc 명령어 이해**

| opc | 명령어 | 동작 |
|-----|--------|------|
| 000 | WFR | 정지 |
| 001 | BRZ | R[rd]=0이면 PC+1 (skip) |
| 010 | BRA | PC <- data |
| 011 | LDA | m=0: R[rd] <- mem[data] <br> m=1: R[rd] <- R[rs] |
| 100 | STA | mem[data] <- R[rd] |
| 101 | ADD | m=0: R[rd] <- R[rd] + mem[data] <br> m=1: R[rd] <- R[rd] + R[rs] |
| 110 | AND | m=0: R[rd] <- R[rd] & mem[data] <br> m=1: R[rd] <- R[rd] & R[rs] |
| 111 | NOT | R[rd] <- ~R[rd] |
</div>
</div>

---

## 검증 목표

<div class="columns">
<div>

**1) BRA 검증**

```
PC=0x00 BRA 0x05 -> 0x05로 점프
PC=0x05 BRA 0x20 -> 2)로 이동
```

**2) LDA + BRZ 검증**

```
PC=0x20 LDA R0,[0x80] -> R0=0x0000
PC=0x21 BRZ R0 -> skip (R0=0)
PC=0x23 LDA R0,[0x81] -> R0=0x00FF
PC=0x24 BRZ R0 -> no skip (R0!=0)
PC=0x25 BRA 0x40 -> 3)으로 이동
```

</div>
<div>

**3) STA 검증**

```
PC=0x40 STA [0x82],R0 -> mem[0x82] <- 0x00FF
PC=0x41 LDA R0,[0x80] -> R0=0x0000
PC=0x42 STA [0x82],R0 -> mem[0x82] <- 0x0000
PC=0x43 LDA R0,[0x82] -> R0=0x0000
PC=0x44 BRZ R0 -> skip (R0=0)
PC=0x46 WFR -> 모든 테스트 통과!
```

**데이터 영역**

| 주소 | 값 | 용도 |
|------|------|------|
| 0x80 | 0x0000 | 상수 0 |
| 0x81 | 0x00FF | 상수 255 |
| 0x82 | 0xAAAA | 임시 변수 (STA 대상) |

</div>
</div>

---

## Step 1: test_ctrl.dat — BRA 검증

`test_ctrl_blank.dat`를 열고 ISA 레퍼런스와 실행 흐름을 참고하여 Comment #1 영역에 바이너리를 작성한다.

```
// Comment #1. BRA 검증 
@00
010_0_00_00_00000101    //  0x00  BRA 0x05          0x05로 점프
000_0_00_00_00000000    //  0x01  WFR               -- (도달하면 안 됨)
000_0_00_00_00000000    //  0x02  WFR               -- (도달하면 안 됨)
000_0_00_00_00000000    //  0x03  WFR               -- (도달하면 안 됨)
000_0_00_00_00000000    //  0x04  WFR               -- (도달하면 안 됨)
010_0_00_00_00100000    //  0x05  BRA 0x20          2)로 이동
```

시뮬레이션하여 BRA 동작을 확인한다.

---

## Step 2: test_ctrl.dat — LDA + BRZ 검증

Comment #2 영역에 바이너리를 추가하고 다시 시뮬레이션한다.

```
// Comment #2. LDA + BRZ 검증
@20
011_0_00_00_10000000    //  0x20  LDA R0,[0x80]     R0 <- 0x0000
001_0_00_00_00000000    //  0x21  BRZ R0            R0=0 -> skip
000_0_00_00_00000000    //  0x22  WFR               -- (도달하면 안 됨)
011_0_00_00_10000001    //  0x23  LDA R0,[0x81]     R0 <- 0x00FF
001_0_00_00_00000000    //  0x24  BRZ R0            R0!=0 -> no skip
010_0_00_00_01000000    //  0x25  BRA 0x40          3)으로 이동
```

---

## Step 3: test_ctrl.dat — STA 검증

Comment #3 영역에 바이너리를 추가하고 다시 시뮬레이션한다.

```
// Comment #3. STA 검증
@40
100_0_00_00_10000010    //  0x40  STA [0x82],R0     mem[0x82] <- 0x00FF
011_0_00_00_10000000    //  0x41  LDA R0,[0x80]     R0 <- 0x0000
100_0_00_00_10000010    //  0x42  STA [0x82],R0     mem[0x82] <- 0x0000
011_0_00_00_10000010    //  0x43  LDA R0,[0x82]     R0 <- 0x0000
001_0_00_00_00000000    //  0x44  BRZ R0            R0=0 -> skip
000_0_00_00_00000000    //  0x45  WFR               -- (도달하면 안 됨)
000_0_00_00_00000000    //  0x46  WFR               모든 테스트 통과!
```

---

## Step 4: tb_cpu_top.sv — TB 작성

`tb_cpu_top.sv`를 열고 Comment #1 영역에 프로그램 로드 + 실행 코드를 작성한다.

```verilog
// Comment #1 : 프로그램 로드 + 실행
$readmemb("../program_code/test_ctrl.dat",
           u_top.u_mem.memory);
reset_dut();
fork
   begin
      #200000;
      $display("TIMEOUT");
   end
   begin
      wait (halt == 1);
   end
join_any
disable fork;
```

---

## Step 5: 시뮬레이션

- 시뮬레이션하여 BRA/BRZ/STA 동작을 파형으로 확인한다.

```bash
cd sim
xrun -f lab10_blank.f -input ../../shm.tcl
```

Expected Waveform:

```
 time  rst_n  halt  pc    설명
-----  -----  ----  ----  ----
   50      0     0    00  reset
 1650      1     0    05  BRA 0x05
 3250      1     0    20  BRA 0x20 → [2]
 4850      1     0    21  BRZ R0 (skip)
 6450      1     0    23  LDA R0,[0x81]
 8050      1     0    24  BRZ R0 (no skip)
 9650      1     0    25  BRA 0x40 → [3]
11250      1     0    40  STA [0x82]
12850      1     0    41  LDA R0,[0x80]
14450      1     0    42  STA [0x82]
16050      1     0    43  LDA R0,[0x82]
17650      1     0    44  BRZ R0 (skip)
19250      1     0    46  WFR
20050      1     1    46  halt
```

---

## Step 6: Git Checkin

```bash
git status
git add program_code/test_ctrl.dat tb_cpu_top.sv
git commit -m "lab10: test_ctrl 프로그램 작성 완료"
git push
```
