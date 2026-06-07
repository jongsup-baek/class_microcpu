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

## 프로그램 개요 1: BRA 검증

> BRA 명령어로 PC를 원하는 주소로 점프시킨다

<div class="columns">
<div>

- **프로그램 개요**

```c
PC = 0x00;
BRA 0x05;   // PC → 0x05
BRA 0x20;   // PC → 0x20 (2)로 이동)
// 0x01~0x04는 도달하면 안 됨
```

- **사용 데이터**

이 섹션은 데이터를 사용하지 않는다

</div>
<div>

**코드 영역**: 0x00~0x06

| 주소 | 명령어 | 동작 |설명|
|------|--------|------|--|
| 0x00 | BRA 0x05 | PC ← 0x05 |점프|
| 0x01 | WFR || 도달하면 안 됨 |
| 0x02 | WFR || 도달하면 안 됨 |
| 0x03 | WFR || 도달하면 안 됨 |
| 0x04 | WFR || 도달하면 안 됨 |
| 0x05 | BRA 0x20 || Next |

</div>
</div>

---

## 프로그램 개요 2: LDA + BRZ 검증

> LDA로 메모리 값을 로드하고, BRZ로 R0=0일 때 skip 동작을 검증한다

<div class="columns">
<div>

- **프로그램 개요**

```c
R0 = mem[0x80];   // R0=0x0000
BRZ R0;           // skip (R0=0)
// WFR 도달하면 안 됨
R0 = mem[0x81];   // R0=0x00FF
BRZ R0;           // no skip (R0!=0)
BRA 0x40;         // 3)으로 이동
```

- **사용 데이터**

| 주소 | 값 | 용도 |
|------|------|------|
| 0x80 | 0x0000 | 상수 0 (BRZ skip) |
| 0x81 | 0x00FF | 상수 255 (BRZ no skip) |

</div>
<div>

**코드 영역**: 0x20~0x25

| 주소 | 명령어 | 동작 |설명|
|------|--------|------|--|
| 0x20 | LDA R0,[0x80] | R0 ← 0x0000 |[0x80]|
| 0x21 | BRZ R0 || skip (R0=0) |
| 0x22 | WFR || 도달하면 안 됨 |
| 0x23 | LDA R0,[0x81] | R0 ← 0x00FF |[0x81]|
| 0x24 | BRZ R0 || no skip (R0≠0) |
| 0x25 | BRA 0x40 || Next |

</div>
</div>

---

## 프로그램 개요 3: STA 검증

> STA로 레지스터 값을 메모리에 저장하고, 다시 읽어서 검증한다

<div class="columns">
<div>

- **프로그램 개요**

```c
mem[0x82] = R0;   // 0x00FF 저장
R0 = mem[0x80];   // R0=0x0000
mem[0x82] = R0;   // 0x0000 덮어쓰기
R0 = mem[0x82];   // R0=0x0000 읽기
BRZ R0;           // skip (R0=0) → 통과
```

- **사용 데이터**

| 주소 | 값 | 용도 |
|------|------|------|
| 0x80 | 0x0000 | 상수 0 |
| 0x82 | 0xAAAA | 임시 변수 (STA 대상) |

</div>
<div>

**코드 영역**: 0x40~0x46

| 주소 | 명령어 | 동작 |설명|
|------|--------|------|--|
| 0x40 | STA [0x82],R0 | mem[0x82] ← 0x00FF |R0 저장|
| 0x41 | LDA R0,[0x80] | R0 ← 0x0000 |[0x80]|
| 0x42 | STA [0x82],R0 | mem[0x82] ← 0x0000 |덮어쓰기|
| 0x43 | LDA R0,[0x82] | R0 ← 0x0000 |읽기 검증|
| 0x44 | BRZ R0 || skip (R0=0) |
| 0x45 | WFR || 도달하면 안 됨 |
| 0x46 | WFR || 프로그램 종료 |

</div>
</div>

---

## 프로그램에서 사용 명령어

<style scoped>
table { width: 100%; }
</style>

| opc | 명령어 | 동작(기본,m=0) | m=1 | 이번 실습 |
|-----|--------|------|------|---|
| 000 | WFR | 정지 | | 프로그램 종료 |
| 001 | BRZ | R[rd]=0이면 PC+2 (skip) | | **skip/no skip 검증** |
| 010 | BRA | PC <- data | | **PC 점프 검증** |
| 011 | LDA | R[rd] <- mem[data] | R[rd] <- R[rs] | **mem 모드만 사용** |
| 100 | STA | mem[data] <- R[rd] | | **메모리 저장 검증** |
| 101 | ADD | R[rd] <- R[rd] + mem[data] | R[rd] <- R[rd] + R[rs] | 미사용 |
| 110 | AND | R[rd] <- R[rd] & mem[data] | R[rd] <- R[rd] & R[rs] | 미사용 |
| 111 | NOT | R[rd] <- ~R[rd] | | 미사용 |

**데이터 영역**

| 주소 | 값 | 용도 |
|------|------|------|
| 0x80 | 0x0000 | 상수 0 |
| 0x81 | 0x00FF | 상수 255 |
| 0x82 | 0xAAAA | 임시 변수 (STA 대상) |

---

## Step 1: test_ctrl.dat — BRA 검증

- `test_ctrl_blank.dat`를 열고 **Comment #1** 영역에 바이너리를 작성한다.

```
// Comment #1. BRA 검증 
@00
010_0_00_00_00000101    //  0x00  BRA 0x05          0x05로 점프
000_0_00_00_00000000    //  0x01  WFR               -- (도달하면 안 됨)
000_0_00_00_00000000    //  0x02  WFR               -- (도달하면 안 됨)
000_0_00_00_00000000    //  0x03  WFR               -- (도달하면 안 됨)
000_0_00_00_00000000    //  0x04  WFR               -- (도달하면 안 됨)
010_0_00_00_00100000    //  0x05  BRA 0x20          Next
```

---

## Step 2: test_ctrl.dat — LDA + BRZ 검증

- **Comment #2** 영역에 바이너리를 추가한다.

```
// Comment #2. LDA + BRZ 검증
@20
011_0_00_00_10000000    //  0x20  LDA R0,[0x80]     R0 <- 0x0000
001_0_00_00_00000000    //  0x21  BRZ R0            R0=0 -> skip
000_0_00_00_00000000    //  0x22  WFR               -- (도달하면 안 됨)
011_0_00_00_10000001    //  0x23  LDA R0,[0x81]     R0 <- 0x00FF
001_0_00_00_00000000    //  0x24  BRZ R0            R0!=0 -> no skip
010_0_00_00_01000000    //  0x25  BRA 0x40          Next
```

---

## Step 3: test_ctrl.dat — STA 검증

- **Comment #3** 영역에 바이너리를 추가한다.

```
// Comment #3. STA 검증
@40
100_0_00_00_10000010    //  0x40  STA [0x82],R0     mem[0x82] <- 0x00FF
011_0_00_00_10000000    //  0x41  LDA R0,[0x80]     R0 <- 0x0000
100_0_00_00_10000010    //  0x42  STA [0x82],R0     mem[0x82] <- 0x0000
011_0_00_00_10000010    //  0x43  LDA R0,[0x82]     R0 <- 0x0000
001_0_00_00_00000000    //  0x44  BRZ R0            R0=0 -> skip
000_0_00_00_00000000    //  0x45  WFR               -- (도달하면 안 됨)
000_0_00_00_00000000    //  0x46  WFR               프로그램 종료
```

---

## Step 4: tb_cpu_top.sv — TB 작성

- `tb_cpu_top.sv`를 열고 **Comment #1** 영역에 프로그램 로드 + 실행 코드를 작성한다.

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

<div class="columns">
<div>

- 시뮬레이션하여 BRA/BRZ/STA 동작을 파형으로 확인한다.

```bash
cd sim
xrun -f lab10_blank.f -input ../../shm.tcl
```

</div>
<div>

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

</div>
</div>

---

## Step 6: Git Checkin

```bash
git status
git add program_code/test_ctrl.dat tb_cpu_top.sv
git commit -m "lab10: test_ctrl 프로그램 작성 완료"
git push
```
