# AMBA AHB-Lite Master–Slave Interconnect (RTL)

## Overview
This repository holds a Register-Transfer-Level implementation built entirely around the ARM AMBA AHB-Lite (Advanced High-performance Bus, Lite) specification. The design targets low-latency, high-throughput on-chip data movement and is written to support pipelined transfers so that back-to-back operations can complete at a steady rate of one transfer per clock once the pipeline is full.

Repository: https://github.com/FarazIsmail/AMBA-AHB-protocols

## How the Protocol Is Modeled

```mermaid
sequenceDiagram
    participant M as AHB Master
    participant S as AHB Slave
    Note right of M: Address phase (overlapped with the previous transfer's data phase)
    M->>S: Drives HADDR, HWRITE, HSIZE, HTRANS
    Note right of M: Data phase
    M->>S: Drives HWDATA (write transfers)
    S-->>M: Asserts HREADY (or holds low to insert wait states)
    S->>M: Returns HRDATA (read transfers)
```

Because the address of the next transfer is driven while the data of the current transfer is still being resolved, the bus keeps both phases in flight simultaneously — this overlap is what gives AHB-Lite its pipelined throughput advantage over a strictly sequential bus.

## Highlights

- **Pipelined address/data phases** — the next address is issued while the current data phase is still in progress, so steady-state throughput approaches one transfer per clock cycle.
- **Zero-wait-state path** — reads and writes can retire in a single cycle when the addressed slave is ready immediately.
- **Configurable wait-state insertion** — any slave can hold `HREADY` low for as many cycles as it needs, stalling the pipeline until it can service the request without corrupting in-flight transfers.
- **Centralized address decode and response multiplexing** — a shared decoder/mux block routes each master-driven address to the correct slave and steers the corresponding `HRDATA`/`HREADY`/`HRESP` back to the master.

## Verification Environment
The included testbenches drive the interconnect through directed scenarios that check both control-path correctness (address decoding, response routing) and data-path correctness (write/read data integrity), including how the design behaves when an access targets no valid slave.

Scenarios covered:

| # | Scenario | Purpose |
|---|----------|---------|
| 1 | Single write, zero wait states | Confirms baseline single-cycle write completion |
| 2 | Single read, zero wait states | Confirms baseline single-cycle read completion |
| 3 | Write with inserted wait states | Confirms the pipeline stalls and resumes correctly when a slave delays `HREADY` |
| 4 | INCR4 burst (4 beats) | Confirms address incrementing and sustained throughput across a burst |
| 5 | Access to an invalid/unmapped address | Confirms the interconnect returns an error response instead of a false completion |

## Waveform Captures

### `AHB_tb` runs
![Waveform 1](assets/waveform_tc1.png)
![Waveform 2](assets/waveform_tc2.png)
![Waveform 3](assets/waveform_tc3.png)

### `tb_AHB` runs
![Waveform 4](assets/waveform_tc4.png)
![Waveform 5](assets/waveform_tc5.png)
![Waveform 6](assets/waveform_tc6.png)
![Waveform 7](assets/waveform_tc7.png)
![Waveform 8](assets/waveform_tc8.png)
