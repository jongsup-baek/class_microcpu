---
marp: true
theme: konyang
paginate: true
header: "Lab 01: Register File"
footer: "Copyright 2026. 건양대학교 국방반도체공학과. All rights reserved"
---

<!-- _class: title -->
<!-- _header: "" -->
<!-- _footer: "" -->
<!-- _paginate: false -->

# MicroCPU 설계 실무

Lab 01: Register File

<br><br><br><br><br><br>
건양대학교 국방반도체공학과<br>백종섭 교수

---

## Step 1: 설계 — regfile.sv

`regfile_blank.sv`를 열고 포트 주석을 참고하여 Comment #1 영역에 RTL을 작성한다.

```verilog
// Comment #1 : 레지스터 파일 모듈
logic [15:0] regs [0:3];

always_ff @(posedge clk or negedge rst_n) begin
   if (!rst_n) begin
      regs[0] <= '0;
      regs[1] <= '0;
      regs[2] <= '0;
      regs[3] <= '0;
   end
   else if (wr_en) begin
      regs[wr_addr] <= wr_data;
   end
end

assign rd_data = regs[rd_addr];
assign rs_data = regs[rs_addr];
```

<p class="ref">💻 regfile.sv</p>

---

## Step 2: TB — 쓰기/읽기 검증

`tb_regfile_blank.sv`를 열고 Comment #1, #2를 작성한다.

<div class="columns">
<div>

- Comment #1: write_reg / read_reg task

```verilog
// Comment #1 : write_reg task
task write_reg(input logic [1:0] addr, input logic [15:0] data);
      wr_en   = 1;
      wr_addr = addr;
      wr_data = data;
   @(posedge clk);
endtask

task read_reg(input logic [1:0] rd, input logic [1:0] rs);
      wr_en   = 0;
      rd_addr = rd;
      rs_addr = rs;
   @(posedge clk);
endtask
```

</div>
<div>

- Comment #2: R0~R3 쓰기 후 읽기 확인

```verilog
// Comment #2 : 쓰기 검증
write_reg(2'd0, 16'hAAAA);
write_reg(2'd1, 16'hBBBB);
write_reg(2'd2, 16'hCCCC);
write_reg(2'd3, 16'hDDDD);

read_reg(2'd0, 2'd1);
read_reg(2'd2, 2'd3);
```

<p class="ref">💻 tb_regfile.sv</p>

</div>
</div>

---

## Step 3: 시뮬레이션

- 시뮬레이션하여 파형을 확인한다.

```bash
cd sim
xrun -f lab01_blank.f -input ../../shm.tcl
```

Expected Waveform:

```
time  rst_n  wr_en  wr_addr  wr_data  rd_addr  rs_addr  rd_data  rs_data
----  -----  -----  -------  -------  -------  -------  -------  -------
   0      0      0        0     0000        0        0     0000     0000    #2
 100      1      0        0     0000        0        0     0000     0000
 200      1      1        0     AAAA        0        0     AAAA     AAAA
 300      1      1        1     BBBB        0        0     AAAA     AAAA
 400      1      1        2     CCCC        0        0     AAAA     AAAA
 500      1      1        3     DDDD        0        0     AAAA     AAAA
 600      1      0        3     DDDD        0        1     AAAA     BBBB
 700      1      0        3     DDDD        2        3     CCCC     DDDD
```

---

## Step 4: TB — wr_en 비활성 검증

Comment #3, #4를 추가하고 다시 시뮬레이션한다.

<div class="columns">
<div>

- Comment #3: write_nowr task

```verilog
// Comment #3 : write_nowr task
task write_nowr(input logic [1:0] addr, input logic [15:0] data);
      wr_en   = 0;
      wr_addr = addr;
      wr_data = data;
   @(posedge clk);
endtask
```

</div>
<div>

- Comment #4: wr_en 비활성 쓰기 시도

```verilog
// Comment #4 : wr_en 비활성 쓰기 시도
write_nowr(2'd0, 16'hEEEE);
write_nowr(2'd1, 16'hFFFF);

read_reg(2'd0, 2'd1);
```

<p class="ref">💻 tb_regfile.sv</p>

</div>
</div>

---

## Step 5: 시뮬레이션

- 시뮬레이션하여 R0=AAAA, R1=BBBB가 유지되는지 확인한다.

```bash
cd sim
xrun -f lab01_blank.f -input ../../shm.tcl
```

Expected Waveform:

```
time  rst_n  wr_en  wr_addr  wr_data  rd_addr  rs_addr  rd_data  rs_data
----  -----  -----  -------  -------  -------  -------  -------  -------
   0      0      0        0     0000        0        0     0000     0000    #2
 100      1      0        0     0000        0        0     0000     0000
 200      1      1        0     AAAA        0        0     AAAA     AAAA
 300      1      1        1     BBBB        0        0     AAAA     AAAA
 400      1      1        2     CCCC        0        0     AAAA     AAAA
 500      1      1        3     DDDD        0        0     AAAA     AAAA
 600      1      0        3     DDDD        0        1     AAAA     BBBB
 700      1      0        3     DDDD        2        3     CCCC     DDDD
 800      1      0        0     EEEE        2        3     AAAA     AAAA    #4
 900      1      0        1     FFFF        2        3     AAAA     AAAA
1000      1      0        1     FFFF        0        1     AAAA     BBBB
```

---

## Step 6: 완성품 복사

```bash
cd ..
cp regfile.sv ../../design/
```

---

## Step 7: Git Checkin

```bash
git status
git add regfile.sv tb_regfile.sv
git add ../../design/regfile.sv
git commit -m "lab01: regfile 설계 완료"
```
