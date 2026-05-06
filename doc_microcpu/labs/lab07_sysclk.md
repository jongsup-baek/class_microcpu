---
marp: true
theme: konyang
paginate: true
header: "Lab 07: System Clock"
footer: "Copyright 2026. 건양대학교 국방반도체공학과. All rights reserved"
---

<!-- _class: title -->
<!-- _header: "" -->
<!-- _footer: "" -->
<!-- _paginate: false -->

# MicroCPU 설계 실무

Lab 07: System Clock

<br><br><br><br><br><br>
건양대학교 국방반도체공학과<br>백종섭 교수

---

## Step 1: 설계 — sysclk.sv

`sysclk_blank.sv`를 열고 Comment #1 영역에 RTL을 작성한다.

```verilog
// Comment #1 : sysclk 모듈
wire clk_i = clk_ext & ~halt;
logic div;

always_ff @(posedge clk_i or negedge rst_n) begin
   if (!rst_n)
      div <= 1'b0;
   else
      div <= ~div;
end

assign clk_sys = div;
```

시뮬레이션하여 파형을 확인한다.

```bash
cd sim
xrun -f lab07_blank.f -input ../../shm.tcl
```

<p class="ref">💻 sysclk.sv</p>

---

## Step 2: TB — 정상 2분주

- Comment #1: 정상 2분주

```verilog
// Comment #1 : 정상 2분주
repeat(8) @(posedge clk_ext);
```

시뮬레이션하여 clk_sys가 clk_ext의 2분주인지 확인한다.

<p class="ref">💻 tb_sysclk.sv</p>

---

## Step 2: Expected Waveform

```
time  rst_n  halt  clk_sys
----  -----  ----  -------
   0      0     0     0       reset
 100      1     0     0
 200      1     0     1       #1
 300      1     0     0
 400      1     0     1
 500      1     0     0
 600      1     0     1
 700      1     0     0
 800      1     0     1
 900      1     0     0
```

---

## Step 3: TB — halt 시 클럭 정지

Comment #2를 추가하고 다시 시뮬레이션한다.

```verilog
// Comment #2 : halt 시 클럭 정지
   halt = 1;
repeat(4) @(posedge clk_ext);
```

<p class="ref">💻 tb_sysclk.sv</p>

---

## Step 3: Expected Waveform

```
time  rst_n  halt  clk_sys
----  -----  ----  -------
   0      0     0     0
 100      1     0     0
 200      1     0     1       #1
 ...
 900      1     0     0
1000      1     1     0       #2
1100      1     1     0
1200      1     1     0
1300      1     1     0
```

---

## Step 4: 완성품 복사

```bash
cd ..
cp sysclk.sv ../../../design/
```

---

## Step 5: Git Checkin

```bash
git status
git add sysclk.sv tb_sysclk.sv
git add ../../../design/sysclk.sv
git commit -m "lab07: sysclk 설계 완료"
```
