/* VernierTutorialAnalogVoltage (v2017)
 * This sketch reads the raw count from a Vernier Analog (BTA) 
 * sensor once every half second, converts it to a voltage, 
 * and prints both values to the Serial Monitor.
 * 
 * Plug the sensor into the Analog 2 port on the Vernier Arduino 
 * Interface Shield or into an Analog Protoboard Adapter wired 
 * to Arduino pin A2.
 */
 
#include <arduino.h>



//Dynomometer specifications can be found in https://www.vernier.com/manuals/hd-bta/
static const float g_slopeN{175.416};   
static const float g_interceptN{-19.295};
static const float g_dynomometerCalibrationN{2.15};
static const float g_ADC_Range{1023};
static const float g_voltageInput{5};
static float g_analog1Threshold{47.5};            //Edit this number to change pressure (Newton) threshold for left Dynomometer
static float g_analog2Threshold{45};            //Edit this number to change pressure (Newton) threshold for right Dynomometer
static const float g_analog1TestThreshold{47.5};   //Edit this number to change pressure (Newton) threshold for TEST phase left Dynomometer
static const float g_analog2TestThreshold{90}; //Edit this number to change pressure (Newton) threshold for TEST phase right Dynomometer

static const unsigned long g_OneHourInMilliSeconds{ 1000l * 60l * 60l };// one hour in milli seconds

static const byte   g_sensorAnalog1{A0};                                //Left Pressure Sensor
static const byte   g_sensorAnalog2{A2};                                //Right Pressure Sensor


static const byte g_bitMaskPin91011{(1 << 3) | (1 << 2) | (1 << 1)};
static const byte g_bitMaskPin2{(1 << 2)};
static const byte g_bitMaskPin13{(1 << 5)};



auto setup() -> void;
auto getDynomometerReadingN(const int sensorValue,
                            const float slope = g_slopeN,
                            const float intercept = g_interceptN,
                            const float ADC_range = g_ADC_Range,
                            const float voltageInput = g_voltageInput, 
                            const float calibration = g_dynomometerCalibrationN) -> float;
auto printCurrentTrial(const byte registers = PINA) -> void;

auto printCurrentStimuli(const byte registers = PINC) -> void;

auto checkCurrentBlock(String& block, byte registers = PING) -> void;

auto sendSignalToPresentation(const int analog1,
                              const int analog2,
                              const int analog1Threshold = g_analog1Threshold,
                              const int analog2Threshold = g_analog2Threshold) -> void;

auto endingConditions(const String&, unsigned long) -> void;


enum class trial
{
  //PINA0, PINA1, and PINA2,
  Response_Period = 1, // 0000 0001
  Stimulus,            // 0000 0010
  Feedback,            // 0000 0011
  ITI,                 // 0000 0100
  Break,               // 0000 0101
  Instructions,        // 0000 0110
  End,                 // 0000 0111
};

enum class stimuli
{
  //PINC0, PINC1, and PINC2,
  _1000 = 1,    // 0000 0001
  _1070,        // 0000 0010
  _1145,        // 0000 0011
  _1225,        // 0000 0100
  _1310,        // 0000 0101
  _1402,        // 0000 0110
  _1500,        // 0000 0111
};

enum class block
{
  //PING0 and PING1
  study = 1, // 0000 0001
  practice,  // 0000 0010
  test,      // 0000 0011
};
 
void setup() 
{
  Serial.begin(9600); //setup communication to display
  
  DDRA |= 0; //sets pins 22, 23, 24 as input.
  DDRC |= 0; //sets pins 35, 36, 37 as input.
  DDRG |= 0; //sets pin 40, 41 as input.

  DDRB |= 0b11; //sets pin 52, 53 as output.
  pinMode(12, INPUT_PULLUP);
}
 
int main() 
{
  init();
  setup();  

  unsigned long startClock{0};
  float analog1Newton;
  float analog2Newton;
  String block{"Beginning"};
  String& blockRef = block;
    
//  Serial.println("Analog1 Pressure (N),Analog2 Pressure (N),Trial Type,Experiment Time Clock (Micro Sec)");

  while(1)
  {
    endingConditions(blockRef, startClock);
    
    if ( !( PINA & 0b111 ) && !startClock )
    {
      continue;                 //The entire programme does and prints nothing until Presentation sends first signal.
    } else if (startClock == 0)
    {
      startClock = micros();    //Remember micros() will overflow after approximately 70 minutes!!!
    }

    checkCurrentBlock(blockRef);
    
    analog1Newton = getDynomometerReadingN(analogRead(g_sensorAnalog1));
    analog2Newton = getDynomometerReadingN(analogRead(g_sensorAnalog2));
    sendSignalToPresentation(analog1Newton, analog2Newton);

    Serial.print(analog1Newton);
    Serial.print(";");
    Serial.print(analog2Newton);
    Serial.print(";");
    printCurrentTrial();
    Serial.print(";");
    printCurrentStimuli();
    Serial.print(";");
    Serial.print(block);
    Serial.print(";");
    Serial.println((micros() - startClock)); //Minus startClock because Arduino clock starts counting at boot up.    
  }  
}


inline auto getDynomometerReadingN(const int sensorValue,
                            const float slope,
                            const float intercept,
                            const float ADC_range,
                            const float voltageInput, 
                            const float calibration) -> float
{
  //This function returns the sensor value of port inputPort in Newtons.
  
  static float voltage;
  static float pressure;
  voltage = (sensorValue/ADC_range)*voltageInput;
  
  pressure = slope*voltage + intercept + calibration;
  return pressure;
}


auto printCurrentTrial(const byte registers) -> void
{
  switch( registers & 0b111 ) //Read first three bits
  {
    case static_cast<uint8_t>(trial::Response_Period):
      Serial.print("Response_Period");
      break;
    case static_cast<uint8_t>(trial::Stimulus):
      Serial.print("Stimulus");
      break;
    case static_cast<uint8_t>(trial::Feedback):
      Serial.print("Feedback");
      break;
    case static_cast<uint8_t>(trial::ITI):
      Serial.print("ITI");
      break;
    case static_cast<uint8_t>(trial::Break):
      Serial.print("Break");
      break;
    case static_cast<uint8_t>(trial::Instructions):
      Serial.print("Instructions_or_others_messages");
      break;
    default:
      Serial.print("No_signal");
      break;
  }
  return;
}

auto printCurrentStimuli(const byte registers) -> void
{
  switch( registers & 0b111 ) //Read first three bits
  {
    case static_cast<uint8_t>(stimuli::_1000):
      Serial.print("1000");                         
      break;
    case static_cast<uint8_t>(stimuli::_1070):
      Serial.print("1070");                         
      break;
    case static_cast<uint8_t>(stimuli::_1145):
      Serial.print("1145");                         
      break;
    case static_cast<uint8_t>(stimuli::_1225):
      Serial.print("1225");                         
      break;
    case static_cast<uint8_t>(stimuli::_1310):
      Serial.print("1310");                         
      break;
    case static_cast<uint8_t>(stimuli::_1402):
      Serial.print("1402");                         
      break;
    case static_cast<uint8_t>(stimuli::_1500):
      Serial.print("1500");                         
      break;  
    default:
      Serial.print("-1");
      break;         
  }
  return;
}

auto checkCurrentBlock(String& blockRef, byte registers) -> void
{
  if (registers)
  {
    switch( registers & 0b111 ) //Read first three bits
    {
      case static_cast<uint8_t>(block::study):
        blockRef = "study";                         
        break;
      case static_cast<uint8_t>(block::practice):
        blockRef = "practice";                         
        break;
      case static_cast<uint8_t>(block::test):
        blockRef = "test"; 
        g_analog1Threshold = g_analog1TestThreshold;  
        g_analog2Threshold = g_analog2TestThreshold;                     
        break;  
      default:
        break; 
    }
  }
  return;
}

auto sendSignalToPresentation(const int analog1Pressure,
                              const int analog2Pressure,
                              const int analog1Threshold,
                              const int analog2Threshold ) -> void
{  
  if( (analog1Pressure >= analog1Threshold) && (analog2Pressure >= analog2Threshold) )
  {
    PORTB |= 0b11;                               //set both outputSignal_pinLeft pin and outputSignal_pinRight pin to HIGH
  } else if( (analog1Pressure >= analog1Threshold) )
  {
    PORTB &= ~0b10;                              //set outputSignal_pinRight pin to LOW
    PORTB |= 0b01;                               //set outputSignal_pinLeft pin to HIGH
  } else if( (analog2Pressure >= analog2Threshold) )
  {
    PORTB &= ~0b01;                              //set outputSignal_pinLeft pin to LOW
    PORTB |= 0b10;                              //set outputSignal_pinRight pin to HIGH
  } else 
  {
    PORTB &= ~0b11;           //set both outputSignal_pinLeft pin and outputSignal_pinRight pin to LOW
  }
}

auto endingConditions(const String& blockRef, unsigned long startClock) -> void
{
  String endReason;
  
  if( !(PINB & (1<<6)) ) //read PB6
  {
    endReason = "End button pressed";
  } else if (millis() > g_OneHourInMilliSeconds)
  {
    endReason = "Experiment_exceeded_1_hour, terminate_automatically";
  } else if (PINA == static_cast<uint8_t>(trial::End))
  {
    endReason = "Experiment_complete";
  } else
  {
    return;
  }
  Serial.print("-1;-1;");
  Serial.print(endReason);
  Serial.print(";");
  printCurrentStimuli();
  Serial.print(";");
  Serial.print(blockRef);
  Serial.print(";");
  Serial.println((micros() - startClock));
  delay(100);
  exit(0);
}
