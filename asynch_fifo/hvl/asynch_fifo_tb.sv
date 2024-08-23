`timescale 1ns/1ps

class transaction;
  rand bit oper;
  logic rd;
  logic wr;
  logic [7:0] din;
  logic [7:0] dout;
  logic empty;
  logic full; 

  function transaction copy();
    copy = new();
    copy.rd = this.rd;
    copy.wr = this.wr;
    copy.din = this.din;
    copy.dout = this.dout;
    copy.empty = this.empty;
    copy.full = this.full;
    copy.oper = this.oper;
  endfunction

  constraint oper_distribution {
    oper dist {1 :/ 50, 0 :/ 50};
  }

endclass

class driver;
  virtual fifo_if fifo_interface;
  mailbox #(transaction) mbx;
  transaction t;
  event driver_done, monitor_next;
  event sim_done;
  bit printed;
  function new(input mailbox #(transaction) mbx);
    this.mbx = mbx;
    t = new();
  endfunction

  task reset();
    fifo_interface.rst1 <= 1'b1;
    fifo_interface.rst2 <= 1'b1;
    fifo_interface.din <= '0;
    fifo_interface.wr <= '0;
    fifo_interface.rd <= '0;
    repeat(5) @(posedge fifo_interface.clk1);
    fifo_interface.rst1 <= 1'b0;
    fifo_interface.rst2 <= 1'b0;
    @(posedge fifo_interface.clk1);
    $display("[DRV] RESET DONE at time: %0t", $time);
  endtask



  task read();

    if(!fifo_interface.empty) begin
        @(posedge fifo_interface.clk2);
        fifo_interface.rst2 <= 1'b0;
        fifo_interface.rd <= 1'b1;
        fifo_interface.wr <= 1'b0;
        fifo_interface.din <= $urandom_range(0,15);
        // fifo_interface.din <= 8'd12;
        @(posedge fifo_interface.clk2);
        $display("[DRV] READ at time: %0t", $time);
        fifo_interface.rd <= 1'b0;  
        @(monitor_next);
    end else begin
          $display("[DRV] Cannot READ from empty FIFO");
    end
  endtask

  task write();
    if(!fifo_interface.full) begin
      @(posedge fifo_interface.clk1);
      fifo_interface.rst1 <= 1'b0;
      fifo_interface.rd <= 1'b0;
      fifo_interface.wr <= 1'b1;
      fifo_interface.din <= $urandom_range(0,15);
      @(posedge fifo_interface.clk1);
      $display("[DRV] WRITE at time: %0t with din: %0d", $time, fifo_interface.din);
      fifo_interface.wr <= 1'b0;
      @(monitor_next);
    end else begin
          $display("[DRV] Cannot WRITE to full FIFO");
    end
  endtask

  task write_full();
    for(int i = 0; i < 8; i++)
    begin
    write();
    end
  endtask

  task read_empty();
    for(int i = 0; i < 8; i++)
    begin
    read();
    end
  endtask

  task main();
    write_full(); 
    read_empty();
  endtask

  task run2();
     write();
     read();
     write();
     read();
     write();
     read(); 
     write();
     write();
     write();
     write_full(); 
    -> driver_done;
    $display("driver_done triggered at time %0t", $time);
  endtask 

endclass

class monitor;
  transaction t;
  mailbox #(transaction) mbx;
  virtual fifo_if fifo_interface;
  event driver_done;
  event monitor_done;
  event monitor_next;
  function new(input mailbox #(transaction) mbx);
    this.mbx = mbx;
    t = new();
  endfunction

  task run_write();
   forever begin
      @(posedge fifo_interface.clk1); // driver will assert signals on second rising edge
      if(fifo_interface.wr) begin

      t.empty = fifo_interface.empty;
      t.full = fifo_interface.full;
      t.wr = fifo_interface.wr;
      t.rd = fifo_interface.rd;
      t.din = fifo_interface.din;
      @(posedge fifo_interface.clk1);
      t.dout = fifo_interface.dout;
      $display("[MON]-WRITE empty: %0d full: %0d din: %0d wr: %0d rd: %0d time: %0t", t.empty, t.full, t.din, t.wr, t.rd, $time);
      -> monitor_next;
      
      end 
    end
  endtask
  task run_read();
    forever begin
      @(posedge fifo_interface.clk2);
      if(fifo_interface.rd) begin
        t.empty = fifo_interface.empty;
        t.full = fifo_interface.full;
        t.wr = fifo_interface.wr;
        t.rd = fifo_interface.rd;
        t.din = fifo_interface.din;
        @(posedge fifo_interface.clk2);
        t.dout = fifo_interface.dout;
        $display("[MON]-READ data_out: %0d empty: %0d full: %0d wr: %0d rd: %0d time: %0t", t.dout, t.empty, t.full, t.wr, t.rd, $time);
        -> monitor_next;
      end
    end
  endtask
  task run2();
    fork
      run_read();
      run_write();
    join_none
      wait(driver_done.triggered);
      $display("Monitor_Done Triggered");
      -> monitor_done;
  endtask
endclass


class environment;
  driver d;
  transaction t;
  monitor m;
  event monitor_done, driver_done, monitor_next;
  // event sim_done;
  virtual fifo_if fif;
  mailbox #(transaction) g_d_mbx, m_s_mbx;
  function new(input virtual fifo_if fif);
    g_d_mbx = new();
    m_s_mbx = new();
    d = new(g_d_mbx);
    m = new(m_s_mbx);
    this.fif = fif;
    d.fifo_interface = fif;
    m.fifo_interface = fif;
    d.driver_done = driver_done;
    m.driver_done = driver_done;
    d.monitor_next = monitor_next;
    m.monitor_next = monitor_next;
    this.driver_done = m.driver_done;
  endfunction

  task pre_test();
    d.reset();
  endtask

  task test2();
    fork
      // g.run();
      d.run2();
      m.run2();
      // s.run();
    join
  endtask
  task post_test2();
    wait(m.monitor_done.triggered)
    $finish();
  endtask
  task run();
    pre_test();
    test2();
    // $finish();
    post_test2();
  endtask
endclass

module asynch_fifo_tb;

    fifo_if fif();
    FIFO dut (
        .clk1(fif.clk1), 
        .clk2(fif.clk2), 
        .rst1(fif.rst1), 
        .rst2(fif.rst2), 
        .wr(fif.wr), 
        .rd(fif.rd),
        .din(fif.din), 
        .dout(fif.dout),
        // .hex_seg(fif.dout),
        // .hex_gridA(hex_gridA),
        // .hex_gridB(hex_gridB),
        .empty(fif.empty), 
        .full(fif.full)
        );
        
    initial begin
        fif.clk1 <= 0;
        fif.clk2 <= 0;
    end
        
    always #10 fif.clk1 <= ~fif.clk1;

    always #5 fif.clk2 <= ~fif.clk2;


    environment env;
        
    initial begin
    // #20
        // $display("clk1:%0d clk2:%0d rst1:%0d rst2:%0d wr:%0d rd:%0d din:%0d dout:%0d empty:%0d full: %0d", fif.clk1, fif.clk2, fif.rst1, fif.rst2, fif.wr, fif.rd, fif.din, fif.dout, fif.empty, fif.full);
        env = new(fif);
        // env.pre_test();
        // // env.g.count = 10;
        // env.test2();
        env.run();
        // $finish();
    end
   endmodule