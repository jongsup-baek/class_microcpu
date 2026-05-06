---
marp: true
theme: konyang
paginate: true
header: "Lab 04: Program Counter"
footer: "Copyright 2026. 건양대학교 국방반도체공학과. All rights reserved"
---

<!-- _class: title -->
<!-- _header: "" -->
<!-- _footer: "" -->
<!-- _paginate: false -->

# MicroCPU 설계 실무

Lab 04: Program Counter

<br><br><br><br><br><br>
건양대학교 국방반도체공학과<br>백종섭 교수

---

## Step 1: 설계 — prog_counter.sv

`prog_counter_blank.sv`를 열고 Comment #1 영역에 RTL을 작성한다.

```verilog
// Comment #1 : 프로그램 카운터 모듈
always_ff @(posedge clk or negedge rst_n) begin
   if (!rst_n)
      pc_count <= '0;
   else if (load)
      pc_count <= din;
   else if (enable)
      pc_count <= pc_count + 1;
end
```

<p class="ref">💻 prog_counter.sv</p>

---

## Step 2: TB — enable 카운트

<div class="columns">
<div>

- Comment #1: enable_pc_duration/load_pc task

```verilog
// Comment #1 : enable_pc_duration/load_pc task
task enable_pc_duration(input int n);
      enable = 1;
      load   = 0;
   repeat(n) @(posedge clk);
endtask

task load_pc(input logic [7:0] val);
      enable = 0;
      load   = 1;
      din    = val;
   @(posedge clk);
endtask
```

</div>
<div>

- Comment #2: enable 카운트

```verilog
// Comment #2 : enable 카운트
enable_pc_duration(4);
```

시뮬레이션하여 파형을 확인한다.

```bash
cd sim
xrun -f lab04_blank.f -input ../../shm.tcl
```

<p class="ref">💻 tb_prog_counter.sv</p>

</div>
</div>

---

## Step 2: Expected Waveform

```
time  rst_n  enable  load  din  pc_count
----  -----  ------  ----  ---  --------
   0      0       0     0   00        00
 100      1       0     0   00        00
 200      1       1     0   00        00    #2
 300      1       1     0   00        01
 400      1       1     0   00        02
 500      1       1     0   00        03
```

---

## Step 3: TB — load 값 로드 후 카운트

Comment #3을 추가하고 다시 시뮬레이션한다.

```verilog
// Comment #3 : load 값 로드 후 카운트
load_pc(8'hF0);
enable_pc_duration(3);
```

<p class="ref">💻 tb_prog_counter.sv</p>

---

## Step 3: Expected Waveform

```
time  rst_n  enable  load  din  pc_count
----  -----  ------  ----  ---  --------
   0      0       0     0   00        00
 100      1       0     0   00        00
 200      1       1     0   00        00    #2
 300      1       1     0   00        01
 400      1       1     0   00        02
 500      1       1     0   00        03
 600      1       0     1   F0        04    #3
 700      1       1     0   F0        F0
 800      1       1     0   F0        F1
 900      1       1     0   F0        F2
1000      1       1     0   F0        F3
```

---

## Step 4: 완성품 복사

```bash
cd ..
cp prog_counter.sv ../../../design/
```

---

## Step 5: Git Checkin

```bash
git status
git add prog_counter.sv tb_prog_counter.sv
git add ../../../design/prog_counter.sv
git commit -m "lab04: prog_counter 설계 완료"
```
