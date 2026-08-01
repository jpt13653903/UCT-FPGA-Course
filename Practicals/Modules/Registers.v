typedef struct packed {
  logic [9:0]Switches;
} DE10_RdStruct;

typedef struct packed {
  logic      RegistersToLEDs;
  logic [9:0]LEDs;
} DE10_WrStruct;
//------------------------------------------------------------------------------

typedef struct packed {
  logic [15:0]X;
  logic [15:0]Y;
  logic [15:0]Z;
} G_Sensor_RdStruct;
//------------------------------------------------------------------------------

typedef struct packed {
  logic [23:0]RampStart;
  logic [23:0]RampStop;
  logic [23:0]RampStep;
} DSP_WrStruct;
//------------------------------------------------------------------------------

typedef struct packed {
  logic ADC_Busy;
  logic LPF_Busy;
} Logger_RdStruct;

typedef struct packed {
  logic ADC_Go;
  logic LPF_Go;
} Logger_WrStruct;
//------------------------------------------------------------------------------

typedef struct packed {
  DE10_RdStruct     DE10;
  G_Sensor_RdStruct G_Sensor;
  Logger_RdStruct   Logger;
} RdRegisters_Struct;

typedef struct packed {
  DE10_WrStruct   DE10;
  DSP_WrStruct    DSP;
  Logger_WrStruct Logger;
} WrRegisters_Struct;
//------------------------------------------------------------------------------

module Registers(
  input  ipClk,
  input  ipReset,

  input  var RdRegisters_Struct ipRdRegisters,
  output     WrRegisters_Struct opWrRegisters,

  input      [ 7:0]ipAddress,
  input      [ 3:0]ipByteEnable,
  output           opWaitRequest,
  input      [31:0]ipWriteData,
  input            ipWrite,
  input            ipRead,
  output reg [31:0]opReadData,
  output reg       opReadDataValid
);
//------------------------------------------------------------------------------

reg [31:0]ReadData;
reg [31:0]WriteData;

always_comb begin
  case(ipAddress)
    8'h00:   ReadData = ipRdRegisters.DE10.Switches;
    8'h01:   ReadData = opWrRegisters.DE10.RegistersToLEDs;
    8'h02:   ReadData = opWrRegisters.DE10.LEDs;

    8'h10:   ReadData = { {16{ipRdRegisters.G_Sensor.X[15]}}, ipRdRegisters.G_Sensor.X };
    8'h11:   ReadData = { {16{ipRdRegisters.G_Sensor.Y[15]}}, ipRdRegisters.G_Sensor.Y };
    8'h12:   ReadData = { {16{ipRdRegisters.G_Sensor.Z[15]}}, ipRdRegisters.G_Sensor.Z };

    8'h20:   ReadData = { {8{opWrRegisters.DSP.RampStart[23]}}, opWrRegisters.DSP.RampStart };
    8'h21:   ReadData = { {8{opWrRegisters.DSP.RampStop [23]}}, opWrRegisters.DSP.RampStop  };
    8'h22:   ReadData = { {8{opWrRegisters.DSP.RampStep [23]}}, opWrRegisters.DSP.RampStep  };

    8'h30:   ReadData = opWrRegisters.Logger.ADC_Go;
    8'h31:   ReadData = ipRdRegisters.Logger.ADC_Busy;
    8'h32:   ReadData = opWrRegisters.Logger.LPF_Go;
    8'h33:   ReadData = ipRdRegisters.Logger.LPF_Busy;

    default: ReadData = 32'hX;
  endcase

  for(integer n = 0; n < 4; n++) begin
    if(ipByteEnable[n])
      WriteData[8*n +:8] = ipWriteData[8*n +:8];
    else
      WriteData[8*n +:8] =   ReadData [8*n +:8];
  end
end
//------------------------------------------------------------------------------

reg Reset;

assign opWaitRequest = 0;

always @(posedge ipClk) begin
  Reset <= ipReset;

  if(Reset) begin
    opWrRegisters.DE10.RegistersToLEDs <= 0;
    opWrRegisters.DE10.LEDs            <= 0;

    opWrRegisters.DSP.RampStart        <= 24'h1A36E3; // 10 kHz
    opWrRegisters.DSP.RampStop         <= 24'h23A6CE; // 13.6 kHz
    opWrRegisters.DSP.RampStep         <= 24'h40    ;

    opWrRegisters.Logger.ADC_Go        <= 0;
    opWrRegisters.Logger.LPF_Go        <= 0;

  end else if(ipWrite) begin
    case(ipAddress)
      8'h01: opWrRegisters.DE10.RegistersToLEDs <= WriteData;
      8'h02: opWrRegisters.DE10.LEDs            <= WriteData;

      8'h20: opWrRegisters.DSP.RampStart        <= WriteData;
      8'h21: opWrRegisters.DSP.RampStop         <= WriteData;
      8'h22: opWrRegisters.DSP.RampStep         <= WriteData;

      8'h30: opWrRegisters.Logger.ADC_Go        <= WriteData;
      8'h32: opWrRegisters.Logger.LPF_Go        <= WriteData;

      default:;
    endcase
  end

  opReadData      <= ReadData;
  opReadDataValid <= ipRead;
end
//------------------------------------------------------------------------------

endmodule
//------------------------------------------------------------------------------

