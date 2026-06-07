---
marp: true
theme: konyang
paginate: true
header: "Lab 02: ALU"
footer: "Copyright 2026. 건양대학교 국방반도체공학과. All rights reserved"
---

<!-- _class: title -->
<!-- _header: "" -->
<!-- _footer: "" -->
<!-- _paginate: false -->

# MicroCPU 설계 실무

Lab 02: ALU

<br><br><br><br><br><br>
건양대학교 국방반도체공학과<br>백종섭 교수

---

## Step 1: 설계 — cpu_pkg.sv

`cpu_pkg.sv`를 열고 Comment #1 영역에 opcode/state 타입을 정의한다.

```verilog
// Comment #1 : opcode/state 타입 정의
typedef enum logic [2:0] {WFR, BRZ, BRA, LDA, STA, ADD, AND, NOT} opcode_t;
typedef enum logic [2:0] {INST_ADDR, INST_FETCH, INST_LOAD, IDLE,
                          OP_ADDR, OP_FETCH, OP_ALU, UPDATE} state_t;
```

<p class="ref">💻 cpu_pkg.sv</p>

---

## Step 2: 설계 — alu.sv

`alu.sv`를 열고 포트 주석을 참고하여 Comment #1 영역에 RTL을 작성한다.

```verilog
// Comment #1 : ALU 모듈
always_comb begin
   unique case (opcode)
      ADD     : dout = accum + din;
      AND     : dout = accum & din;
      NOT     : dout = ~accum;
      LDA     : dout = din;
      default : dout = accum;
   endcase
end

assign zero = ~(|dout);
```

<p class="ref">💻 alu.sv</p>

---

## Step 3: TB — ADD/AND 연산

`tb_alu.sv`를 열고 Comment #1, #2를 작성한다.

<div class="columns">
<div>

- Comment #1: drive_alu task

```verilog
// Comment #1 : drive_alu task
task drive_alu(input opcode_t op,
   input logic [15:0] a,
   input logic [15:0] d);
      opcode = op;
      accum  = a;
      din    = d;
   @(posedge clk);
endtask
```

</div>
<div>

- Comment #2: ADD/AND 연산

```verilog
// Comment #2 : ADD/AND 연산
drive_alu(ADD, 16'h0010, 16'h0020);
drive_alu(ADD, 16'hFFFF, 16'h0001);
drive_alu(AND, 16'hFF00, 16'h0F0F);
drive_alu(AND, 16'hAAAA, 16'h5555);
```

<p class="ref">💻 tb_alu.sv</p>

</div>
</div>

---

## Step 4: 시뮬레이션

- 시뮬레이션하여 파형을 확인한다.

```bash
cd sim
xrun -f lab02.f -input ../../shm.tcl
```

Expected Waveform:

```
time  opcode  accum  din    dout   zero
----  ------  -----  -----  -----  ----
   0  WFR     0000   0000   0000   1
 100  ADD     0010   0020   0030   0       #2
 200  ADD     FFFF   0001   0000   1
 300  AND     FF00   0F0F   0F00   0
 400  AND     AAAA   5555   0000   1
```

---

## Step 5: TB — NOT/LDA + BRZ

Comment #3, #4를 추가하고 다시 시뮬레이션한다.

<div class="columns">
<div>

- Comment #3: NOT/LDA 연산

```verilog
// Comment #3 : NOT/LDA 연산
drive_alu(NOT, 16'h00FF, 16'h0000);
drive_alu(LDA, 16'h0000, 16'hBEEF);
```

</div>
<div>

- Comment #4: BRZ zero 플래그 확인

```verilog
// Comment #4 : BRZ zero 플래그 확인
drive_alu(BRZ, 16'h0000, 16'h0000);
drive_alu(BRZ, 16'h1234, 16'h0000);
```

<p class="ref">💻 tb_alu.sv</p>

</div>
</div>

---

## Step 6: 시뮬레이션

- 시뮬레이션하여 파형을 확인한다.

```bash
cd sim
xrun -f lab02.f -input ../../shm.tcl
```

Expected Waveform:

```
time  opcode  accum  din    dout   zero
----  ------  -----  -----  -----  ----
   0  WFR     0000   0000   0000   1
 100  ADD     0010   0020   0030   0       #2
 200  ADD     FFFF   0001   0000   1
 300  AND     FF00   0F0F   0F00   0
 400  AND     AAAA   5555   0000   1
 500  NOT     00FF   0000   FF00   0       #3
 600  LDA     0000   BEEF   BEEF   0
 700  BRZ     0000   0000   0000   1       #4
 800  BRZ     1234   0000   1234   0
```

---

## Step 7: 완성품 복사 + Git Checkin

검증 끝난 .sv 파일을 design 폴더에 모듈명으로 복사하고 커밋한다.

```bash
cd ..
cp cpu_pkg.sv ../design/cpu_pkg.sv
cp alu.sv ../design/alu.sv

git status
git add cpu_pkg.sv alu.sv
git add ../design/cpu_pkg.sv
git add ../design/alu.sv
git commit -m "lab02: done"
git push
```
