// Code your design here

//--------------------------------------------------------------
//this apb slave have i.addresses have "wo" write only 25,40,80,200
//                   ii.addresses have "RO" READ ONLY 60,70,90,255.
//BECAREFUL SLAVE IS thrown "slverr" when read the write only registers and write the read only 
//write only registers.
//and the addrreses are beyond => 2**16=65536,means address>=65536 then slave thrown error and dont write and read transaction takes place.

`define IDLE 0
`define SETUP 1
`define ACCESS 2

module apb_mem #(parameter DEPTH = 16) (
    input _PCLK, _PRESETn, _PSEL1, _PWRITE, _PENABLE,
    input [31:0] _PADDR, _PWDATA,
    output reg [31:0] _PRDATA, 
    output reg _PREADY, _PSLVERR
);
    reg [1:0] _state, _next_state;
    reg [1:0] delay;
    reg read_only;
    reg write_only;

    reg [31:0] mem [2**DEPTH-1:0];//memory depth 0 to 65535 and data width is 32 bit .

    initial begin
        _state = `IDLE;
    end

    always @(posedge _PCLK or negedge _PRESETn ) begin
        if(!_PRESETn) begin
            _state <= `IDLE;
          _PRDATA <= '0;
          foreach(mem[i]) mem[i] = i;
        end
        else
            _state <= _next_state;
    end

    always @(_state, _PSEL1, _PENABLE) begin
        case (_state)
            `IDLE:                
            begin
                ///$display("[%0t] In Idle State", $time);
              delay = $urandom_range(0,4);
                _PSLVERR <= 0;
                _PREADY <= 0;
                //_PRDATA <= 32'h0;
                if(_PSEL1) _next_state <= `SETUP;
                else _next_state <= `IDLE;
            end
                
            `SETUP:
            begin:B1
                ///$display("[%0t] In Setup State", $time);
                _PREADY <= 0;
                _PSLVERR<=0;
              
              if(_PENABLE) begin:A1
                repeat(delay) @(posedge _PCLK);
                    _PREADY <= 1;
                  
                   if(!_PWRITE && _PSEL1 && _PENABLE && write_only!==1) begin:A6
                            _PRDATA <= mem[_PADDR[DEPTH-1:0]];
                      end:A6
                
                    _next_state <= `ACCESS;
                end:A1
                else
                    _next_state <= _state;
               end:B1

            `ACCESS:
            begin:C0
               /// $display("[%0t] In Access State", $time);
              if(_PWRITE && !_PSLVERR && read_only!==1) begin:C1
                    mem[_PADDR[DEPTH-1:0]] =  _PWDATA;
                end:C1
                _PREADY <= 0;
                if(!_PSEL1)
                    _next_state <= `IDLE;
                else
                    _next_state <= `SETUP;
            end:C0
        endcase
    end

              always @(*) begin:D1
                
                  if(_PENABLE) begin: D2
                    
                 if(_PADDR >= 2**DEPTH) begin:A2
                   _PSLVERR <= 1;
                    $error("Memory Address more than limits");
                   end: A2 
                  
                    else if(_PWRITE && (_PWDATA === 32'hx || _PWDATA === 32'hz)) begin:A3
                      _PSLVERR <= 1;
                     $error("Invalid data in PWDATA line");
                    end:A3
                  
                    else if((_PWRITE) && (_PADDR===60 || _PADDR===70 || _PADDR===90 || _PADDR===255))  begin:A4 //read only locations
                      read_only=1;
                     _PSLVERR <= 1;
                     $error("Read only address locations");
                 end:A4
                  
                    else if((!_PWRITE) && (_PADDR===25 || _PADDR===40 || _PADDR===80 || _PADDR===200)) begin:A5 //write only locations,if read this locations pslverr come.
                    write_only=1;
                 	_PSLVERR <= 1;
                	$error("write only address locations");
                    end:A5
                  
                	end:D2
                
                   end:D1
              
endmodule  



            
  /*            

module apb_mem #(parameter DEPTH = 16) (
    input _PCLK, _PRESETn, _PSEL1, _PWRITE, _PENABLE,
    input [31:0] _PADDR, _PWDATA,
    output reg [31:0] _PRDATA, 
    output reg _PREADY, _PSLVERR
);
    reg [1:0] _state, _next_state;
    reg [1:0] delay;
    reg read_only;
    reg write_only;

    reg [31:0] mem [2**DEPTH-1:0];

    initial begin
        _state = `IDLE;
    end

    always @(posedge _PCLK or negedge _PRESETn ) begin
        if(!_PRESETn) begin
            _state <= `IDLE;
          _PRDATA <= '0;
          foreach(mem[i]) mem[i] = i;
        end
        else
            _state <= _next_state;
    end

    always @(_state, _PSEL1, _PENABLE) begin
        case (_state)
            `IDLE:                
            begin
                ///$display("[%0t] In Idle State", $time);
              delay = $urandom_range(0,4);
                _PSLVERR <= 0;
                _PREADY <= 0;
                //_PRDATA <= 32'h0;
                if(_PSEL1) _next_state <= `SETUP;
                else _next_state <= `IDLE;
            end
                
            `SETUP:
            begin:B1
                ///$display("[%0t] In Setup State", $time);
                _PREADY <= 0;
                _PSLVERR<=0;
              
              if(_PENABLE) begin:A1
                repeat(delay) @(posedge _PCLK);
                    _PREADY <= 1;
                  
                   if(!_PWRITE && _PSEL1 && _PENABLE && write_only!==1) begin:A6
                    _PRDATA <= mem[_PADDR[DEPTH-1:0]];
                      end:A6
                
                    _next_state <= `ACCESS;
                end:A1
                else
                    _next_state <= _state;
               end:B1

            `ACCESS:
            begin:C0
               /// $display("[%0t] In Access State", $time);
              if(_PWRITE && !_PSLVERR && read_only!==1) begin:C1
                    mem[_PADDR[DEPTH-1:0]] =  _PWDATA;
                end:C1
                _PREADY <= 0;
                if(!_PSEL1)
                    _next_state <= `IDLE;
                else
                    _next_state <= `SETUP;
            end:C0
        endcase
    end

              always @(posedge _PCLK) begin:D1
                if(_PENABLE) begin
                  if(_PADDR >= 2**DEPTH) begin:A2
                  repeat(delay) @(posedge _PCLK);
                    _PSLVERR <= 1;
                    end: A2 
                    end
                    end:D1
                
                 always @(posedge _PCLK) begin
                  if(_PENABLE) begin
                    if(_PWRITE && ((_PWDATA === 32'hx) || (_PWDATA === 32'hz))) begin:A3
                     repeat(delay) @(posedge _PCLK); 
                      _PSLVERR <= 1;
                  end:A3
                  end
                  end
          
          
                  always @(posedge _PCLK) begin
                   if(_PENABLE) begin
                     if((_PWRITE) && ((_PADDR===60) || (_PADDR===70) || (_PADDR===90) || (_PADDR===255) ))  begin:A4 //read only locations
                       read_only=1;
                      repeat(delay) @(posedge _PCLK); 
                     _PSLVERR <= 1;
                     $error("Read only address locations");
                 end:A4
                  end
                   end
                   
                   
                   
                    always @(*) begin
                   if(_PENABLE) begin
                     if((!_PWRITE) && ( (_PADDR===25) || (_PADDR===40) || (_PADDR===80) || (_PADDR===200) )) begin:A5 
                   //write only locations,if read this locations pslverr come.
                    write_only=1;
                   repeat(delay) @(posedge _PCLK); 
                   _PSLVERR <= 1;
                    end:A5
                    end
                    end
                
                   
endmodule  

*/       
                     
                     
                     
                     
//===============================================================================================

//bug found in this RTL AMBA 3.0 APB 1.0 
                     
                     
  /*                   
// Code your design here
`define IDLE 0
`define SETUP 1
`define ACCESS 2
module apb_mem #(parameter DEPTH = 8) (
    input _PCLK, _PRESETn, _PSEL1, _PWRITE, _PENABLE,
    input [31:0] _PADDR, _PWDATA,
    output reg [31:0] _PRDATA, 
    output reg _PREADY, _PSLVERR);
  
    reg [1:0] _state, _next_state;
    reg [1:0] delay;
    reg read_only;
    reg write_only;

    reg [31:0] mem [2**DEPTH-1:0];

    initial begin
        _state = `IDLE;
    end

    always @(posedge _PCLK or negedge _PRESETn ) begin
        if(!_PRESETn) begin
            _state <= `IDLE;
          foreach(mem[i]) mem[i] = i;
        end
        else
            _state <= _next_state;
    end

    always @(_state, _PSEL1, _PENABLE) begin
        case (_state)
            `IDLE:                
            begin
                ///$display("[%0t] In Idle State", $time);
              delay = $urandom_range(0,4);
                _PSLVERR <= 0;
                _PREADY <= 0;
                _PRDATA <= 32'h0;
                if(_PSEL1) _next_state <= `SETUP;
                else _next_state <= `IDLE;
            end
                
            `SETUP:
            begin:B1
                ///$display("[%0t] In Setup State", $time);
                _PREADY <= 0;
                _PSLVERR<=0;
              
              if(_PENABLE) begin:A1
                repeat(delay) @(posedge _PCLK);
                    _PREADY <= 1;
                  
                   if(!_PWRITE && _PSEL1 && _PENABLE && write_only!==1) begin:A6
                            _PRDATA <= mem[_PADDR[DEPTH-1:0]];
                      end:A6
                
                    _next_state <= `ACCESS;
                end:A1
                else
                    _next_state <= _state;
               end:B1

            `ACCESS:
            begin:C0
               /// $display("[%0t] In Access State", $time);
              if(_PWRITE && !_PSLVERR && read_only!==1) begin:C1
                    mem[_PADDR[DEPTH-1:0]] =  _PWDATA;
                end:C1
                _PREADY <= 0;
                if(!_PSEL1)
                    _next_state <= `IDLE;
                else
                    _next_state <= `SETUP;
            end:C0
        endcase
    end

              always @(*)
                begin:D1
                  if(_PENABLE) 
                    begin: D2
                 if(_PADDR >= 2**DEPTH) 
                 begin:A2
                   _PSLVERR <= 1;
                    $error("Memory Address more than limits");
                 end: A2 
                  
                 else if(_PWRITE && (_PWDATA === 32'hx || _PWDATA === 32'hz))
                    begin:A3
                        _PSLVERR <= 1;
                        $error("Invalid data in PWDATA line");
                    end:A3
                  
                  else if(_PWRITE && _PADDR===60 || _PADDR===70 || _PADDR===90 || _PADDR===255)
                    begin:A4
                      read_only=1;
                     _PSLVERR <= 1;
                     $error("Read only address locations");
                    end:A4
                  
                  else if(!_PWRITE && _PADDR===25 || _PADDR===40 || _PADDR===80 || _PADDR===200)
                    begin:A5
                 	write_only=1;
                 	_PSLVERR <= 1;
                	$error("write only address locations");
                    end:A5
                  
                	end:D2
                end:D1
              
endmodule

              
              

        */             
                     
                     
                     
                     
                     
//--------------------------------------------------------------------
              
