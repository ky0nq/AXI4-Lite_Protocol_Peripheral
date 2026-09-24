# AXI4-Lite Protocol Peripheral

Basys3 FPGA 위 MicroBlaze SoC에 연결되는 **AXI4-Lite 커스텀 Peripheral IP 5종(GPIO / UART / Timer / I2C / SPI)** 을 직접 설계하고,
계층형 C 소프트웨어 스택과 Stopwatch 응용, GPIO IP에 대한 UVM 검증 환경까지 구축한 프로젝트입니다.

- 기간: 2026.06.22 ~ 2026.06.30 (온디바이스 AI 시스템반도체 설계 2기)
- 보드: Digilent Basys3 (Artix-7 XC7A35T), 100 MHz
- 툴: Vivado / Vitis (MicroBlaze), Xilinx xsim (UVM)

## System Architecture

```
MicroBlaze ──AXI Interconnect ──┬── gpio_v1_0  ×5  (GPIOA~E: 버튼 / FND / LED …)
                                ├── uart_v1_0      (TX/RX, interrupt)
                                ├── timer_v1_0     (PSC/ARR, 1 ms tick interrupt)
                                ├── I2C_v1_0       (I2C master → PCF8574T/HD44780 LCD)
                                ├── spi_master_v1_0(SPI master → 외부 보드 SPI slave)
                                └── axi_uartlite   (디버그 콘솔)
```

응용 예제인 **Stopwatch System**은 Timer 인터럽트(1 ms)로 시간을 카운트하고, FND와 I2C LCD에 표시하며,
버튼(Run/Stop, Clear)으로 제어하고 SPI로 다른 Basys3 보드에 값을 전송합니다.

## Repository Layout

```
.
├── Hardware_Vivado/
│   ├── ip_repo/                 # 직접 설계한 AXI4-Lite IP 5종 (Vivado IP packager 형식)
│   │   ├── gpio_1.0/
│   │   ├── uart_1.0/
│   │   ├── timer_1.0/
│   │   ├── I2C_1.0/
│   │   └── spi_master_1.0/
│   │       ├── hdl/             # RTL (*_v1_0.v : top, *_S00_AXI.v : AXI4-Lite slave + register)
│   │       ├── component.xml    # IP-XACT
│   │       ├── xgui/, bd/       # Vivado GUI / BD 스크립트
│   │       └── drivers/, example_designs/  # IP packager 생성물
│   ├── sources_1/bd/system/     # Block design (system.bd) + Xilinx IP 설정(*.xci)
│   ├── constrs_1/               # Basys3 제약 파일 (Basys-3-Master.xdc)
│   └── XSA/system_wrapper.xsa   # Vitis용 하드웨어 플랫폼 (export 결과)
├── vitis_workspace/             # MicroBlaze 소프트웨어 (계층형 구조)
│   ├── hal/                     # 레지스터 직접 접근 계층 (gpio, uart, timer, i2c, spi)
│   ├── driver/                  # 장치 드라이버 (button, fnd, lcd, led, spi)
│   ├── common/                  # delay, interrupt
│   ├── ap/                      # 응용 (stopwatch, spi)
│   └── main.c
├── UVM_GPIO_ip/                 # GPIO IP UVM 검증 환경
│   ├── rtl/                     # DUT (gpio_top.v, gpio_axi.v)
│   └── tb/                      # agent / driver / monitor / scoreboard / coverage / sequence / test
└── spi_slave_HW_code/           # SPI 통신 상대 보드용 SPI slave RTL + xdc
```

## Peripheral IP Register Map

모든 IP는 AXI4-Lite slave(32-bit, 4 word) 인터페이스를 가집니다.

| IP | 0x00 | 0x04 | 0x08 | 0x0C | 외부 포트 |
|---|---|---|---|---|---|
| **gpio** | CR (방향) | IDR (입력) | ODR (출력) | – | `io_port[7:0]` (inout) |
| **uart** | SR | TDR | RDR | CR | `tx`, `rx`, `intr` |
| **timer** | CR (bit0 EN, bit1 IE) | PSC | ARR | CNT | `intr` |
| **I2C** | CTRL | ADDR_DATA | RXDATA | STATUS | `scl`, `sda` (inout) |
| **spi_master** | SR | TDR | RDR | CR (CPOL/CPHA/div) | `sclk`, `mosi`, `miso`, `ss_n` |

소프트웨어에서는 각 레지스터 블록을 `typedef struct`로 매핑하고 `XPAR_*_BASEADDR`로 접근합니다
(`vitis_workspace/hal/*/*.h` 참고).

## Software Stack

```
ap/        Stopwatch, SPI 응용 로직
driver/    Button / FND / LCD(HD44780 via PCF8574T) / LED / SPI
hal/       AXI 레지스터 접근 (GPIO_WritePin, TMR_SetARR, UART_Transmit, …)
common/    delay, interrupt (AXI INTC 연동)
```

## Verification (UVM, GPIO IP)

`UVM_GPIO_ip/`에 AXI4-Lite 인터페이스 기반 UVM 환경을 구성했습니다.

- 구성: `axi4lite_if`, `axi_gpio_seq_item / sequence / driver / monitor / agent / env / scoreboard / coverage / test`
- 결과: **PASS 47 / FAIL 0**, functional coverage **86.64 %**

## How to Reproduce

**Hardware (Vivado)**
1. 새 프로젝트 생성(Basys3) → `Settings > IP > Repository`에 `Hardware_Vivado/ip_repo` 추가
2. `Hardware_Vivado/sources_1/bd/system/system.bd`를 Block Design으로 추가 → HDL wrapper 생성
3. `Hardware_Vivado/constrs_1/imports/OndeviceAI2/Basys-3-Master.xdc` 추가 → Generate Bitstream → Export Hardware(XSA)

**Software (Vitis)**
1. `Hardware_Vivado/XSA/system_wrapper.xsa`로 Platform 생성
2. Application 프로젝트 생성 후 `vitis_workspace/` 내용을 `src/`에 복사

**UVM Simulation (xsim)**
```
cd UVM_GPIO_ip
xvlog -sv -L uvm -i tb rtl/*.v tb/axi4lite_if.sv tb/axi_gpio_pkg.sv tb/tb_top.sv
xelab -L uvm tb_top -s sim
xsim sim -R
```
