---
marp: true
theme: konyang
paginate: true
header: "Class 01: MicroCPU 스펙"
footer: "Copyright 2026. 건양대학교 국방반도체공학과. All rights reserved"
---

<!-- _class: title -->
<!-- _header: "" -->
<!-- _footer: "" -->
<!-- _paginate: false -->

# MicroCPU 설계 실무

Class 01: MicroCPU 스펙

<br><br><br><br><br><br>
건양대학교 국방반도체공학과<br>백종섭 교수

---

## 학습 목표

- MicroCPU의 전체 아키텍처와 설계 특징을 이해한다
- 16비트 명령어 구조와 mode 비트의 역할을 이해한다
- 8개 명령어(ISA)의 동작을 설명할 수 있다
- 외부 인터페이스(핀 스펙)를 이해한다
- 내부 블럭 구성과 데이터 경로를 파악한다
- 8-상태 FSM 기반 명령어 실행 흐름을 추적할 수 있다
- 각 블럭의 입출력 신호와 타이밍 관계를 분석할 수 있다

---

## 1.1 MicroCPU 아키텍처

> MicroCPU는 16비트 명령어와 16비트 데이터를 사용하는 16비트 프로세서이다

| 항목 | 스펙 | 설명 |
| --- | --- | --- |
| 워드 폭 | 16비트 | 메모리, 명령어, 레지스터, ALU 모두 16비트이다.<br>폰 노이만 구조이므로 명령어와 데이터가 같은 폭을 공유한다. |
| 명령어 구조 | 5필드, 16비트 | opcode(3b) + mode(1b) + rd(2b) + rs(2b) + data(8b).<br>하나의 명령어 안에 연산, 주소 지정 방식, 레지스터 2개, 메모리 주소를 모두 인코딩한다. |
| 메모리 구조 | 폰 노이만 | 명령어와 데이터가 동일한 256×16 메모리를 공유한다. |
| 레지스터 | 4×16비트 (R0~R3)<br>2R + 1W 포트 | Rd가 연산의 첫 번째 입력이자 결과 저장 대상이다.<br>4개의 값을 레지스터에 동시에 유지할 수 있다. |
| 명령어 세트 | 3비트 opcode, 8개 | 제어(WFR), 분기(BRZ, BRA), 데이터 이동(LDA, STA), 산술/논리(ADD, AND, NOT). |
| 주소 지정 | Direct, Register | `op_memrd`(ADD, AND, LDA)만 mode 비트로 Direct/Register를 전환한다.<br>나머지 명령어는 mode에 무관하다.<br>Immediate, Indirect, Indexed는 지원하지 않는다. |
| 클럭 | 단일 clk_sys | clk_ext를 2분주. halt 시 clock gating으로 정지. |
| 실행 구조 | 8 clk_sys/명령어<br>Fetch + Execute 2-phase | **Fetch**(S0~S3): 명령어를 읽어 IR에 저장하고 디코딩한다.<br>**Execute**(S4~S7): 피연산자 접근 + 연산 + 결과 저장. |

---

## 1.2 MicroCPU 명령어 구조

> 16비트 명령어 안에 mode 비트 하나를 두어, 메모리 모드와 레지스터 모드를 전환한다

![MicroCPU Instruction Format](../images/microcpu_inst_format.svg)

| 필드 | 비트 | 이름 | 설명 |
| --- | --- | --- | --- |
| opcode | [15:13] | 연산 코드<br>(Operation Code) | 8개 명령어를 인코딩한다. |
| mode | [12] | 주소 지정 방식<br>(Addressing Mode) | op_mux의 sel 입력을 제어한다.<br>**mode=0 (메모리 모드)**: data[7:0]을 메모리 주소로 사용하여 mem[data]를 ALU에 전달한다.<br>**mode=1 (레지스터 모드)**: rs가 지정한 레지스터 값을 ALU에 전달한다. |
| rd | [11:10] | 목적 레지스터<br>(Destination Register) | R0(00), R1(01), R2(10), R3(11).<br>ALU 연산의 첫 번째 입력이자 결과 저장 대상이다. |
| rs | [9:8] | 소스 레지스터<br>(Source Register) | mode=1일 때 ALU의 두 번째 입력으로 사용된다.<br>mode=0일 때는 무시된다. |
| data | [7:0] | 주소<br>(Address) | 8비트 주소 필드. `op_memrd`의 Direct 모드에서 메모리 주소로 사용된다.<br>Register 모드에서는 사용되지 않는다. |

---

## 1.3 MicroCPU 명령어 세트 (ISA: Instruction Set Architecture)

> 3비트 opcode로 8개 명령어를 정의하며, mode 비트에 따라 피연산자 소스가 달라진다

| 그룹 | Opcode | 이름 | 인코딩 | Direct 모드 | Register 모드 | Note |
| --- | --- | --- | --- | --- | --- | --- |
| **제어** | WFR | Wait For Reset | 000 | 프로세서 정지 | <span class="rtl">프로세서 정지</span> | clock gating으로 전체 정지. rst_n으로만 해제 |
| **분기** | BRZ | Branch if Zero | 001 | Rd=0이면 PC += 1 | <span class="rtl">Rd=0이면 PC += 1</span> | 유일한 조건 분기. Rd가 0이면 다음 명령어를 건너뛴다 |
| | BRA | Branch Always | 010 | PC = data | <span class="rtl">PC = data</span> | 무조건 분기. data[7:0]을 PC에 로드 |
| **데이터 이동** | LDA | Load | 011 | Rd = mem[data] | Rd = Rs | Register 모드에서는 레지스터 간 복사 |
| | STA | Store | 100 | mem[data] = Rd | <span class="rtl">mem[data] = Rd</span> | Rd 값을 메모리에 저장 |
| **산술/논리** | ADD | Add | 101 | Rd = Rd + mem[data] | Rd = Rd + Rs | 2's complement 덧셈 |
| | AND | And | 110 | Rd = Rd & mem[data] | Rd = Rd & Rs | 비트 단위 논리곱 |
| | NOT | Not | 111 | Rd = ~Rd | <span class="rtl">Rd = ~Rd</span> | 단항 연산. 메모리 읽기 불필요 |

- `op_memrd` (ADD, AND, LDA): mode 구분이 있다. Direct/Register에 따라 피연산자 소스가 달라진다
- `!op_memrd` (WFR, BRZ, BRA, STA, NOT): mode에 무관하다

---

## 1.4 제어 흐름 프로그래밍

> BRZ(조건 skip)와 BRA(무조건 분기) 2개 명령어로 모든 제어 흐름을 구현한다

<div class="columns">
<div>

**if-then**
BRZ가 유일한 조건 분기 수단이다. Rd=0이면 다음 명령어 1개를 건너뛴다.

**if-else**
BRZ로 skip 후 BRA로 ELSE로 점프한다. THEN 끝에 BRA END로 합류한다.
```c
if (R0 == 0) R1 = mem[0x80];
else         R1 = mem[0x81];
```
```
// 주소 0x10부터 if-else 시작되는 예제 코드
0x10  BRZ R0           // R0=0? → 0x12(THEN)
0x11  BRA 0x15         // R0≠0  → 0x15(ELSE)
0x12  LDA R1, mem[0x80]// THEN: R1 = mem[0x80]
0x13  BRA 0x16         // → 0x16(END)
0x14  WFR              // 미도달
0x15  LDA R1, mem[0x81]// ELSE: R1 = mem[0x81]
0x16  ...              // END
```
</div>
<div>



**while 루프**
BRZ로 탈출 조건을 검사하고, BRA로 루프 시작으로 되돌아간다. 카운터 감소는 ADD + 상수(-1)로 구현한다.
```c
while (R0 != 0) R0 -= 1;
```
```
// 0x10부터 while 루프 시작
0x10  BRZ R0           // R0=0? → 0x12(탈출)
0x11  BRA 0x14         // R0≠0  → 0x14(DONE)
0x12  ADD R0, mem[0x82]// R0 = R0 + (-1)
0x13  BRA 0x10         // → 0x10(반복)
0x14  WFR              // DONE
```

</div>
</div>

---

## 1.5 산술/논리 프로그래밍

> 상수 테이블과 NOT+ADD 조합으로 뺄셈을 포함한 모든 산술 연산을 수행한다

<div class="columns">
<div>

**상수 테이블**
Immediate 모드가 없으므로 자주 쓰는 값(0, 1, -1 등)을 메모리 데이터 영역에 미리 저장한다.

**뺄셈 (A - B)**
NOT으로 ~B를 만들고 ADD 1로 -B(2's complement)를 완성한다. 이후 ADD로 A + (-B).

**감소 (R0 -= 1)**
상수 -1(0xFFFF)을 메모리에 저장해두고 ADD 한 줄로 감소한다.

**AND 마스킹**
원하는 비트 위치에 1을 둔 마스크를 AND하여 특정 비트만 추출한다.

</div>
<div>

```
// 상수 테이블
@80
0000000000000001   // 0x81: 상수 1
1111111111111111   // 0x82: 상수 -1

// 뺄셈 (A - B)
   NOT R1           // ~B
   ADD R1, mem[1]   // ~B + 1 = -B
   ADD R0, R1       // A + (-B)

// 감소
   ADD R0, mem[-1]  // R0 - 1

// AND 마스킹
   AND R0, mem[mask] // 비트 추출
```

</div>
</div>

---

## 1.6 MicroCPU 핀 스펙

> cpu_top 모듈은 4개 핀만 외부에 노출하며, 내부의 모든 클럭과 데이터 경로는 외부에서 보이지 않는다

| Pin Name | Type | Width | Description |
| --- | --- | --- | --- |
| clk_ext | Input | 1 | System clock. Rising edge active.<br>sysclk에서 2분주되어 내부 클럭(clk_sys)을 생성한다. |
| rst_n | Input | 1 | Active-low asynchronous reset.<br>Low 입력 시 클럭과 무관하게 모든 내부 레지스터를 0으로 클리어하고, FSM을 초기 상태로 복귀시킨다. |
| halt | Output | 1 | Processor halt indicator. Active-high.<br>WFR 명령어(opcode 000) 실행 시 high가 되며, 리셋 전까지 유지된다.<br>halt=1이면 clock gating으로 내부 클럭이 정지한다. |
| ir_load | Output | 1 | Instruction fetch observation signal. Active-high.<br>매 fetch 단계에서 1사이클 동안 high가 된다. 실행된 명령어 수를 측정하거나 명령어 경계를 식별하는 데 사용한다. |

---

## 1.7 MicroCPU 블럭 다이어그램

> cpu_top 내부의 블럭 구성과 데이터 경로. sysclk, cpu_core, MEM 3개 블럭으로 나뉜다

![MicroCPU Block Diagram](../images/microcpu_block.drawio.svg)

---

## 1.8 MicroCPU 내부 신호

<style scoped>
td, th { padding-left: 6px; padding-right: 6px; }
</style>

> 블럭 간 연결 신호의 이름, 폭, 방향을 정리한다

| Signal | Width | From | To | Description |
| --- | --- | --- | --- | --- |
| pc_addr | 8 | PC | addr_mux | 현재 명령어의 메모리 주소를 전달한다. |
| ir_data | 8 | IR | addr_mux, PC | 피연산자 주소 또는 분기 주소를 전달한다. |
| addr | 8 | addr_mux | MEM | fetch/operand phase에 따라 선택된 메모리 주소를 전달한다. |
| data_out | 16 | MEM | IR, op_mux | 메모리에서 읽은 명령어 또는 피연산자 데이터를 전달한다. |
| ir_opcode | 3 | IR | Controller | 디코딩된 opcode를 Controller에 전달한다. |
| ir_mode | 1 | IR | op_mux | mode 비트로 Operand MUX의 입력을 선택한다. |
| ir_rd, ir_rs | 2, 2 | IR | Register File | 목적/소스 레지스터 주소를 전달한다. |
| rd_data | 16 | Register File | ALU | Rd 레지스터 값을 ALU의 첫 번째 입력(accum)으로 전달한다. |
| rs_data | 16 | Register File | op_mux | Rs 레지스터 값을 Operand MUX에 전달한다(mode=1). |
| alu_operand | 16 | op_mux | ALU | 선택된 피연산자를 ALU의 두 번째 입력(din)으로 전달한다. |
| alu_out | 16 | ALU | Register File, MEM | 연산 결과를 Rd에 저장하거나, STA 시 메모리에 기록한다. |
| zero | 1 | ALU | Controller | Rd가 0이면 high. BRZ 분기 판단에 사용한다. |

---

## 1.9 MicroCPU 명령어 실행 — 데이터 흐름

<style scoped>
table { width: 100%; }
td, th { padding: 6px 12px; }
td:nth-child(6) { width: 55%; }
</style>

> 하나의 명령어는 8개 FSM 상태를 순차적으로 거쳐 실행된다. 8 clk_sys = 1 명령어 주기

| FSM | 이름 | fetch | From | To | 설명 | 신호 |
| :---: | :---: | :---: | :---: | :---: | --- | :---: |
| S0 | <span class="ltr">INST_ADDR</span> | 1 | PC | addr_mux | PC 주소를 addr_mux에 전달한다 | |
| S1 | <span class="ltr">INST_FETCH</span> | 1 | addr_mux | MEM | PC 주소로 MEM 읽기 시작 | mem_rd(1) |
| S2 | <span class="ltr">INST_LOAD</span> | 1 | MEM | IR | 16비트 명령어를 IR에 래치 | mem_rd(1)<br>ir_load(1) |
| S3 | <span class="ltr">IDLE</span> | 1 | IR | — | 명령어를 5개 필드로 디코딩 | mem_rd(1)<br>ir_load(1) |
| S4 | <span class="rtl">OP_ADDR</span> | 0 | IR | addr_mux | fetch_phase=0으로 전환. addr_mux가 ir_data[7:0]을 선택한다 | inc_pc(1)<br>halt(WFR) |
| S5 | <span class="rtl">OP_FETCH</span> | 0 | addr_mux | MEM | op_memrd이면 data[7:0] 주소의 MEM을 읽는다. 그 외이면 읽지 않는다 | mem_rd(op_memrd) |
| S6 | <span class="rtl">OP_ALU</span> | 0 | regfile<br>op_mux | ALU | op_memrd: mode에 따라 연산 수행. NOT: ~Rd. 결과가 ALU에 즉시 출력된다(조합). WFR/BRZ/BRA/STA: Controller가 직접 제어한다 | mem_rd(op_memrd)<br>load_reg(op_memrd\|NOT)<br>load_pc(BRA)<br>inc_pc(BRZ&zero) |
| S7 | <span class="rtl">UPDATE</span> | 0 | ALU<br>regfile | regfile<br>MEM | op_memrd: ALU 결과를 regfile에 저장. STA: regfile의 Rd 값을 MEM에 기록. WFR/BRZ/BRA: 갱신 없음 | load_reg(op_memrd)<br>mem_wr(STA) |

---

## 1.10 MicroCPU 명령어 실행 — 제어 신호

> Fetch phase의 제어 신호는 모든 명령어에서 동일하고, Execute phase의 제어 신호는 opcode에 따라 조건부로 활성화된다

![Control signals](../images/class01_1_8_ctrl_signal_wavedrom.svg)

---

## 복습

- 1.1: 16비트 프로세서. 폰 노이만, 4개 범용 레지스터, 단일 clk_sys
- 1.2: 16비트 명령어 = opcode(3) + mode(1) + rd(2) + rs(2) + data(8)
- 1.3: 8개 명령어. `op_memrd`(ADD, AND, LDA)만 mode 전환, 나머지는 mode 무관
- 1.4: BRZ+BRA로 if-else, while 루프 구현
- 1.5: 상수 테이블 + NOT+ADD로 뺄셈. AND 마스킹
- 1.6: cpu_top은 4핀(clk_ext, rst_n, halt, ir_load)만 외부에 노출
- 1.7~1.8: 9개 블럭이 단일 clk_sys로 연결
- 1.9: 8-상태 FSM(S0~S7), Fetch + Execute 2-phase, 8 clk_sys = 1 명령어
- 1.10: Controller가 8개 제어 신호를 생성. `op_memrd`와 `is_not`으로 분류

---

## Thank You

🔖 1.1 MicroCPU 아키텍처
🔖 1.2 MicroCPU 명령어 구조
🔖 1.3 MicroCPU 명령어 세트 (ISA)
🔖 1.4 제어 흐름 프로그래밍
🔖 1.5 산술/논리 프로그래밍
🔖 1.6 MicroCPU 핀 스펙
🔖 1.7 MicroCPU 블럭 다이어그램
🔖 1.8 MicroCPU 내부 신호
🔖 1.9 MicroCPU 명령어 실행 — 데이터 흐름
🔖 1.10 MicroCPU 명령어 실행 — 제어 신호
