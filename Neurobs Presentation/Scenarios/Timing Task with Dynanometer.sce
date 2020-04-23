 # -------------------------- Header Parameters --------------------------

scenario = "Timing Task"; 

#write_codes = EXPARAM( "Send ERP Codes" );

max_y = 100;
active_buttons = 4;
button_codes= 1, 2, 3, 4;
response_matching = simple_matching;

no_logfile = false;
response_logging = log_active;
write_codes = true;
response_port_output = false;

# ------------------------------- SDL Part ------------------------------
begin;

#Set default picture so can make it white later in PCL
picture {} default;


# ------------------------------- Trials --------------------------------
trial {
	trial_duration = forever;
	trial_type = specific_response;
	terminator_button = 1; # only SPACE
	
	stimulus_event{
		picture { 
			text { 
				caption = " "; 
				preload = false;
				font_size = 4.5;
			} instruct_text; 
			x = 0; 
			y = 0;
		}; 
		code = "Instruction";
		port_code = 192;
		code_width = indefinite_port_code; #Tried to use stimulus_event::INDEFINITE_PORT_CODE but throws error.
	} instruct_event;
} instruct_trial; # for practice instr and test instr, manually replace caption

trial {
	clear_active_stimuli = false;
	trial_duration = stimuli_length;
	monitor_sounds = true; # sounds are not terminated if a trial ends
	all_responses = false; # response during stimuli presentation is disabled
	
	stimulus_event {
		sound { 
			wavefile { 
				filename = ""; 
				preload = false; 
			}; 
		} sound_anchors;
		code = "Stimuli";
	} sound_event;	
	
	stimulus_event { 
		picture {
			text { 
				caption = "";
				preload = true; 
				font_size = 64;
			} anchor_text;
			x = 0;
			y = 0;
		} label_anchors;
	} sound_label_event;
} sound_trial; 

trial {
	stimulus_event {
			picture{};
	code = "ITI";
	port_code = 128;
	code_width = indefinite_port_code; #Tried to use stimulus_event::INDEFINITE_PORT_CODE but throws error. 
	} ITI_event;
}ITI_trial;

trial { 
   trial_duration = forever;
	trial_type = specific_response;
	terminator_button = 1, 2; # press SPACE to end break, R to repeat
	
	stimulus_event {
		picture {
			text {
				caption = "";
				preload = false; 
				font_size = 7;
				} end_block_text;
			x = 0; 
			y = 0;
		} end_block_pic;
		code = "End_Block";
		port_code = 192;
		code_width = indefinite_port_code; #Tried to use stimulus_event::INDEFINITE_PORT_CODE but throws error.
	} end_block_event;
} end_block_trial;

trial {	
	trial_duration = 2000;
	stimulus_event {
		picture { 
			text { 
				caption = "";
				preload = false;
				font_size = 7; 
			} fb_text; 
			x = 0; 
			y = 0; 
		}fb_pic;
		code = "Feedback";
		port_code = 96;
		code_width = indefinite_port_code; #Tried to use stimulus_event::INDEFINITE_PORT_CODE but throws error.
	} feedback_event;
} fb_trial;

trial{
	trial_type = specific_response;
	terminator_button = 1;
	trial_duration = forever;
	stimulus_event {
		picture {
			text {
				caption = "BREAK";
				font_size = 30;
			}break_caption_1;
			x = 0; y =0;
			text {
				caption = "(Press SPACE to move on)";
				font_size = 5;
			}break_caption_2;
			x = 0; y = -85;
		} break_pic;
		code = "Break";
		port_code = 160;
		code_width = indefinite_port_code; #Tried to use stimulus_event::INDEFINITE_PORT_CODE but throws error. 
	}break_event;
} break_trial;

trial {
    trial_duration = 992;
    
    stimulus_event {
       picture {
			text {
				caption = "BREAK";
				font_size = 30;
			}count_down_caption_1;
			x = 0; y =0;
			text {
				caption = "Experiment resumes in (seconds): ";
				font_size = 5;
			}count_down_caption_2;
			x = 0; y = -85;
			text {
				caption = "";
				font_size = 5;
			}count_down_caption_3;
			x = 50; y = -85;
		} count_down_pic;
		port_code = 160;
		code_width = indefinite_port_code; #Tried to use stimulus_event::INDEFINITE_PORT_CODE but throws error.
    } count_down_event;
} count_down_trial;

picture {
   text { 
	caption = "Enter participant number:"; 
	font_size = 5	;
};
   x = 0; y = 0;
   text { caption = " "; font_size = 2;} parti_num_text;
   x = 0; y = -20;
} parti_num;

trial {
	all_responses = false;
	trial_duration = 1000;
	monitor_sounds = true; # sounds are not terminated if a trial ends
	
	stimulus_event {
		sound { 
			wavefile { 
				filename = ""; 
				preload = false; 
			};
		};
		port_code = 96;
		code_width = 1000;
	} correct_sound_event;	
	
		picture {
			text { 
				caption = "Correct!";
				preload = true; 
				font_size = 6;
			};
			x = 0;
			y = 0;
		};
} correct_message; 

trial {
	clear_active_stimuli = false;
	trial_duration = 1000;
	monitor_sounds = true; # sounds are not terminated if a trial ends
	
	stimulus_event {
		sound { 
			wavefile { 
				filename = ""; 
				preload = false; 
			}; 
		};
		port_code = 96;
		code_width = 1000;
	} incorrect_sound_event;	
	
		picture {
			text { 
				caption = "Incorrect!";
				preload = true; 
				font_size = 6;
			} incorrect_text; 
			x = 0;
			y = 0;
		};
} incorrect_message; 

trial {
	all_responses = false;
	trial_duration = 1000;
		picture {
			text { 
				caption = "Too Slow!";
				preload = true; 
				font_size = 6;
			};
			x = 0;
			y = 0;
		};
		port_code = 96;
		code_width = 1000;
} too_slow_feedback; 

trial {
	clear_active_stimuli = true;
	monitor_sounds = true; # sounds are not terminated if a trial ends
	all_responses = false; 
	
	trial_type = first_response;
	no_response_feedback = too_slow_feedback;
   miss_feedback = incorrect_message;
   correct_feedback = correct_message;
	
	stimulus_event {
		sound { 
			wavefile { 
				filename = ""; 
				preload = false; 
			}; 
		};
		response_active = false;
		code = "Practice";
		code_width = indefinite_port_code; #Tried to use stimulus_event::INDEFINITE_PORT_CODE but throws error.
	} practice_sound_event;	
	
	stimulus_event {
		picture {};
		duration = 2500;
		code = "response";
		port_code = 32;
		code_width = indefinite_port_code; #Tried to use stimulus_event::INDEFINITE_PORT_CODE but throws error.
	} practice_response_event;	
} practice_trial; 


trial {
	all_responses = false;
	stimulus_event {
		sound { 
			wavefile { 
				filename = ""; 
				preload = false; 
			}; 
		};
		port_code = 96;
		code_width = indefinite_port_code;
	} blank_sound_event;
} sound_only_feedback; 

trial {
	clear_active_stimuli = true;
	monitor_sounds = true; # sounds are not terminated if a trial ends
	all_responses = false; 
	
	trial_type = first_response;
   incorrect_feedback = sound_only_feedback;
   correct_feedback = sound_only_feedback;
	
	stimulus_event {
		sound { 
			wavefile { 
				filename = ""; 
				preload = false; 
			}; 
		};
		response_active = false;
		code = "test";
		code_width = indefinite_port_code; #Tried to use stimulus_event::INDEFINITE_PORT_CODE but throws error.
	} test_sound_event;	
	
	stimulus_event {
		picture {};
		target_button = 2;
		duration = 2500;
		delta_time = 1;
		code = "response";
		port_code = 32;
		code_width = indefinite_port_code; #Tried to use stimulus_event::INDEFINITE_PORT_CODE but throws error.
	} test_response_event;	
} test_trial; 

trial{
	trial_type = specific_response;
	terminator_button = 3, 4;
	incorrect_feedback = sound_only_feedback;
   correct_feedback = sound_only_feedback;
	trial_duration = forever;
	stimulus_event {
		picture {
			text {
				caption = "Squeeze either handle to resume test.";
				font_size = 10;
			}resume_test_caption;
			x = 0; y =0;
			};
		code = "resume";
		port_code = 192;
		code_width = indefinite_port_code; #Tried to use stimulus_event::INDEFINITE_PORT_CODE but throws error. 
		
	}resume_event;
} resume_trial;


# ----------------------------- PCL Program -----------------------------
begin_pcl;

int RESET_OUTPUT_PORT = 0;


# ----------------------------- Stimuli -----------------------------
array<double> stimuli_durations[] = { 1000., 1070., 1145., 1225., 1310., 1402., 1500. };
array<sound> stimuli[stimuli_durations.count()];
array<int> stimuli_port_codes[] = { 68, 72, 76, 80, 84, 88, 92 };

loop
	int i = 1
until 
	i > stimuli_durations.count()
begin
	stimuli[i] = new sound( new wavefile( new asg::sine( stimuli_durations[i], 500., 0. ) ) );
	i = i + 1;
end;

asg::sine response_sound = new asg::sine( 100., 1500., 0. );
correct_sound_event.set_stimulus( new sound( new wavefile( response_sound ) ) );
incorrect_sound_event.set_stimulus( new sound( new wavefile( response_sound ) ) );
blank_sound_event.set_stimulus( new sound( new wavefile( response_sound ) ) );

# ----------------------------- Port Setup -----------------------------
if (input_port_manager.port_count() < 1) then
   exit( "Something wrong with Dynomometer or Arduino, Presentation cannot detect port device." )
end;

set_random_seed( int(logfile.subject()) );					#use participant number as seed

input_port in_port = input_port_manager.get_port( 1 ); 
output_port out_port = output_port_manager.get_port( 1 );
out_port.send_code( RESET_OUTPUT_PORT );

#Constant Integers
double DURATION_CUTOFF = median_value( stimuli_durations ); #First 4 stimulus are short, the rest are long
int ONE_SEC = 1000;
int TWO_SEC = 2000;

output_file outputFile = new output_file;
outputFile.open( logfile.subject() + ".txt", true );
outputFile.print( "Subject Number, Block, Trial Number, Dynomometer Response, Duration\n" );

# ----------------------------- Participant Number -----------------------------

include_once "..\\PCLs\\Participant Number.pcl";


# ----------------------------- Functions ----------------------------------------------

include_once "..\\PCLs\\Import_Functions.pcl";

# ----------------------------- Import Message File ------------------------------------
language_file lang = new language_file;
lang.load( stimulus_directory + "English.xml" );

# ----------------------------- Study Block -------------------------------------------- 
play_instruct_trial( lang.get_text( "Instructions" ) );
out_port.send_code( 1, 100 );
wait_interval(500);
include_once "..\\PCLs\\Study_Block.pcl";
anchor_text.set_caption( "" ); #reset caption since in practice phase we don't show caption along with stimuli
play_break_trial();
play_ITI_trial( ONE_SEC ); #Just a short blank screen between blocks

# ----------------------------- PRACTICE Block ------------------------------------------ 
play_instruct_trial( lang.get_text( Dynanometer_Position ) );
out_port.send_code( 2, 100 );
wait_interval(500);
include_once "..\\PCLs\\Practice_Block.pcl";
play_break_trial();
play_instruct_trial( lang.get_text("Practice Complete Caption" ) );
play_ITI_trial( ONE_SEC ); #Just a short blank screen between blocks


# ----------------------------- TEST Block -----------------------------------------------
out_port.send_code( 3, 100 );
wait_interval(500);
include_once "..\\PCLs\\Test_Block.pcl";

# ----------------------------- END ------------------------------------------------------
wait_interval(1000);
instruct_event.set_port_code( 224 );
play_instruct_trial( lang.get_text( "Completion Screen Caption" ) );
outputFile.close();