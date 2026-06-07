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

## 프로그램 개요: 배열의 이동합

> 배열의 이동합을 계산한다. y[n] = x[n] + x[n+1], 입력은 주어진 8개이고 출력 7개임

<div class="columns">
<div>

- **입력** : x[0:7] = {3, 7, 2, 5, 8, 1, 4, 6};
```c
cnt = 7; n=0;
do {
    y[n] = x[n] + x[n+1];
    cnt = cnt -1; n++;
} while (cnt != 0);
// y = {10, 9, 7, 13, 9, 5, 10}
```
- MicroCPU 에 맞게 재작성

```c
x[0:7] = {3, 7, 2, 5, 8, 1, 4, 6};
R3 = 7;  n=0;               // R3=cnt
do {
    y[n] = x[n] + x[n+1];   // self-modify로 n 증가
    R3 = R3 + (-1); n++;    // ADD R3,[0xA2]
    // x[n]= x[n+1]
    // x[n+1]= x[n+2]
    // y[n]= y[n+1]
} while (R3 != 0);           // BRZ R3

```
- **예상 출력** : y[0:6] = {10, 9, 7, 13, 9, 5, 10}
  
</div>
<div>

**레지스터 사용**

| reg | 용도 | 설명|
|-----|------|---|
| R0 | x[n] | 이전 값 |
| R1 | x[n+1] | 현재 값 |
| R2 | 임시 | (합계, 명령어 수정) |
| R3 | 카운터 |7에서 0으로 감소 |

**상수형 데이터 영**
| 주소 | 값 |설명|
|------|------|---|
| 0xA0 | 7 | 카운터 초기값 |
| 0xA1 | 1 | 주소 증분 |
| 0xA2 |0xFFFF| -1, 카운터 감소 |

</div>
</div>

---


## 프로그램의 이해

<style scoped>
table { width: 100%; }
</style>

<div class="columns">
<div>

| 주소 | 설명1 |설명2|
|------|------|---|
| 0x00~0x02 | R0=x[0]=3, R3=7|BRA 0x10 |
| 0x10 | LDA R1,[0x81]| R1 ← x[n+1] **0x22에서 수정됨** |
| 0x11 | LDA R2,R0 (m=1)| R2 ← R0 |
| 0x12 | ADD R2,R1 (m=1)| R2 ← R0 + R1 |
| 0x13 | LDA R0,R1 (m=1)| R0 ← R1 **Shift**|
| 0x14 | STA [0x90],R2 | y[n] ← R2 **0x33에서 수정됨** |
| 0x15 |  | BRA 0x20 |
| 0x20~0x23 | x[n+1]++ |BRA 0x30|
| 0x30~0x33 | y[n]++ |BRA 0x40|
| 0x40~0x42 | R3 + (-1)|BRA 0x10 **BRZ R3**|
| 0x43 | WFR ||

</div>
<div>

**데이터 영역**

| 주소 | 값 | 용도 |주소 | 값 | 용도 |
|------|------|------|------|------|------|
| 0x80 | 3 | x[0] |0x90 | x[0]+x[1] | y[0] |
| 0x81 | 7 | x[1] |0x91 | x[1]+x[2] | y[1] |
| 0x82 | 2 | x[2] |0x92 | x[2]+x[3] | y[2] |
| 0x83 | 5 | x[3] |0x93 | x[3]+x[4] | y[3] |
| 0x84 | 8 | x[4] |0x94 | x[4]+x[5] | y[4] |
| 0x85 | 1 | x[5] |0x95 | x[5]+x[6] | y[5] |
| 0x86 | 4 | x[6] |0x96 | x[6]+x[7] | y[6] |
| 0x87 | 6 | x[7] |0x97 |   |   |



</div>
</div>

---
## 프로그램에서 사용 명령어

<style scoped>
table { width: 100%; }
</style>

| opc | 명령어 | 동작(기본,m=0) |m=1|이번실습|
|-----|--------|------|------|---|
| 000 | WFR | 정지 ||프로그램 종료|
| 001 | BRZ | R[rd]=0이면 PC+1 ||루프 종료 판단에 사용|
| 010 | BRA | PC <- data ||PC Conter 이동|
| 011 | LDA | R[rd] <- mem[data] | R[rd] <- R[rs] |mem/reg 모드 둘다 사용|
| 100 | STA | mem[data] <- R[rd] ||결과 저장와 명령어 수정 |
| 101 | ADD | R[rd] <- R[rd] + mem[data] | R[rd] <- R[rd] + R[rs] |mem/reg 모드  둘다 사용|
| 110 | AND | R[rd] <- R[rd] & mem[data] | R[rd] <- R[rd] & R[rs] |미사용|
| 111 | NOT | R[rd] <- ~R[rd] ||미사용|


</div>
</div>


---

## Step 1: test_movsum.dat — 초기화

**Comment #1 영역**: R0=x[0], R3=카운터, BRA loop

```
// Comment #1. 초기화
@00
011_0_00_00_10000000    //  0x00  LDA R0,[0x80]     R0 <- x[0] = 3
011_0_11_00_10100000    //  0x01  LDA R3,[0xA0]     R3 <- 7 (카운터)
010_0_00_00_00010000    //  0x02  BRA 0x10          loop 시작
```

---

## Step 2: test_movsum.dat — 이동합 계산

**Comment #2 영역**: y[n] = x[n] + x[n+1]

```
// Comment #2. y[n] = x[n] + x[n+1], loop 본체
@10
011_0_01_00_10000001    //  0x10  LDA R1,[0x81]     R1 <- x[1] = 7 (0x22 Update)
011_1_10_00_00000000    //  0x11  LDA R2,R0 (m=1)   R2 <- R0
101_1_10_01_00000000    //  0x12  ADD R2,R1 (m=1)   R2 <- R2 + R1
100_0_10_00_10010000    //  0x13  STA [0x90],R2     y[0] <- R2 (0x33 Update)
011_1_00_01_00000000    //  0x14  LDA R0,R1 (m=1)   R0 <- R1 =x[1] (x[n] Update)
010_0_00_00_00100000    //  0x15  BRA 0x20          Next
```

---

## Step 3: test_movsum.dat — x[n+1] 주소 update

Comment #3: x[n+1] 주소를 +1 하여 다음 입력을 가리킨다

```
// Comment #3. x[n+1] Update, x[2], x[3], x[4], x[5], x[6], x[7]
@20
011_0_10_00_00010000    //  0x20  LDA R2,[0x10]     R2 <- 0x10의 명령어
101_0_10_00_10100001    //  0x21  ADD R2,[0xA1]     R2 <- R2 + 1 (x[2],x[3],...)
100_0_10_00_00010000    //  0x22  STA [0x10],R2     0x10 <- R2
010_0_00_00_00110000    //  0x23  BRA 0x30          Next
```

---

## Step 4: test_movsum.dat — y[n] 주소 update

Comment #4: y[n] 주소를 +1 하여 다음 출력 위치를 가리킨다

```
// Comment #4. y[n] Update, y[1], y[2], y[3], y[4], y[5], y[6]
@30
011_0_10_00_00010011    //  0x30  LDA R2,[0x13]     R2 <- 0x13의 명령어
101_0_10_00_10100001    //  0x31  ADD R2,[0xA1]     R2 <- R2 + 1 (y[1],y[2],...)
100_0_10_00_00010011    //  0x32  STA [0x13],R2     0x13 <- R2 
010_0_00_00_01000000    //  0x33  BRA 0x40          Next
```

---

## Step 5: test_movsum.dat — 카운터 + loop

Comment #5: R3 -1 = 0이 도달할 때까지 loop back

```
// Comment #5. R3 -1 = 0 이 도달할 때까지 loop back
@40
101_0_11_00_10100010    //  0x40  ADD R3,[0xA2]     R3 <- R3 + (-1)
001_0_11_00_00000000    //  0x41  BRZ R3            R3=0 -> skip to 0x43
010_0_00_00_00010000    //  0x42  BRA 0x10          loop back
000_0_00_00_00000000    //  0x43  WFR               loop stop
```

결과: y = {10, 9, 7, 13, 9, 5, 10}

---

## Step 6: tb_cpu_top.sv — TB 작성

`tb_cpu_top.sv`를 열고 Comment #1 영역에 프로그램 로드 + 실행 코드를 작성한다.

```verilog
// Comment #1 : 프로그램 로드 + 실행
$readmemb("../program_code/test_movsum.dat",
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

## Step 7: 시뮬레이션

<div class="columns">
<div>

- 시뮬레이션하여 이동합 결과를 파형으로 확인한다.

```bash
cd sim
xrun -f lab12_demo.f -input ../../shm.tcl
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

## Step 8: Git Checkin

```bash
git status
git add program_code/test_movsum.dat tb_cpu_top.sv
git commit -m "lab12: test_movsum 프로그램 작성 완료"
git push
```
