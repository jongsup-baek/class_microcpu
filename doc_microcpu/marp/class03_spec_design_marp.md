---
marp: true
theme: konyang
paginate: true
header: "Class 03: MicroCPU 블럭 설계"
footer: "Copyright 2026. 건양대학교 국방반도체공학과. All rights reserved"
---

<!-- _class: title -->
<!-- _header: "" -->
<!-- _footer: "" -->
<!-- _paginate: false -->

# MicroCPU 설계 실무

Class 03: MicroCPU 블럭 설계

<br><br><br><br><br><br>
건양대학교 국방반도체공학과<br>백종섭 교수

---

## 학습 목표

- cpu_pkg 패키지의 enum 타입 정의를 이해한다
- 각 블럭의 포트, 동작, 구현 코드를 분석할 수 있다
- sysclk의 clock gating + 2분주 구조를 이해한다
- Controller FSM의 opcode 디코딩과 제어 신호 생성을 이해한다
- 각 블럭을 SystemVerilog로 구현할 수 있다

---

## 3.1 cpu_pkg 패키지

> 전체 블럭이 공유하는 타입 정의. opcode와 FSM 상태를 enum으로 선언하여 가독성과 안전성을 확보한다

<div class="columns">
<div>

- 패키지로 타입을 공유하여 모듈 간 일관성을 보장한다
- enum은 숫자 대신 이름으로 코딩하여 가독성과 안전성을 높인다
- `import cpu_pkg::*;`로 모든 모듈에서 사용
- opcode_t: 3비트
  - 8개 명령어를 기능별 그룹으로 인코딩
- state_t: 3비트
  - 8개 FSM 상태를 Fetch/Execute 2-phase로 구분

</div>
<div>

```verilog
package cpu_pkg;

  typedef enum logic [2:0] {
     WFR,            // Control
     BRZ, BRA,       // Branch
     LDA, STA,       // Data Move
     ADD, AND, NOT   // ALU
  } opcode_t;

  typedef enum logic [2:0] {
     INST_ADDR,    // S0 Fetch
     INST_FETCH,   // S1
     INST_LOAD,    // S2
     IDLE,         // S3
     OP_ADDR,      // S4 Execute
     OP_FETCH,     // S5
     OP_ALU,       // S6
     UPDATE        // S7
  } state_t;

endpackage : cpu_pkg
```

</div>
</div>

---

## 3.2 sysclk 블럭

<style scoped>
table { width: 100%; }
td:nth-child(5) { width: 65%; }
</style>

> clock gating + 2분주. halt=1이면 clk_sys가 정지하며, rst_n으로만 해제된다

| Port | Dir | Width | From | Description |
| --- | :---: | :---: | --- | --- |
| clk_ext | in | 1 | 외부 핀 | 시스템 클럭. rising edge active |
| rst_n | in | 1 | 외부 핀 | 비동기 리셋. low이면 div를 0으로 초기화 |
| halt | in | 1 | Controller | halt. 1이면 clk_i=0으로 고정되어 clk_sys가 정지한다 |
| clk_sys | out | 1 | | clk_ext를 2분주한 내부 클럭. 모든 순차 블럭의 동작 기준 |

```verilog
wire clk_i = clk_ext & ~halt;

always_ff @(posedge clk_i or negedge rst_n)
   if (!rst_n)  div <= 1'b0;
   else         div <= ~div;

assign clk_sys = div;
```

---

## 3.3 mem 블럭

> 256x16 동기 메모리. read와 write는 동시에 high가 되지 않는다

<div class="columns">
<div>

| Port | Dir | Width | From | Description |
| --- | :---: | :---: | --- | --- |
| clk | in | 1 | sysclk | 시스템 클럭 |
| read | in | 1 | Controller | mem_rd |
| write | in | 1 | Controller | mem_wr |
| addr | in | 8 | addr_mux | 메모리 주소 |
| data_in | in | 16 | ALU | 쓰기 데이터 |
| data_out | out | 16 | | 읽기 데이터 |

</div>
<div>

```verilog
logic [15:0] memory [0:255];

// Write
always @(posedge clk)
   if (write && !read)
      memory[addr] <= data_in;

// Read
always_ff @(posedge clk)
   if (read && !write)
      data_out <= memory[addr];
```

</div>
</div>

---

## 3.4 Controller 모듈 동작

> 8-상태 FSM이 opcode와 zero를 입력받아 9개 제어 신호를 생성한다

<div class="columns">
<div>

| Port | Dir | Width | From | Description |
| --- | :---: | :---: | --- | --- |
| clk | in | 1 | sysclk | 시스템 클럭 |
| rst_n | in | 1 | 외부 핀 | 비동기 active-low 리셋 |
| ir_opcode | in | 3 | IR | 명령어의 opcode |
| zero | in | 1 | ALU | ALU zero 플래그 |
| fetch_phase | out | 1 | | Fetch/Execute phase 표시 |
| mem_rd | out | 1 | | MEM 읽기 enable |
| mem_wr | out | 1 | | MEM 쓰기 enable |
| ir_load | out | 1 | | IR 래치 enable |
| load_reg | out | 1 | | regfile 쓰기 enable |
| inc_pc | out | 1 | | PC 증가 enable |
| load_pc | out | 1 | | PC 분기 주소 로드 enable |
| halt | out | 1 | | WFR 시 1로 래치 |


</div>
<div>

```verilog
// 1. opcode decode (조합)
assign is_op_memrd = (ir_opcode inside {ADD, AND, LDA});
assign is_not = (ir_opcode == NOT);
assign is_wfr = (ir_opcode == WFR);
assign is_brz = (ir_opcode == BRZ);
assign is_bra = (ir_opcode == BRA);
assign is_sta = (ir_opcode == STA);

// 2. state FF
always_ff @(posedge clk or negedge rst_n)
   if (!rst_n)      state <= INST_ADDR;
   else if (!halt)  state <= state.next();

// 3. 출력 FF — next-state 기반
always_ff @(posedge clk or negedge rst_n)
   if (!rst_n) begin /* 초기화 */ end
   else if (!halt) begin
      fetch_phase <= ...;  // next-state 기반
      case (state.next())
         // Fetch: 
         //    mem_rd, ir_load (고정)
         // Execute:
         //    inc_pc, halt(is_wfr)
         //    mem_rd(is_op_memrd), mem_wr(is_sta)
         //    load_reg(is_op_memrd|is_not)
         //    inc_pc(is_brz&&zero), load_pc(is_bra)
      endcase
   end
```

</div>
</div>

---

## 3.5 IR 모듈 동작

> 16-bit Instruction Register. 메모리에서 읽은 명령어를 5개 필드로 분리하여 개별 FF에 래치한다

<div class="columns">
<div>

| Port | Dir | Width | From | Description |
| --- | :---: | :---: | --- | --- |
| clk | in | 1 | sysclk | 시스템 클럭 |
| rst_n | in | 1 | 외부 핀 | 비동기 리셋 |
| enable | in | 1 | Controller | ir_load |
| din | in | 16 | MEM | 래치할 데이터 |
| ir_opcode | out | 3 | | din[15:13] 연산 코드. 리셋 시 WFR |
| ir_mode | out | 1 | | din[12] 주소 지정 방식 |
| ir_rd | out | 2 | | din[11:10] 목적 레지스터 |
| ir_rs | out | 2 | | din[9:8] 소스 레지스터 |
| ir_data | out | 8 | | din[7:0] 주소 |

</div>
<div>

```verilog
always_ff @(posedge clk or negedge rst_n)
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
```

</div>
</div>

---

## 3.6 Register File 모듈 동작

> 4x16-bit 레지스터 파일(R0~R3). 읽기는 조합, 쓰기는 동기

<div class="columns">
<div>

| Port | Dir | Width | From | Description |
| --- | :---: | :---: | --- | --- |
| clk | in | 1 | sysclk | 시스템 클럭 |
| rst_n | in | 1 | 외부 핀 | 비동기 리셋 |
| rd_addr | in | 2 | IR | Rd 읽기 주소 |
| rs_addr | in | 2 | IR | Rs 읽기 주소 |
| wr_data | in | 16 | ALU | 쓰기 데이터 |
| wr_addr | in | 2 | IR | 쓰기 주소 |
| wr_en | in | 1 | Controller | load_reg |
| rd_data | out | 16 | | regs[rd_addr] 조합 출력 |
| rs_data | out | 16 | | regs[rs_addr] 조합 출력 |

</div>
<div>

```verilog
logic [15:0] regs [0:3];

// Synchronous write
always_ff @(posedge clk, negedge rst_n)
   if (!rst_n) begin
      regs[0] <= '0;
      regs[1] <= '0;
      regs[2] <= '0;
      regs[3] <= '0;
   end
   else if (wr_en)
      regs[wr_addr] <= wr_data;

// Combinational read
assign rd_data = regs[rd_addr];
assign rs_data = regs[rs_addr];
```

</div>
</div>

---

## 3.7 op_mux 모듈 동작

> 파라미터화된 2:1 MUX. sel_a에 따라 두 입력 중 하나를 선택하여 출력한다. 조합 로직

<div class="columns">
<div>

| Port | Dir | Width | From | Description |
| --- | :---: | :---: | --- | --- |
| din_a | in | 16 | MEM | 첫 번째 입력 |
| din_b | in | 16 | regfile | 두 번째 입력 |
| sel_a | in | 1 | IR | 1이면 din_a, 0이면 din_b 선택 |
| dout | out | 16 | | 선택된 출력 |

</div>
<div>

```verilog
// mux2to1 #(16)
assign dout = sel_a ? din_a : din_b;
```

</div>
</div>

---

## 3.8 PC 모듈 동작

> 8-bit 카운터. load 시 din 값을 로드하고, enable 시 +1 증가한다. load가 enable보다 우선한다

<div class="columns">
<div>

| Port | Dir | Width | From | Description |
| --- | :---: | :---: | --- | --- |
| clk | in | 1 | sysclk | 시스템 클럭 |
| rst_n | in | 1 | 외부 핀 | 비동기 리셋 |
| load | in | 1 | Controller | load_pc. 1이면 pc_count = din. load와 enable이 동시에 1이면 load가 우선한다 |
| enable | in | 1 | Controller | inc_pc. 1이면 pc_count += 1. load=0일 때만 동작한다 |
| din | in | 8 | IR | load 시 로드할 값 |
| pc_count | out | 8 | | 현재 카운터 값. rst_n이면 0x00 |

</div>
<div>

```verilog
always_ff @(posedge clk, negedge rst_n)
   if (!rst_n)       pc_count <= '0;
   else if (load)    pc_count <= din;
   else if (enable)  pc_count <= pc_count + 1;
```

</div>
</div>

---

## 3.9 addr_mux 모듈 동작

> 파라미터화된 2:1 MUX. sel_a에 따라 두 입력 중 하나를 선택하여 출력한다. 조합 로직

<div class="columns">
<div>

| Port | Dir | Width | From | Description |
| --- | :---: | :---: | --- | --- |
| din_a | in | 8 | PC | 첫 번째 입력. sel_a=1이면 선택 |
| din_b | in | 8 | IR | 두 번째 입력. sel_a=0이면 선택 |
| sel_a | in | 1 | Controller | 1이면 din_a, 0이면 din_b 선택 |
| dout | out | 8 | | 선택된 출력 |

</div>
<div>

```verilog
// mux2to1 #(8)
assign dout = sel_a ? din_a : din_b;
```

</div>
</div>

---

## 3.10 ALU 모듈 동작

> 16-bit 조합 논리 연산기. 입력이 바뀌면 즉시 출력이 바뀐다

<div class="columns">
<div>

| Port | Dir | Width | From | Description |
| --- | :---: | :---: | --- | --- |
| accum | in | 16 | regfile | 첫 번째 피연산자 |
| din | in | 16 | op_mux | 두 번째 피연산자 |
| opcode | in | 3 | IR | 연산 종류 선택 |
| dout | out | 16 | | 연산 결과 |
| zero | out | 1 | | ~(\|dout). 연산 결과가 0이면 1 |

</div>
<div>

```verilog
always_comb
   unique case (opcode)
      ADD : dout = accum + din;
      AND : dout = accum & din;
      NOT : dout = ~accum;
      LDA : dout = din;
      default : dout = accum;
   endcase

assign zero = ~(|dout);
```

</div>
</div>

---

## 복습

- cpu_pkg는 opcode_t와 state_t 두 enum을 정의한다. 모든 모듈이 import하여 타입을 공유한다
- sysclk은 clk_ext를 2분주하여 clk_sys를 생성한다. halt=1이면 clock gating으로 전체 클럭이 정지한다
- mem은 256x16 동기 메모리이다. read와 write는 동시에 활성화되지 않으며, posedge clk에서 동작한다
- Controller는 8-상태 Moore FSM이다. 모든 출력이 FF에 등록되며, next-state 기반으로 미리 계산하여 글리치 없이 동작한다
- IR은 16비트 명령어를 래치하고 opcode, mode, rd, rs, data 5개 필드로 디코딩한다
- regfile은 4x16비트 레지스터 파일이다. 읽기는 조합 로직으로 즉시 출력되고, 쓰기는 clk posedge에서 동기 동작한다
- op_mux와 addr_mux는 동일한 mux2to1 모듈의 인스턴스이다. 삼항 연산자로 구현된 조합 로직이다
- PC는 8비트 카운터이다. load가 enable보다 우선하며, 리셋 시 0x00으로 초기화된다
- ALU는 조합 논리 연산기이다. ADD, AND, NOT, LDA 4개 연산을 수행하며, 나머지 opcode는 accum을 패스스루한다

---

## Thank You

🔖 3.1 cpu_pkg 패키지
🔖 3.2 sysclk 블럭
🔖 3.3 mem 블럭
🔖 3.4 Controller 모듈 동작
🔖 3.5 IR 모듈 동작
🔖 3.6 Register File 모듈 동작
🔖 3.7 op_mux 모듈 동작
🔖 3.8 PC 모듈 동작
🔖 3.9 addr_mux 모듈 동작
🔖 3.10 ALU 모듈 동작
