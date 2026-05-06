---
marp: true
theme: konyang
paginate: true
header: "Lab 06: Instruction Register"
footer: "Copyright 2026. 건양대학교 국방반도체공학과. All rights reserved"
---

<!-- _class: title -->
<!-- _header: "" -->
<!-- _footer: "" -->
<!-- _paginate: false -->

# MicroCPU 설계 실무

Lab 06: Instruction Register

<br><br><br><br><br><br>
건양대학교 국방반도체공학과<br>백종섭 교수

---

## Step 1: 설계 — cpu_pkg.sv

`cpu_pkg_blank.sv`를 열고 Comment #1 영역에 타입을 정의한다.

```verilog
// Comment #1 : opcode/state 타입 정의
typedef enum logic [2:0] {WFR, BRZ, BRA, LDA, STA, ADD, AND, NOT} opcode_t;
typedef enum logic [2:0] {INST_ADDR, INST_FETCH, INST_LOAD, IDLE,
                          OP_ADDR, OP_FETCH, OP_ALU, UPDATE} state_t;
```

<p class="ref">💻 cpu_pkg.sv</p>

---

## Step 2: 설계 — instr_reg.sv

`instr_reg_blank.sv`를 열고 Comment #1 영역에 IR을 작성한다.

```verilog
// Comment #1 : IR 모듈
always_ff @(posedge clk or negedge rst_n) begin
   if (!rst_n) begin
      ir_opcode <= WFR;
      ir_mode   <= 1'b0;
      ir_rd     <= 2'b0;
      ir_rs     <= 2'b0;
      ir_data   <= 8'b0;
   end
   else if (enable) begin
      ir_opcode <= opcode_t'(din[15:13]);
      ir_mode   <= din[12];
      ir_rd     <= din[11:10];
      ir_rs     <= din[9:8];
      ir_data   <= din[7:0];
   end
end
```

<p class="ref">💻 instr_reg.sv</p>

---

## Step 3: TB — IR 로드 + 디코드

<div class="columns">
<div>

- Comment #1: load_ir task

```verilog
// Comment #1 : load_ir task
task load_ir(input logic [15:0] instr);
      enable = 1;
      din    = instr;
   @(posedge clk);
      enable = 0;
   @(posedge clk);
endtask
```

</div>
<div>

- Comment #2: IR 로드 + 필드 디코드 검증

```verilog
// Comment #2 : IR 로드 + 필드 디코드 검증
// ADD m=0, Rd=1, Rs=2, data=0x55
load_ir(16'b101_0_01_10_01010101);
// LDA m=1, Rd=3, Rs=0, data=0xAB
load_ir(16'b011_1_11_00_10101011);
// WFR
load_ir(16'b000_0_00_00_00000000);
```

시뮬레이션하여 필드 디코드를 파형으로 확인한다.

<p class="ref">💻 tb_instr_reg.sv</p>

</div>
</div>

---

## Step 3: Expected Waveform

```
time  enable  din    ir_opcode  ir_mode  ir_rd  ir_rs  ir_data
----  ------  -----  ---------  -------  -----  -----  -------
   0      0   0000   WFR             0      0      0       00
 100      0   0000   WFR             0      0      0       00
 200      1   A655   WFR             0      0      0       00    #2
 300      0   A655   ADD             0      1      2       55
 400      1   7CAB   ADD             0      1      2       55
 500      0   7CAB   LDA             1      3      0       AB
 600      1   0000   LDA             1      3      0       AB
 700      0   0000   WFR             0      0      0       00
```

---

## Step 4: 완성품 복사

```bash
cd ..
cp cpu_pkg.sv instr_reg.sv ../../../design/
```

---

## Step 5: Git Checkin

```bash
git status
git add cpu_pkg.sv instr_reg.sv tb_instr_reg.sv
git add ../../../design/cpu_pkg.sv ../../../design/instr_reg.sv
git commit -m "lab06: instr_reg 설계 완료"
```
