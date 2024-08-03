# AHB2APB Bridge Design and Implementation Project
## Abstract
This report details the design and implementation of an AHB to APB bridge. The bridge facilitates communication between the high-performance AHB (Advanced High-performance Bus) and the low-power APB (Advanced Peripheral Bus). The design includes an AHB slave interface and an APB FSM controller, as well as a testbench for verifying the functionality of the bridge. This project covers the synthesis of the bridge and highlights the technical and non-technical learnings derived from it.

## 1. Introduction
The Advanced Microcontroller Bus Architecture (AMBA) is a widely adopted on-chip interconnect specification that provides a framework for designing SoCs. Among the various protocols in the AMBA suite, the AHB, APB, and AXI protocols are crucial for different performance and complexity requirements. This report focuses on the AHB to APB bridge, a critical component for connecting high-speed and low-speed devices within a system.

## 2. ARM AMBA
AMBA buses are designed to facilitate communication within SoCs. They include several protocols, each serving different purposes:

• AMBA AHB (Advanced High-performance Bus): Used for high-speed, high-bandwidth operations.

• AMBA APB (Advanced Peripheral Bus): Optimized for low-power, low-speed peripheral communication.

• AMBA AXI (Advanced eXtensible Interface): Supports high-performance, high-frequency system designs with flexible addressing and data capabilities.

#### Figure 1-1 Typical AMBA System: 

![image](https://github.com/user-attachments/assets/d9b22d71-8cd5-4b98-8e16-7982a92c4b3e)

### 2.1 AMBA AHB 
AMBA AHB is a bus interface suitable for high-performance synthesizable designs. It defines the interface between components, such as masters, interconnects, and slaves. 
 
AMBA AHB implements the features required for high-performance, high clock frequency systems including: 

•	Burst transfers. 

•	Single clock-edge operation. 

•	Non-tristate implementation. 

•	Wide data bus configurations, 64, 128, 256, 512, and 1024 bits. 

 
The most common AHB slaves are internal memory devices, external memory interfaces, and high-bandwidth peripherals. Although low-bandwidth peripherals can be included as AHB slaves, for system performance reasons, they typically reside on the AMBA Advanced Peripheral Bus (APB). Bridging between the higher performance AHB and APB is done using an AHB slave, known as an APB bridge. 

#### Figure 2-1 AHB block diagram: 

![image](https://github.com/user-attachments/assets/48af2314-20cc-42ad-9197-faa8af95f6d4)

Figure 2-1 shows a single master AHB system design with the AHB master and three AHB slaves. The bus interconnect logic consists of one address decoder and a slave-to-master multiplexor. The decoder monitors the address from the master so that the appropriate slave is selected and the multiplexor routes the corresponding slave output data back to the master. AHB also supports multimaster designs by the use of an interconnect component that provides arbitration and routing signals from different masters to the appropriate slaves. 

#### Figure 2-2 AHB master interface:

![image](https://github.com/user-attachments/assets/4714ff4e-a44e-40e3-b235-dfd88bc99e3c)

A master provides address and control information to initiate read and write operations. Figure 2-2 shows a master interface. 

#### Figure 2-3 AHB slave interface:

![image](https://github.com/user-attachments/assets/f9e39824-8c0f-4ee3-88e8-39039247e2da)

A slave responds to transfers initiated by masters in the system. The slave uses the HSELx select signal from the decoder to control when it responds to a bus transfer. 
The slave signals back to the master: 

•	The completion or extension of the bus transfer. 

•	The success or failure of the bus transfer. Figure 2-3 shows a slave interface. 

### 2.2 AMBA APB
The Advanced Peripheral Bus (APB) is part of the Advanced Microcontroller Bus 
Architecture (AMBA) protocol family. It defines a low-cost interface that is 
optimized for minimal power consumption and reduced interface complexity.
The APB protocol is not pipelined, use it to connect to low-bandwidth peripherals 
that do not require the high performance of the AXI protocol.
The APB protocol relates a signal transition to the rising edge of the clock, to 
simplify the integration of APB peripherals into any design flow. Every transfer 
takes at least two cycles.

The APB can interface with:

• AMBA Advanced High-performance Bus (AHB)

• AMBA Advanced High-performance Bus Lite (AHB-Lite)

• AMBA Advanced Extensible Interface (AXI)

• AMBA Advanced Extensible Interface Lite (AXI4-Lite)

You can use it to access the programmable control registers of peripheral devices.

## 3. AHB to APB Bridge
The AHB to APB bridge interface is an AHB slave. When accessed (in normal operation or system test) it initiates an access to the APB. APB accesses are of different duration (three HCLK cycles in the EASY for a read, and two cycles for a write). They also have their width fixed to one word, which means it is not possible to write only an 8-bit section of a 32-bit APB register. APB peripherals do not need a PCLK input as the APB access is timed with an enable signal generated by the AHB to APB bridge interface. This makes APB peripherals low power consumption parts, because they are only strobed when accessed. 

The AHB to APB bridge is an AHB slave, providing an interface between the high speed AHB and the low-power APB. Read and write transfers on the AHB are converted into equivalent transfers on the APB. As the APB is not pipelined, then wait states are added during transfers to and from the APB when the AHB is required to wait for the APB. 
 
It is required to bridge the communication gap between low bandwidth peripherals on APB with the high bandwidth ARM Processors and/or other high-speed devices on AHB. This ensures that there is no data loss between AHB to APB or APB to AHB data transfers. AHB2APB interfaces AHB and APB. It buffers address, controls and data from the AHB, drives the APB peripherals and return data along with response signal to the AHB. The AHB2APB interface is designed to operate when AHB and APB clocks have the any combination of frequency and phase. TheAHB2APB performs transfer of data from AHB to APB for write cycle and APB to AHB for Read cycle. Interface between AMBA high performance bus (AHB) and AMBA peripheral bus (APB). It provides latching of address, controls and data signals for APB peripherals. 

### 3.1 Architecture
#### Figure 3-1 AHB to APB Bridge block diagram: 

![image](https://github.com/user-attachments/assets/cfacd479-a206-459b-8af4-4b9b800c8a55)

The main sections of this module are: 

•	AHB slave bus interface 

•	APB transfer state machine, which is independent of the device memory map 

•	APB output signal generation. 

To add new APB peripherals, or alter the system memory map, only the address decode sections need to be modified. 
The base addresses of each of the peripherals (timer, interrupt controller, and remap and pause controller) are defined in the AHB to APB bridge interface, which selects the peripheral according to its base address. The whole APB address range is also defined in the bridge. 
These base addresses can be implementation-specific. The peripherals standard specifies only the register offsets (from an unspecified base address), register bit meaning, and minimum supported function 
The APB data bus is split into two separate directions: 

•	read (PRDATA), where data travels from the peripherals to the bridge.

•	write (PWDATA), where data travels from the bridge to the peripherals. 

This simplifies driving the buses because turnaround time between the peripherals and bridge is avoided. 
In the default system, because the bridge is the only master on the bus, PWDATA is driven continuously. PRDATA is a multiplexed connection of all peripheral PRDATA outputs on the bus, and is only driven when the slaves are selected by the bridge during APB read transfers. 
It is possible to combine these two buses into a single bidirectional bus, but precautions must be taken to ensure that there is no bus clash between the bridge and the peripherals. 

### 3.2 Bridge Module
#### Figure 3-2 Bridge module system diagram:

![image](https://github.com/user-attachments/assets/fa58cd1d-4a05-407c-a559-7cbc16efd5ec)

The AHB to APB bridge comprises a state machine, which is used to control the generation of the APB and AHB output signals, and the address decoding logic which is used to generate the APB peripheral select lines. 
All registers used in the system are clocked from the rising edge of the system clock HCLK, and use the asynchronous reset HRESETn. 

 ### 3.3 AHB to APB transfer state machine 
 #### Figure 3-3 APB transfer state Diagram:

 ![image](https://github.com/user-attachments/assets/0bfe73cc-b445-4f00-88ea-6873484e3e2d)

The transfer state machine is used to control the application of APB transfers based on the AHB inputs. The state diagram in Figure 3-3 shows the operation of the state machine, which is controlled by its current state and the AHB slave interface. 

## 4. Signal Description
#### Figure 4-1 AHB Signals:

![image](https://github.com/user-attachments/assets/835b91db-7cfd-4468-a3c0-3aeee43fb7a6)

#### Figure 4-2 APB Signals:

![image](https://github.com/user-attachments/assets/78ce40df-75e2-4e81-bed2-df90682facd0)

## 5. Implementation
### 5.1 Objective 
To design and simulate a synthesizable AHB to APB bridge interface using Verilog and run single read, single write burst read and burst write tests using AHB Master and APB Slave testbenches. The bridge unit converts system bus transfers into APB transfers and performs the following functions:

• Latches the address and holds it valid throughout the transfer.

• Decodes the address and generates a peripheral select, PSELx. Only one select signal can be active during a transfer.

• Drives the data onto the APB for a write transfer.

• Drives the APB data onto the system bus for a read transfer.

• Generates a timing strobe, PENABLE, for the transfer.

• Can implement single read and write operations successfully.

### 5.2 Tools Used
• HDL Used: Verilog

• Simulator Tool Used: ModelSIM - Intel FPGA

• Synthesis Tool Used: Quartus Prime

• Family: MAX V

• Device: 5M2210ZF324I5

### 5.3 Simulation Results
The below figures shows all four basic transfers as Follows:
#### Figure 5-1 Single Read Transfer:
<img width="939" alt="Single_Read" src="https://github.com/user-attachments/assets/7f835e20-ceca-4b18-9cb8-89786172ad03">

#### Figure 5-2 Single Write Transfer:
<img width="939" alt="Single_Write" src="https://github.com/user-attachments/assets/6dc55fb4-236b-43b0-8ff5-fb3629655c14">

#### Figure 5-3 Burst Read Transfer:
<img width="960" alt="Burst_Read" src="https://github.com/user-attachments/assets/e67165cc-3b3a-4db9-b6f2-9d45b080357a">

#### Figure 5-4 Burst Write Transfer:
<img width="960" alt="Burst_Write" src="https://github.com/user-attachments/assets/08e86ea2-5827-4eeb-8d32-8ad3cc346799">

### 5.4 Synthesis Results
#### Figure 6-1 Top Level RTL Model:
<img width="933" alt="Bridge Top" src="https://github.com/user-attachments/assets/33c31761-5f2e-4880-8b0d-98e63c26fb0b">

#### Figure 6-2 AHB Slave Model:
<img width="960" alt="AHB Slave Interface" src="https://github.com/user-attachments/assets/954853cc-16e4-4600-a6e4-9899148583de">

#### Figure 6-3 APB FSM Control Model:
<img width="960" alt="APB Controller" src="https://github.com/user-attachments/assets/f154da89-da6c-4095-b7e1-28b9a2dc6892">

#### Figure 6-4 State Machine Viewer:
<img width="949" alt="State Machine Diagram (FSM)" src="https://github.com/user-attachments/assets/d016d83d-03db-476a-b670-2098d450e92c">

## 6. Conclusion
The AHB to APB bridge is a crucial component in modern SoC designs, enabling efficient communication between high-speed and low-speed components. This report detailed its design, functionality, and performance through comprehensive simulation results.

## 7. Future Work
Future work involves optimizing the bridge for lower power consumption and higher data throughput. Additional features such as enhanced error handling and support for newer AMBA protocols can also be explored.The multimaster and multislave AHB to APB bridge is one of the future scope. 














