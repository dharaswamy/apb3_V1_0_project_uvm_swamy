
`define DRIVE_IF  m_vintf.driver_mdp

class apb_master_driver extends uvm_driver#(apb_master_seq_item);
  
   //factory registration.
  `uvm_component_utils(apb_master_driver)
  
 //INTERFACE Handle declaration.
  virtual apb_master_interface m_vintf;
  
  //apb_master_seq_item req;
  
  //default constructor.
  function new(string name,uvm_component parent);
    super.new(name,parent);
  `uvm_info("TRACE",$sformatf("%m"),UVM_HIGH)
  endfunction:new
  
  
  //uvm_config_db#(virtual apb_master_interface)::set(     uvm_root::get,  " * ","slv_vintf",slv_vintf);

function void build_phase(uvm_phase phase);
super.build_phase(phase);
  if(!uvm_config_db#(virtual apb_master_interface)::get(this," ","m_vintf",m_vintf)) begin
    `uvm_fatal("APB_MASTER_DRIVER_CONFIG_FATAL"," \n First set the \" slv_vintf \" virtual master interface handle into config db")
  end

endfunction:build_phase

  
virtual task run_phase(uvm_phase phase);
super.run_phase(phase);
  wait( `DRIVE_IF.preset_n);
 
 forever begin:forever_begin
   
  
  seq_item_port.get_next_item(req);
  
    `uvm_info("driver_debug",$sformatf(" req.PWADAT=%H",req.pwdata),UVM_NONE);
//    if(apb_master_seq_item::WRITE == req.pwrite)
//      `uvm_info("MASTER_DRV_RUN",{" \"WRITE TRANSACTION \"\n",req.sprint()},UVM_DEBUG);
//    if(apb_master_seq_item::READ == req.pwrite)
//      `uvm_info("MASTER_DRV_RUN",{" \"READ TRANSACTION \"\n",req.sprint()},UVM_DEBUG);
   drive();
  seq_item_port.item_done();
 
  end:forever_begin
endtask:run_phase
 
  
  protected task drive();
    `uvm_info("start_driver","debug driver",UVM_NONE);
    idle_state();
    setup_state();
    access_state();
    `uvm_error(get_full_name()," Error got fromt the ahb sequence " ) ;
  endtask:drive
  
  //we are writting the one task for the idle state behaviour.
  protected task idle_state();
    @(posedge `DRIVE_IF.pclk);
    `DRIVE_IF.pselx <= 1'b0;
    `DRIVE_IF.penable <= 1'b0;
  endtask:idle_state
 
  //we are writting the one task for the setup state behaviour.
  protected task setup_state();
    @(posedge `DRIVE_IF.pclk);
    `DRIVE_IF.pselx <= req.pselx;
    `DRIVE_IF.penable <= 1'b0;
    if(apb_master_seq_item::WRITE == req.pwrite) begin
    `DRIVE_IF.paddr <= req.paddr;
    `DRIVE_IF.pwdata <= req.pwdata;
    `DRIVE_IF.pwrite <= req.pwrite;
    end
    if(apb_master_seq_item::READ == req.pwrite) begin
     `DRIVE_IF.paddr <= req.paddr;
     `DRIVE_IF.pwrite <= req.pwrite; 
    end
    
  endtask:setup_state
  
  //we are writting the one task for the access state behaviour.
  protected task access_state();
    @(posedge `DRIVE_IF.pclk);
    `DRIVE_IF.penable <= 1'b1;
    wait(`DRIVE_IF.pready);
   `uvm_info("APB_MASTER_DRV_ACCESS_STATE_DONE",$sformatf(" \n signal pready=%b",`DRIVE_IF.pready),UVM_FULL);
   // @(posedge `DRIVE_IF.pclk);
   //`DRIVE_IF.pwrite <= 1'b0; 
    // `DRIVE_IF.pselx <= 1'b0;
  //`DRIVE_IF.penable <= 1'b0;
  endtask:access_state
  
endclass:apb_master_driver