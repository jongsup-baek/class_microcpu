---
marp: true
theme: konyang
paginate: true
header: "Lab 09: CPU Core + Top"
footer: "Copyright 2026. 건양대학교 국방반도체공학과. All rights reserved"
---

<!-- _class: title -->
<!-- _header: "" -->
<!-- _footer: "" -->
<!-- _paginate: false -->

# MicroCPU 설계 실무

Lab 09: CPU Core + Top 조립

<br><br><br><br><br><br>
건양대학교 국방반도체공학과<br>백종섭 교수

---

## Step 1: 설계 — cpu_core.sv (1/2)

`cpu_core_blank.sv`를 열고 Comment #1 영역에 블록 인스턴스를 연결한다.

```verilog
instr_reg u_ir (
   .ir_opcode, .ir_mode, .ir_rd, .ir_rs, .ir_addr,
   .din(data_out), .clk(clk_sys), .enable(ir_load), .rst_n );

regfile u_regfile (
   .rd_data(rd_data), .rs_data(rs_data),
   .rd_addr(ir_rd), .rs_addr(ir_rs),
   .wr_data(alu_result), .wr_addr(ir_rd),
   .wr_en(load_reg), .clk(clk_sys), .rst_n );

prog_counter u_pc (
   .pc_count(pc_addr), .din(ir_addr),
   .clk(clk_sys), .load(pc_load), .enable(pc_inc), .rst_n );

mux2to1 #(16) u_opmux (
   .dout(alu_operand), .din_a(data_out), .din_b(rs_data), .sel_a(~ir_mode) );
```

---

## Step 1: 설계 — cpu_core.sv (2/2)

```verilog
alu u_alu (
   .dout(alu_result), .zero(alu_zero),
   .accum(rd_data), .din(alu_operand), .opcode(ir_opcode) );

mux2to1 #(8) u_addrmux (
   .dout(addr), .din_a(pc_addr), .din_b(ir_addr), .sel_a(fetch_phase) );

control u_ctrl (
   .load_reg(load_reg), .mem_rd, .mem_wr,
   .inc_pc(pc_inc), .load_pc(pc_load), .ir_load, .halt, .fetch_phase,
   .ir_opcode, .zero(alu_zero), .clk(clk_sys), .rst_n );
```

---

## Step 2: 설계 — cpu_top.sv

`cpu_top_blank.sv`를 열고 Comment #1 영역에 top 인스턴스를 연결한다.

```verilog
sysclk u_sysclk (
   .clk_ext, .halt, .clk_sys, .rst_n );

cpu_core u_cpu_core (
   .halt, .ir_load,
   .addr(addr), .rd_data(rd_data), .mem_rd(mem_rd), .mem_wr(mem_wr),
   .data_out(data_out), .clk_sys(clk_sys), .rst_n );

mem u_mem (
   .clk(clk_sys), .read(mem_rd), .write(mem_wr),
   .addr(addr), .data_in(rd_data), .data_out(data_out) );
```

---

## Step 3: TB — halt 대기

`tb_cpu_core_blank.sv`를 열고 Comment #1을 작성한다.

```verilog
// Comment #1 : halt 대기
repeat (100) begin
   @(posedge clk_ext);
   if (halt) break;
end
```

메모리를 0으로 초기화 → 첫 명령어가 WFR(=0) → halt.

<p class="ref">💻 tb_cpu_core.sv</p>

---

## Step 4: 시뮬레이션

- 시뮬레이션하여 컴파일 + halt 동작을 확인한다.

```bash
cd sim
xrun -f lab09_blank.f -input ../../shm.tcl
```

Expected Waveform:

```
time  rst_n  clk_sys  halt  state       addr  mem_rd  mem_wr
----  -----  -------  ----  ----------  ----  ------  ------
  50      0        0     0  INST_ADDR     00       0       0
 150      0        0     0  INST_ADDR     00       0       0
 250      1        1     0  INST_FETCH    00       1       0    #1
 350      1        0     0  INST_FETCH    00       1       0
 450      1        1     0  INST_LOAD     00       1       0
 550      1        0     0  INST_LOAD     00       1       0
 650      1        1     0  INST_DECODE   00       1       0
 750      1        0     0  INST_DECODE   00       1       0
 850      1        1     1  OP_ADDR       00       0       0
```

---

## Step 5: 완성품 복사 + Git Checkin

검증 끝난 _blank.sv 파일을 lab00-design 폴더에 모듈명으로 복사하고 커밋한다.

```bash
cd ..
cp cpu_core_blank.sv ../lab00-design/cpu_core.sv
cp cpu_top_blank.sv ../lab00-design/cpu_top.sv

git status
git add cpu_core_blank.sv cpu_top_blank.sv
git add ../lab00-design/cpu_core.sv
git add ../lab00-design/cpu_top.sv
git commit -m "lab09: done"
git push
```
