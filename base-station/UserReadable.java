
import java.text.SimpleDateFormat;
import java.util.Date;
import net.tinyos.message.Message;
import net.tinyos.message.MessageListener;
import net.tinyos.message.MoteIF;
import net.tinyos.packet.BuildSource;
import net.tinyos.util.PrintStreamMessenger;

/**
 * User readable for our SerialMsg.java
 * @author kcs13
 */
public class UserReadable implements MessageListener{
    private static String source = "serial@/dev/ttyUSB1:micaz";
    
    public static void main(String[] args) {
        MoteIF mote = new MoteIF(BuildSource.makePhoenix(source, PrintStreamMessenger.err));
        mote.registerListener(new SerialMsg(), new UserReadable());
    }

    @Override
    public void messageReceived(int i, Message msg) {
        //Assume it is our message!
        SerialMsg message = (SerialMsg) msg;

        System.out.println("");
        System.out.println("Mote " + message.get_srcid() + " sent at " + new SimpleDateFormat("HH:mm:ss SSS").format(new Date()));
        
        if(message.get_isFire() != 0){
            System.out.println("FIREEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE!!!! RUN FOR YOUR LIVES!!");
        }
        
        System.out.println("Temperature (Raw): " + message.get_temperature());
        System.out.println("Temperature (Kelvin): " + getTemperatureInKelvin(message.get_temperature()));
        System.out.println("Temperature (Celsius): " + getTemperatureInCelsius(message.get_temperature()));
        System.out.println("Light: " + message.get_photo());
    }
    
    private double getTemperatureInKelvin(short tempInADC){
        //if 0 then cannot get Kelvin
        if(tempInADC == 0){
            return Double.NaN;
        }
        
        double a = 0.001010024;
        double b = 0.000242127;
        double c = 0.000000146;
        double Rthr = 10 * (1023 - tempInADC)/(double)tempInADC;
        
        double answer = 1 / (double) (a + (b * Math.log(Rthr)) + (c * Math.pow(Math.log(Rthr), 3)));
        
        return answer;
    }
    
    private double getTemperatureInCelsius(short tempInADC){
        if(tempInADC == 0){
            return Double.NaN;
        }
        
        return getTemperatureInKelvin(tempInADC) - (double) 273;
    }
}
