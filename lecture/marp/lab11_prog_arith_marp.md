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

## 프로그램 개요 1: NOT 검증

>NOT을 두 번 적용하면 원래 값으로 돌아온다

<div class="columns">
<div>

- **프로그램 개요**

```c
R0 = 0x00AA;
R0 = ~R0;          // 0xFF55
R0 = ~R0;          // 0x00AA (원복)
R0 = R0 + 0xFF56;  // 0x0000 (검증)
// BRZ R0 → skip → 통과
```

- **사용 데이터**

| 주소 | 값 | 용도 |
|------|------|------|
| 0x80 | 0x00AA | NOT 대상 |
| 0x82 | 0xFF56 | -0x00AA (검증용) |




</div>
<div>

**코드 영역**: 0x00~0x06

| 주소 | 명령어 | 동작 |설명|
|------|--------|------|--|
| 0x00 | LDA R0,[0x80] | R0 ← 0x00AA |[0x80]|
| 0x01 | NOT R0 | R0 ← 0xFF55 |NOT 0x00AA |
| 0x02 | NOT R0 | R0 ← 0x00AA |NOT 0xFF55 |
| 0x03 | ADD R0,[0x82] | R0 ← 0x0000 |0x00AA + x82[0xFF56]|
| 0x04 | BRZ R0 ||skip (R0=0)|
| 0x05 | WFR ||도달하면 안 됨|
| 0x06 | BRA 0x20 ||Next |

</div>
</div>

---

## 프로그램 개요 2: AND, ADD 연산 검증
>AND와 ADD 연산자를 메모리 모드를 활용하여 검증한다.

<div class="columns">
<div>

- **프로그램 개요**

```c
R0 = 0x0001 & 0x00AA;  // 0x0000
// BRZ R0 → skip → 통과
R0 = R0 + 1;            // 0x0001
R0 = R0 + (-1);         // 0x0000 (검증)
// BRZ R0 → skip → 통과
```

- **사용 데이터**

| 주소 | 값 | 용도 |
|------|------|------|
| 0x80 | 0x00AA | AND 마스크 |
| 0x81 | 0x0001 | +1 상수 |
| 0x83 | 0xFFFF | -1 상수 |

</div>
<div>

**코드 영역**: 0x20~0x28

| 주소 | 명령어 | 동작 |설명|
|------|--------|------|--|
| 0x20 | LDA R0,[0x81] | R0 ← 0x0001 |[0x81]|
| 0x21 | AND R0,[0x80] | R0 ← 0x0000 |0x0001 & 0x00AA|
| 0x22 | BRZ R0 || skip (R0=0) |
| 0x23 | WFR | |도달하면 안 됨|
| 0x24 | ADD R0,[0x81] | R0 ← 0x0001 |0x0000 + 0x0001|
| 0x25 | ADD R0,[0x83] | R0 ← 0x0000 |0x0001 + 0xFFFF|
| 0x26 | BRZ R0 || skip (R0=0) |
| 0x27 | WFR || 도달하면 안 됨 |
| 0x28 | BRA 0x40 || Next |

</div>
</div>

---

## 프로그램 개요 3: 뺄셈 연산 검증
> NOT+ADD 조합으로 2의 보수 뺄셈을 구현하고, 레지스터 모드(m=1) ADD를 검증한다

<div class="columns">
<div>

- **프로그램 개요**

```c
R0 = 5; R1 = 3;
R1 = ~R1;        // 0xFFFC
R1 = R1 + 1;     // 0xFFFD (-3)
R0 = R0 + R1;    // 0x0002 (m=1)
R0 = R0 + (-2);  // 0x0000 (검증)
// BRZ R0 → skip → 통과
```

- **사용 데이터**

| 주소 | 값 | 용도 |
|------|------|------|
| 0x81 | 0x0001 | +1 (2의 보수용) |
| 0x84 | 0x0005 | 피감수 |
| 0x85 | 0x0003 | 감수 |
| 0x86 | 0xFFFE | -2 (검증용) |

</div>
<div>

**코드 영역**: 0x40~0x48

| 주소 | 명령어 | 동작 |설명|
|------|--------|------|--|
| 0x40 | LDA R0,[0x84] | R0 ← 0x0005 |[0x84]|
| 0x41 | LDA R1,[0x85] | R1 ← 0x0003 |[0x85]|
| 0x42 | NOT R1 | R1 ← 0xFFFC |~0x0003|
| 0x43 | ADD R1,[0x81] | R1 ← 0xFFFD |0xFFFC + 0x0001 = -3|
| 0x44 | ADD R0,R1 (m=1) | R0 ← 0x0002 |5 + (-3) = 2|
| 0x45 | ADD R0,[0x86] | R0 ← 0x0000 |0x0002 + 0xFFFE(-2)|
| 0x46 | BRZ R0 || skip (R0=0) |
| 0x47 | WFR || 도달하면 안 됨 |
| 0x48 | WFR || 프로그램 종료|

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
| 001 | BRZ | R[rd]=0이면 PC+2 | | 검증 결과 판단 |
| 010 | BRA | PC <- data | | PC Counter 이동 |
| 011 | LDA | R[rd] <- mem[data] | R[rd] <- R[rs] | **mem 모드만 사용** |
| 100 | STA | mem[data] <- R[rd] | | 미사용 |
| 101 | ADD | R[rd] <- R[rd] + mem[data] | R[rd] <- R[rd] + R[rs] | **mem/reg 둘 다 사용** |
| 110 | AND | R[rd] <- R[rd] & mem[data] | R[rd] <- R[rd] & R[rs] | **mem 모드만 사용** |
| 111 | NOT | R[rd] <- ~R[rd] | | **반전하는 경우에 사용** |

---

## Step 1: test_arith.dat — NOT 검증

- `test_arith_blank.dat`를 열고 **Comment #1** 영역에 바이너리를 작성한다.

```
// Comment #1. NOT 검증
@00
011_0_00_00_10000000    //  0x00  LDA R0,[0x80]     R0 <- 0x00AA
111_0_00_00_00000000    //  0x01  NOT R0            R0 <- 0xFF55
111_0_00_00_00000000    //  0x02  NOT R0            R0 <- 0x00AA (원복)
101_0_00_00_10000010    //  0x03  ADD R0,[0x82]     R0 <- 0x00AA+0xFF56=0x0000
001_0_00_00_00000000    //  0x04  BRZ R0            R0=0 -> skip
000_0_00_00_00000000    //  0x05  WFR               -- (도달하면 안 됨)
010_0_00_00_00100000    //  0x06  BRA 0x20          Next
```

---

## Step 2: test_arith.dat — AND, ADD 연산 검증

- **Comment #2** 영역에 바이너리를 추가한다.

```
// Comment #2. AND, ADD 연산 검증
@20
011_0_00_00_10000001    //  0x20  LDA R0,[0x81]     R0 <- 0x0001
110_0_00_00_10000000    //  0x21  AND R0,[0x80]     R0 <- 0x0001&0x00AA=0x0000
001_0_00_00_00000000    //  0x22  BRZ R0            R0=0 -> skip
000_0_00_00_00000000    //  0x23  WFR               -- (도달하면 안 됨)
101_0_00_00_10000001    //  0x24  ADD R0,[0x81]     R0 <- 0x0000+0x0001=0x0001
101_0_00_00_10000011    //  0x25  ADD R0,[0x83]     R0 <- 0x0001+0xFFFF=0x0000
001_0_00_00_00000000    //  0x26  BRZ R0            R0=0 -> skip
000_0_00_00_00000000    //  0x27  WFR               -- (도달하면 안 됨)
010_0_00_00_01000000    //  0x28  BRA 0x40          Next
```

---

## Step 3: test_arith.dat — 뺄셈 연산 검증

- **Comment #3** 영역에 바이너리를 추가한다.

```
// Comment #3. ADD 검증 (레지스터 모드 + 뺄셈)
@40
011_0_00_00_10000100    //  0x40  LDA R0,[0x84]     R0 <- 0x0005
011_0_01_00_10000101    //  0x41  LDA R1,[0x85]     R1 <- 0x0003
111_0_01_00_00000000    //  0x42  NOT R1            R1 <- 0xFFFC
101_0_01_00_10000001    //  0x43  ADD R1,[0x81]     R1 <- 0xFFFC+1=0xFFFD (-3)
101_1_00_01_00000000    //  0x44  ADD R0,R1 (m=1)   R0 <- 0x0005+0xFFFD=0x0002
101_0_00_00_10000110    //  0x45  ADD R0,[0x86]     R0 <- 0x0002+0xFFFE=0x0000
001_0_00_00_00000000    //  0x46  BRZ R0            R0=0 -> skip
000_0_00_00_00000000    //  0x47  WFR               -- (도달하면 안 됨)
000_0_00_00_00000000    //  0x48  WFR               프로그램 종료
```

---

## Step 4: tb_cpu_top.sv — TB 작성

- `tb_cpu_top.sv`를 열고 **Comment #1** 영역에 프로그램 로드 + 실행 코드를 작성한다.

```verilog
// Comment #1 : 프로그램 로드 + 실행
$readmemb("../program_code/test_arith.dat",
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

- 시뮬레이션하여 NOT/AND/ADD 연산 결과를 파형으로 확인한다.

```bash
cd sim
xrun -f lab11_blank.f -input ../../shm.tcl
```

</div>
<div>

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

</div>
</div>

---

## Step 6: Git Checkin

```bash
git status
git add program_code/test_arith.dat tb_cpu_top.sv
git commit -m "lab11: test_arith 프로그램 작성 완료"
git push
```
