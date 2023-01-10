Library IEEE ;
Use IEEE.STD_Logic_1164.All ;
Use IEEE.Numeric_STD.All ;

Entity IIR_Filter_Transposed_Direct_Form_II_Second_Order_Section Is
	
    Generic(
        Length_Of_Input_Words            : Integer := 8 ;
        Length_Of_Input_Fractions        : Integer := 7 ;
		
        Length_Of_Output_Words           : Integer := 9 ;
        Length_Of_Output_Fractions       : Integer := 7 ;
		
        Length_Of_Coefficients_Words     : Integer := 10 ;
        Length_Of_Coefficients_Fractions : Integer := 7 ;
		
        Gain                             : Integer := 31 ;
        Feed_Forward_Coefficient_1       : Integer := 255 ;
        Feed_Back_Coefficient_1          : Integer := -24 ;
        Feed_Back_Coefficient_2          : Integer := 23
    ) ;
	
    Port(
        Clock              : In  STD_Logic ;
        Synchronous_Reset  : In  STD_Logic ;
        Clock_Enable       : In  STD_Logic ;
        Input              : In  Signed(Length_Of_Input_Words-1 Downto 0) ;
        Output             : Out Signed(Length_Of_Output_Words-1 Downto 0)
    ) ;
    
End IIR_Filter_Transposed_Direct_Form_II_Second_Order_Section ;

Architecture Behavioral Of IIR_Filter_Transposed_Direct_Form_II_Second_Order_Section Is

    Signal Synchronous_Reset_Register        : STD_Logic                                                              := '0' ;
    Signal Clock_Enable_Register             : STD_Logic                                                              := '0' ;
    Signal Input_Register                    : Signed(Length_Of_Input_Words-1 Downto 0)                               := To_Signed(0,Length_Of_Input_Words) ;
    Signal Output_Register                   : Signed(Length_Of_Output_Words-1 Downto 0)                              := To_Signed(0,Length_Of_Output_Words) ;
    
    Signal Input_Signal                      : Signed(Length_Of_Input_Words-1 Downto 0)                               := To_Signed(0,Length_Of_Input_Words) ;
    Signal Input_Signal_1_Delay              : Signed(Length_Of_Input_Words-1 Downto 0)                               := To_Signed(0,Length_Of_Input_Words) ;
    
    Signal Input_Gain                        : Signed(Length_Of_Input_Words+Length_Of_Coefficients_Words-1 Downto 0)  := To_Signed(0,Length_Of_Input_Words+Length_Of_Coefficients_Words) ;
    Alias  Input_Gaine_Quantize              : Signed(Length_Of_Output_Words-1 Downto 0) Is Input_Gain(Length_Of_Output_Words+Length_Of_Input_Fractions+Length_Of_Coefficients_Fractions-Length_Of_Output_Fractions-1 Downto Length_Of_Input_Fractions+Length_Of_Coefficients_Fractions-Length_Of_Output_Fractions) ;
    
    Signal Signal_Numerator_0_1_Delay        : Signed(Length_Of_Output_Words-1 Downto 0)                              := To_Signed(0,Length_Of_Output_Words) ;
    Signal Signal_Numerator_0_2_Delay        : Signed(Length_Of_Output_Words-1 Downto 0)                              := To_Signed(0,Length_Of_Output_Words) ;
    Signal Signal_Numerator_1_1_Delay        : Signed(Length_Of_Output_Words-1 Downto 0)                              := To_Signed(0,Length_Of_Output_Words) ;
    Signal Signal_Numerator_1_2_Delay        : Signed(Length_Of_Output_Words-1 Downto 0)                              := To_Signed(0,Length_Of_Output_Words) ;
    Signal Signal_Numerator_2_1_Delay        : Signed(Length_Of_Output_Words-1 Downto 0)                              := To_Signed(0,Length_Of_Output_Words) ;
    Signal Signal_Numerator_2_2_Delay        : Signed(Length_Of_Output_Words-1 Downto 0)                              := To_Signed(0,Length_Of_Output_Words) ;
    
    Signal Multiplier_Numerator_0            : Signed(Length_Of_Output_Words-1 Downto 0)                              := To_Signed(0,Length_Of_Output_Words) ;
    Signal Multiplier_Numerator_1            : Signed(Length_Of_Output_Words+Length_Of_Coefficients_Words-1 Downto 0) := To_Signed(0,Length_Of_Output_Words+Length_Of_Coefficients_Words) ;
    Alias  Multiplier_Numerator_1_Quantize   : Signed(Length_Of_Output_Words-1 Downto 0) Is Multiplier_Numerator_1(Length_Of_Output_Words+Length_Of_Coefficients_Fractions-1 Downto Length_Of_Coefficients_Fractions) ;
    Signal Multiplier_Numerator_2            : Signed(Length_Of_Output_Words-1 Downto 0)                              := To_Signed(0,Length_Of_Output_Words) ;
    
    Signal Multiplier_Denumerator_1          : Signed(Length_Of_Output_Words+Length_Of_Coefficients_Words-1 Downto 0) := To_Signed(0,Length_Of_Output_Words+Length_Of_Coefficients_Words) ;
    Alias  Multiplier_Denumerator_1_Quantize : Signed(Length_Of_Output_Words-1 Downto 0) Is Multiplier_Denumerator_1(Length_Of_Output_Words+Length_Of_Coefficients_Fractions-1 Downto Length_Of_Coefficients_Fractions) ;
    Signal Multiplier_Denumerator_2          : Signed(Length_Of_Output_Words+Length_Of_Coefficients_Words-1 Downto 0) := To_Signed(0,Length_Of_Output_Words+Length_Of_Coefficients_Words) ;
    Alias  Multiplier_Denumerator_2_Quantize : Signed(Length_Of_Output_Words-1 Downto 0) Is Multiplier_Denumerator_2(Length_Of_Output_Words+Length_Of_Coefficients_Fractions-1 Downto Length_Of_Coefficients_Fractions) ;
    
    Signal Adder_0                           : Signed(Length_Of_Output_Words-1 Downto 0)                              := To_Signed(0,Length_Of_Output_Words) ;
    Signal Adder_1                           : Signed(Length_Of_Output_Words-1 Downto 0)                              := To_Signed(0,Length_Of_Output_Words) ;
    Signal Adder_2                           : Signed(Length_Of_Output_Words-1 Downto 0)                              := To_Signed(0,Length_Of_Output_Words) ;
    
Begin

    Process(Clock)
    Begin
       
        If Rising_Edge(Clock) Then
       
        --  Registering Input Ports
           Synchronous_Reset_Register <= Synchronous_Reset ;
           Clock_Enable_Register      <= Clock_Enable ;
           Input_Register             <= Input ;
        --  %%%%%%%%%%%%%%%%%%%%%%%
        
        --  Reset Internal Registers
           If Synchronous_Reset_Register='1' Then
               
                Input_Signal               <= To_Signed(0,Length_Of_Input_Words) ;
                Input_Signal_1_Delay       <= To_Signed(0,Length_Of_Input_Words) ;
                
                Input_Gain                 <= To_Signed(0,Length_Of_Input_Words+Length_Of_Coefficients_Words) ;

                Signal_Numerator_0_1_Delay <= To_Signed(0,Length_Of_Output_Words) ;
                Signal_Numerator_0_2_Delay <= To_Signed(0,Length_Of_Output_Words) ;
                Signal_Numerator_1_1_Delay <= To_Signed(0,Length_Of_Output_Words) ;
                Signal_Numerator_1_2_Delay <= To_Signed(0,Length_Of_Output_Words) ;
                Signal_Numerator_2_1_Delay <= To_Signed(0,Length_Of_Output_Words) ;
                Signal_Numerator_2_2_Delay <= To_Signed(0,Length_Of_Output_Words) ;
                
                Multiplier_Numerator_0     <= To_Signed(0,Length_Of_Output_Words) ;
                Multiplier_Numerator_1     <= To_Signed(0,Length_Of_Output_Words+Length_Of_Coefficients_Words) ;
                Multiplier_Numerator_2     <= To_Signed(0,Length_Of_Output_Words) ;
                
                Adder_1                    <= To_Signed(0,Length_Of_Output_Words) ;
                Adder_2                    <= To_Signed(0,Length_Of_Output_Words) ;
                
                Output_Register            <= To_Signed(0,Length_Of_Output_Words) ;
        --  %%%%%
        
            Elsif Clock_Enable_Register='1' Then
                
                Input_Signal               <= Input_Register ;
                Input_Signal_1_Delay       <= Input_Signal ;
                
                Input_Gain                 <= Input_Signal_1_Delay * To_Signed(Gain,Length_Of_Coefficients_Words) ;
                
                Signal_Numerator_0_1_Delay <= Input_Gaine_Quantize ;
                Signal_Numerator_0_2_Delay <= Signal_Numerator_0_1_Delay ;
                Signal_Numerator_1_1_Delay <= Input_Gaine_Quantize ;
                Signal_Numerator_1_2_Delay <= Signal_Numerator_1_1_Delay ;
                Signal_Numerator_2_1_Delay <= Input_Gaine_Quantize ;
                Signal_Numerator_2_2_Delay <= Signal_Numerator_2_1_Delay ;
                                
                Multiplier_Numerator_0     <= Signal_Numerator_0_2_Delay ;
                Multiplier_Numerator_1     <= Signal_Numerator_1_2_Delay * To_Signed(Feed_Forward_Coefficient_1,Length_Of_Coefficients_Words) ;
                Multiplier_Numerator_2     <= Signal_Numerator_2_2_Delay ;
                
                Adder_1                    <= Multiplier_Numerator_1_Quantize + Multiplier_Denumerator_1_Quantize + Adder_2 ;
                Adder_2                    <= Multiplier_Numerator_2 + Multiplier_Denumerator_2_Quantize ;
                
					 Output_Register            <= Adder_0 ;
					 
            End If ;
           
        End If ;
       
    End Process ;
    
    Adder_0                  <= Multiplier_Numerator_0 + Adder_1 ;
    
    Multiplier_Denumerator_1 <= Adder_0 * To_Signed((-1)*Feed_Back_Coefficient_1,Length_Of_Coefficients_Words) ;
    Multiplier_Denumerator_2 <= Adder_0 * To_Signed((-1)*Feed_Back_Coefficient_2,Length_Of_Coefficients_Words) ;
	 
--  Registering Output Ports 
    Output                   <= Output_Register ;
--  %%%%%%%%%%%%%%%%%%%%%%%
    
End Behavioral ;