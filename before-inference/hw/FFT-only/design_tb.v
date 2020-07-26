module design1_tb; 
    reg clk, resetn;
    reg[15:0] tdata;
    reg tvalid;
    wire tready;
    parameter integer C_S_AXIS_TDATA_WIDTH	= 32;
    parameter integer C_M_AXIS_TDATA_WIDTH	= 32;
    // Start count is the number of clock cycles the master will wait before initiating/issuing any transaction.
    parameter integer C_M_START_COUNT	= 32;
     
    // MAXIS 
    // Master Stream Ports. TVALID indicates that the master is driving a valid transfer, A transfer takes place when both TVALID and TREADY are asserted. 
    wire  M_AXIS_TVALID;
    // TDATA is the primary payload that is used to provide the data that is passing across the interface from the master.
    wire [C_M_AXIS_TDATA_WIDTH-1 : 0] M_AXIS_TDATA;
    // TSTRB is the byte qualifier that indicates whether the content of the associated byte of TDATA is processed as a data byte or a position byte.
    wire [(C_M_AXIS_TDATA_WIDTH/8)-1 : 0] M_AXIS_TSTRB;
    // TLAST indicates the boundary of a packet.
    wire  M_AXIS_TLAST;
    // TREADY indicates that the slave can accept a transfer in the current cycle.
    wire  M_AXIS_TREADY;
    // SAXIS
    // Ready to accept data in
    wire  S_AXIS_TREADY;
    // Data in
    wire [C_S_AXIS_TDATA_WIDTH-1 : 0] S_AXIS_TDATA;
    // Byte qualifier
    wire [(C_S_AXIS_TDATA_WIDTH/8)-1 : 0] S_AXIS_TSTRB;
    // Indicates boundary of last packet
    wire  S_AXIS_TLAST;
    // Data is in valid
    wire  S_AXIS_TVALID;
design_1 d1 (.S_AXIS_CONFIG_0_tdata(tdata),
    .S_AXIS_CONFIG_0_tready(tready),
    .S_AXIS_CONFIG_0_tvalid(tvalid),
    .aclk_0(clk),
    .M_AXIS_DATA_0_tdata(M_AXIS_TDATA),
    .M_AXIS_DATA_0_tlast(M_AXIS_TLAST),
    .M_AXIS_DATA_0_tready(M_AXIS_TREADY),
    .M_AXIS_DATA_0_tvalid(M_AXIS_TVALID),
    .S_AXIS_DATA_0_tdata(S_AXIS_TDATA),
    .S_AXIS_DATA_0_tlast(S_AXIS_TLAST),
    .S_AXIS_DATA_0_tready(S_AXIS_TREADY),
    .S_AXIS_DATA_0_tvalid(S_AXIS_TVALID)
    );    
	// User initalization 
	  parameter width =4;
  wire [width-1:0] out;
  reg  [width-1:0] lfsr[13:0];
  integer f,i;
    // For user inputs
    integer               data_file    ; // file handler
    integer               scan_file    ; // file handler
    integer               index;
    reg signed[31:0]             captured_data;
    reg[31 : 0]                    data_reg[0:8191];
    `define NULL 0    


    // End user inputs
    always #5 clk=~clk;

   
   initial begin
   	index = 0;
	data_file = $fopen("/home/shodan/workspace/PHOTONIC/InitialTrainingData/0m.txt", "r");
         if (data_file == `NULL) begin
            $display("data_file handle was NULL");
            $finish;
            end

//  if (!$feof(data_file)) begin
//  end
    f = $fopen("output.txt","w");     
      tdata = 15'b00011;
      tvalid = 1'b1;
      clk=1; resetn=0;
      #10 resetn=1;
      # 2000 
    $fclose(f);  
    $stop;
    
    end
		// Do not modify the ports beyond this line

		// AXI4Stream sink: Clock
		 wire  S_AXIS_ACLK;
		 assign S_AXIS_ACLK=clk;
		// AXI4Stream sink: Reset
		wire  S_AXIS_ARESETN;
		assign S_AXIS_ARESETN=resetn;

    
    	// function called clogb2 that returns an integer which has the 
	// value of the ceiling of the log base 2.
	function integer clogb2 (input integer bit_depth);
	  begin
	    for(clogb2=0; bit_depth>0; clogb2=clogb2+1)
	      bit_depth = bit_depth >> 1;
	  end
	endfunction

	// Total number of input data.
	localparam NUMBER_OF_INPUT_WORDS  = 8;
	// bit_num gives the minimum number of bits needed to address 'NUMBER_OF_INPUT_WORDS' size of FIFO.
	localparam bit_num  = clogb2(NUMBER_OF_INPUT_WORDS-1);
	// Define the states of state machine
	// The control state machine oversees the writing of input streaming data to the FIFO,
	// and outputs the streaming data from the FIFO
	parameter [1:0] IDLE = 1'b0,        // This is the initial/idle state 

	                WRITE_FIFO  = 1'b1; // In this state FIFO is written with the
	                                    // input stream data S_AXIS_TDATA 
	wire  	axis_tready;
	// State variable
	reg mst_exec_state;  
	// FIFO implementation signals
	genvar byte_index;     
	// FIFO write enable
	wire fifo_wren;
	// FIFO full flag
	reg fifo_full_flag;
	// FIFO write pointer
	reg [bit_num-1:0] write_pointer;
	// sink has accepted all the streaming data and stored in FIFO
	  reg writes_done;
	// I/O Connections assignments

	assign S_AXIS_TREADY	= axis_tready;
	


	// End User initialization 
	// Control state machine implementation
	always @(posedge S_AXIS_ACLK) 
	begin  
	  if (!S_AXIS_ARESETN) 
	  // Synchronous reset (active low)
	    begin
	      mst_exec_state <= IDLE;
	    end  
	  else
	    case (mst_exec_state)
	      IDLE: 
	        // The sink starts accepting tdata when 
	        // there tvalid is asserted to mark the
	        // presence of valid streaming data 
	          if (S_AXIS_TVALID)
	            begin
	              mst_exec_state <= WRITE_FIFO;
	            end
	          else
	            begin
	              mst_exec_state <= IDLE;
	            end
	      WRITE_FIFO: 
	        // When the sink has accepted all the streaming input data,
	        // the interface swiches functionality to a streaming master
	        if (writes_done)
	          begin
	            mst_exec_state <= IDLE;
	          end
	        else
	          begin
	            // The sink accepts and stores tdata 
	            // into FIFO
	            mst_exec_state <= WRITE_FIFO;
	          end

	    endcase
	end
	// AXI Streaming Sink 
	// 
	// The example design sink is always ready to accept the S_AXIS_TDATA  until
	// the FIFO is not filled with NUMBER_OF_INPUT_WORDS number of input words.
	assign axis_tready = ((mst_exec_state == WRITE_FIFO) && (write_pointer <= NUMBER_OF_INPUT_WORDS-1));

	always@(posedge S_AXIS_ACLK)
	begin
	  if(!S_AXIS_ARESETN)
	    begin
	      write_pointer <= 0;
	      writes_done <= 1'b0;
	    end  
	  else
	    if (write_pointer <= NUMBER_OF_INPUT_WORDS-1)
	      begin
	        if (fifo_wren)
	          begin
	            // write pointer is incremented after every write to the FIFO
	            // when FIFO write signal is enabled.
	            write_pointer <= write_pointer + 1;
	            writes_done <= 1'b0;
	          end
	          if ((write_pointer == NUMBER_OF_INPUT_WORDS-1)|| S_AXIS_TLAST)
	            begin
	              // reads_done is asserted when NUMBER_OF_INPUT_WORDS numbers of streaming data 
	              // has been written to the FIFO which is also marked by S_AXIS_TLAST(kept for optional usage).
	              writes_done <= 1'b1;
	            end
	      end  
	end

	// FIFO write enable generation
	assign fifo_wren = S_AXIS_TVALID && axis_tready;

	// FIFO Implementation
	generate 
	  for(byte_index=0; byte_index<= (C_S_AXIS_TDATA_WIDTH/8-1); byte_index=byte_index+1)
	  begin:FIFO_GEN

	    reg  [(C_S_AXIS_TDATA_WIDTH/4)-1:0] stream_data_fifo [0 : NUMBER_OF_INPUT_WORDS-1];

	    // Streaming input data is stored in FIFO

	    always @( posedge S_AXIS_ACLK )
	    begin
	      if (fifo_wren)// && S_AXIS_TSTRB[byte_index])
	        begin
	          stream_data_fifo[write_pointer] <= S_AXIS_TDATA[(byte_index*8+7) -: 8];
	           $fwrite(f,"%d\n",   stream_data_fifo[write_pointer]);
	        end  
	    end  
	  end		
	endgenerate


		// Global ports
		wire  M_AXIS_ACLK;
		assign M_AXIS_ACLK=clk;
		// 
		wire  M_AXIS_ARESETN;
		assign M_AXIS_ARESETN=resetn;

		
		localparam NUMBER_OF_OUTPUT_WORDS = 8;                                               
	                                          
	// WAIT_COUNT_BITS is the width of the wait counter.                                 
	localparam integer WAIT_COUNT_BITS = clogb2(C_M_START_COUNT-1);                      
	                                                                                     
                                                                                     
	// Define the states of state machine                                                
	// The control state machine oversees the writing of input streaming data to the FIFO,
	// and outputs the streaming data from the FIFO                                      
	parameter [1:0] IDLE2 = 2'b00,        // This is the initial/idle state               
	                                                                                     
	                INIT_COUNTER  = 2'b01, // This state initializes the counter, once   
	                                // the counter reaches C_M_START_COUNT count,        
	                                // the state machine changes state to SEND_STREAM     
	                SEND_STREAM   = 2'b10; // In this state the                          
	                                     // stream data is output through M_AXIS_TDATA   
	// State variable                                                                    
	reg [1:0] mst_exec_state2;                                                            
	// Example design FIFO read pointer                                                  
	reg [bit_num-1:0] read_pointer;                                                      

	// AXI Stream internal signals
	//wait counter. The master waits for the user defined number of clock cycles before initiating a transfer.
	reg [WAIT_COUNT_BITS-1 : 0] 	count;
	//streaming data valid
	wire  	axis_tvalid;
	//streaming data valid delayed by one clock cycle
	reg  	axis_tvalid_delay;
	//Last of the streaming data 
	wire  	axis_tlast;
	//Last of the streaming data delayed by one clock cycle
	reg  	axis_tlast_delay;
	//FIFO implementation signals
	reg [C_M_AXIS_TDATA_WIDTH-1 : 0] 	stream_data_out;
	wire  	tx_en;
	//The master has issued all the streaming data stored in FIFO
	reg  	tx_done;


	// I/O Connections assignments

	assign M_AXIS_TVALID	= axis_tvalid_delay;
	assign M_AXIS_TDATA	= stream_data_out;
	assign M_AXIS_TLAST	= axis_tlast_delay;
	assign M_AXIS_TSTRB	= {(C_M_AXIS_TDATA_WIDTH/8){1'b1}};


	// Control state machine implementation                             
	always @(posedge M_AXIS_ACLK)                                             
	begin                                                                     
	  if (!M_AXIS_ARESETN)                                                    
	  // Synchronous reset (active low)                                       
	    begin                                                                 
	      mst_exec_state2 <= IDLE2;                                             
	      count    <= 0;                                                      
	    end                                                                   
	  else                                                                    
	    case (mst_exec_state2)                                                 
	      IDLE2:                                                               
	        // The slave starts accepting tdata when                          
	        // there tvalid is asserted to mark the                           
	        // presence of valid streaming data                               
	        //if ( count == 0 )                                                 
	        //  begin                                                           
	            mst_exec_state2  <= INIT_COUNTER;                              
	        //  end                                                             
	        //else                                                              
	        //  begin                                                           
	        //    mst_exec_state2  <= IDLE;                                      
	        //  end                                                             
	                                                                          
	      INIT_COUNTER:                                                       
	        // The slave starts accepting tdata when                          
	        // there tvalid is asserted to mark the                           
	        // presence of valid streaming data                               
	        if ( count == C_M_START_COUNT - 1 )                               
	          begin                                                           
	            mst_exec_state2  <= SEND_STREAM;                               
	          end                                                             
	        else                                                              
	          begin                                                           
	            count <= count + 1;                                           
	            mst_exec_state2  <= INIT_COUNTER;                              
	          end                                                             
	                                                                          
	      SEND_STREAM:                                                        
	        // The example design streaming master functionality starts       
	        // when the master drives output tdata from the FIFO and the slave
	        // has finished storing the S_AXIS_TDATA                          
	        if (tx_done)                                                      
	          begin                                                           
	            mst_exec_state2 <= IDLE2;                                       
	          end                                                             
	        else                                                              
	          begin                                                           
	            mst_exec_state2 <= SEND_STREAM;                                
	          end                                                             
	    endcase                                                               
	end                                                                       


	//tvalid generation
	//axis_tvalid is asserted when the control state machine's state is SEND_STREAM and
	//number of output streaming data is less than the NUMBER_OF_OUTPUT_WORDS.
	assign axis_tvalid = ((mst_exec_state2 == SEND_STREAM) && (read_pointer < NUMBER_OF_OUTPUT_WORDS));
	                                                                                               
	// AXI tlast generation                                                                        
	// axis_tlast is asserted number of output streaming data is NUMBER_OF_OUTPUT_WORDS-1          
	// (0 to NUMBER_OF_OUTPUT_WORDS-1)                                                             
	assign axis_tlast = (read_pointer == NUMBER_OF_OUTPUT_WORDS-1);                                
	                                                                                               
	                                                                                               
	// Delay the axis_tvalid and axis_tlast signal by one clock cycle                              
	// to match the latency of M_AXIS_TDATA                                                        
	always @(posedge M_AXIS_ACLK)                                                                  
	begin                                                                                          
	  if (!M_AXIS_ARESETN)                                                                         
	    begin                                                                                      
	      axis_tvalid_delay <= 1'b0;                                                               
	      axis_tlast_delay <= 1'b0;                                                                
	    end                                                                                        
	  else                                                                                         
	    begin                                                                                      
	      axis_tvalid_delay <= axis_tvalid;                                                        
	      axis_tlast_delay <= axis_tlast;                                                          
	    end                                                                                        
	end                                                                                            


	//read_pointer pointer

	always@(posedge M_AXIS_ACLK)                                               
	begin                                                                            
	  if(!M_AXIS_ARESETN)                                                            
	    begin                                                                        
	      read_pointer <= 0;                                                         
	      tx_done <= 1'b0;                                                           
	    end                                                                          
	  else                                                                           
	    if (read_pointer <= NUMBER_OF_OUTPUT_WORDS-1)                                
	      begin                                                                      
	        if (tx_en)                                                               
	          // read pointer is incremented after every read from the FIFO          
	          // when FIFO read signal is enabled.                                   
	          begin                                                                  
	            read_pointer <= read_pointer + 1;                                    
	            tx_done <= 1'b0;                                                     
	          end                                                                    
	      end                                                                        
	    else if (read_pointer == NUMBER_OF_OUTPUT_WORDS)                             
	      begin                                                                      
	        // tx_done is asserted when NUMBER_OF_OUTPUT_WORDS numbers of streaming data
	        // has been out.                                                         
	        tx_done <= 1'b1;                                                         
	      end                                                                        
	end                                                                              


	//FIFO read enable generation 

	assign tx_en = M_AXIS_TREADY && axis_tvalid;   
	                                                     
	    // Streaming output data is read from FIFO       
	    always @( posedge M_AXIS_ACLK )                  
	    begin                                            
	      if(!M_AXIS_ARESETN)                            
	        begin                                        
	          stream_data_out <= data_reg[1];                      
	        end                                          
	      else if (tx_en)// && M_AXIS_TSTRB[byte_index]  
	        begin                                        
	          stream_data_out <= data_reg[read_pointer + 32'b1];   
	        end                                          
	    end                                              

	// Add user logic here
always @( posedge M_AXIS_ACLK )  
begin
    index = index +1; 
    scan_file = $fscanf(data_file, "%f\n", captured_data); 
    if (!$feof(data_file) && resetn) begin
        data_reg[index] = captured_data;
        $display("M_AXIS: Data_reg %d, Captured_data %d\n",index,data_reg[index],captured_data);
    end
    //use captured_data as you would any other wire or reg value;
	// User logic ends
end
endmodule
    
