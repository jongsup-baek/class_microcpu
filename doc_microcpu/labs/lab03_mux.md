---
marp: true
theme: konyang
paginate: true
header: "Lab 03: MUX"
footer: "Copyright 2026. 건양대학교 국방반도체공학과. All rights reserved"
---

<!-- _class: title -->
<!-- _header: "" -->
<!-- _footer: "" -->
<!-- _paginate: false -->

# MicroCPU 설계 실무

Lab 03: 2:1 MUX

<br><br><br><br><br><br>
건양대학교 국방반도체공학과<br>백종섭 교수

---

## Step 1: 설계 — mux2to1.sv

`mux2to1_blank.sv`를 열고 Comment #1 영역에 RTL을 작성한다.

```verilog
// Comment #1 : 2:1 MUX 모듈
assign dout = sel_a ? din_a : din_b;
```

<p class="ref">💻 mux2to1.sv</p>

---

## Step 2: TB — sel_a=1, sel_a=0

<div class="columns">
<div>

- Comment #1: drive_mux task

```verilog
// Comment #1 : drive_mux task
task drive_mux(input logic [7:0] a,
   input logic [7:0] b, input logic s);
      din_a = a;
      din_b = b;
      sel_a = s;
   @(posedge clk);
endtask
```

- Comment #2: sel_a=1 → din_a 선택

```verilog
// Comment #2 : sel_a=1 → din_a 선택
drive_mux(8'hAA, 8'h55, 1);
drive_mux(8'hFF, 8'h00, 1);
```

</div>
<div>

- Comment #3: sel_a=0 → din_b 선택

```verilog
// Comment #3 : sel_a=0 → din_b 선택
drive_mux(8'hAA, 8'h55, 0);
drive_mux(8'h00, 8'hFF, 0);
```

<p class="ref">💻 tb_mux2to1.sv</p>

</div>
</div>

---

## Step 3: 시뮬레이션

- 시뮬레이션하여 파형을 확인한다.

```bash
cd sim
xrun -f lab03_blank.f -input ../../shm.tcl
```

Expected Waveform:

```
time  sel_a  din_a  din_b  dout
----  -----  -----  -----  ----
   0  0      00     00     00
 100  1      AA     55     AA     #2
 200  1      FF     00     FF
 300  --     --     --     --
 400  0      AA     55     55     #3
 500  0      00     FF     FF
```

---

## Step 4: TB — sel_a 토글

Comment #4를 추가하고 다시 시뮬레이션한다.

- Comment #4: sel_a 토글

```verilog
// Comment #4 : sel_a 토글
drive_mux(8'h12, 8'h34, 1);
drive_mux(8'h12, 8'h34, 0);
drive_mux(8'h12, 8'h34, 1);
```

<p class="ref">💻 tb_mux2to1.sv</p>

---

## Step 5: 시뮬레이션

- 시뮬레이션하여 파형을 확인한다.

```bash
cd sim
xrun -f lab03_blank.f -input ../../shm.tcl
```

Expected Waveform:

```
time  sel_a  din_a  din_b  dout
----  -----  -----  -----  ----
   0  0      00     00     00
 100  1      AA     55     AA     #2
 200  1      FF     00     FF
 300  --     --     --     --
 400  0      AA     55     55     #3
 500  0      00     FF     FF
 600  --     --     --     --
 700  1      12     34     12     #4
 800  0      12     34     34
 900  1      12     34     12
```

---

## Step 6: 완성품 복사

```bash
cd ..
cp mux2to1.sv ../../../design/
```

---

## Step 7: Git Checkin

```bash
git status
git add mux2to1.sv tb_mux2to1.sv ../../../design/mux2to1.sv
git commit -m "lab03: mux2to1 설계 완료"
```
