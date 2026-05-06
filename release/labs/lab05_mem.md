---
marp: true
theme: konyang
paginate: true
header: "Lab 05: Memory"
footer: "Copyright 2026. 건양대학교 국방반도체공학과. All rights reserved"
---

<!-- _class: title -->
<!-- _header: "" -->
<!-- _footer: "" -->
<!-- _paginate: false -->

# MicroCPU 설계 실무

Lab 05: Memory

<br><br><br><br><br><br>
건양대학교 국방반도체공학과<br>백종섭 교수

---

## Step 1: 설계 — mem.sv

`mem_blank.sv`를 열고 Comment #1 영역에 RTL을 작성한다.

```verilog
// Comment #1 : 동기 메모리 모듈
logic [15:0] memory [0:255];

always @(posedge clk) begin
   if (write && !read)
      memory[addr] <= data_in;
end

always_ff @(posedge clk) begin
   if (read && !write)
      data_out <= memory[addr];
end
```

<p class="ref">💻 mem.sv</p>

---

## Step 2: TB — 쓰기 후 읽기

`tb_mem_blank.sv`를 열고 Comment #1, #2를 작성한다.

<div class="columns">
<div>

- Comment #1: write_mem/read_mem task

```verilog
// Comment #1 : write_mem/read_mem task
task write_mem(input logic [7:0] a,
   input logic [15:0] d);
      write   = 1;
      read    = 0;
      addr    = a;
      data_in = d;
   @(posedge clk);
endtask

task read_mem(input logic [7:0] a);
      write = 0;
      read  = 1;
      addr  = a;
   @(posedge clk);
endtask
```

</div>
<div>

- Comment #2: 쓰기 후 읽기 검증

```verilog
// Comment #2 : 쓰기 후 읽기 검증
write_mem(8'h00, 16'hAAAA);
write_mem(8'h01, 16'hBBBB);
write_mem(8'h02, 16'hCCCC);
read_mem(8'h00);
read_mem(8'h01);
read_mem(8'h02);
```

<p class="ref">💻 tb_mem.sv</p>

</div>
</div>

---

## Step 3: 시뮬레이션

- 시뮬레이션하여 파형을 확인한다.

```bash
cd sim
xrun -f lab05_blank.f -input ../../shm.tcl
```

Expected Waveform:

```
time  write  read  addr  data_in  data_out
----  -----  ----  ----  -------  --------
   0      0     0    00     0000      xxxx
 100      1     0    00     AAAA      xxxx    #2
 200      1     0    01     BBBB      xxxx
 300      1     0    02     CCCC      xxxx
 400      0     1    00     --        xxxx
 500      0     1    01     --        AAAA
 600      0     1    02     --        BBBB
```

---

## Step 4: TB — 읽기/쓰기 동시

Comment #3, #4를 추가하고 다시 시뮬레이션한다.

<div class="columns">
<div>

- Comment #3: rw_mem task

```verilog
// Comment #3 : rw_mem task
task rw_mem(input logic [7:0] a,
   input logic [15:0] d);
      write   = 1;
      read    = 1;
      addr    = a;
      data_in = d;
   @(posedge clk);
endtask
```

</div>
<div>

- Comment #4: 읽기/쓰기 동시 — 무시

```verilog
// Comment #4 : 읽기/쓰기 동시 — 무시
rw_mem(8'h00, 16'hFFFF);
read_mem(8'h00);
```

<p class="ref">💻 tb_mem.sv</p>

</div>
</div>

---

## Step 5: 시뮬레이션

- 시뮬레이션하여 파형을 확인한다.

```bash
cd sim
xrun -f lab05_blank.f -input ../../shm.tcl
```

Expected Waveform:

```
time  write  read  addr  data_in  data_out
----  -----  ----  ----  -------  --------
   0      0     0    00     0000      xxxx
 100      1     0    00     AAAA      xxxx    #2
 200      1     0    01     BBBB      xxxx
 300      1     0    02     CCCC      xxxx
 400      0     1    00     --        xxxx
 500      0     1    01     --        AAAA
 600      0     1    02     --        BBBB
 700      1     1    00     FFFF      CCCC    #4
 800      0     1    00     --        --
 900      --    --   --     --        AAAA
```

---

## Step 6: 완성품 복사

```bash
cd ..
cp mem.sv ../../design/
```

---

## Step 7: Git Checkin

```bash
git status
git add mem.sv tb_mem.sv
git add ../../design/mem.sv
git commit -m "lab05: mem 설계 완료"
```
