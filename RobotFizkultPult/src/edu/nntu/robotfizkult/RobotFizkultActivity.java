package edu.nntu.robotfizkult;

import java.io.IOException;
import java.io.OutputStreamWriter;
import java.net.Socket;



import android.os.Bundle;
import android.os.Handler;
import android.app.Activity;
import android.view.Menu;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.View.OnTouchListener;
import android.widget.Button;
import android.widget.Toast;

public class RobotFizkultActivity extends Activity {
	public static final String CMD_FORWARD = "F";
	public static final String CMD_BACKWARD = "B";
	public static final String CMD_LEFT = "L";
	public static final String CMD_RIGHT = "R";
	public static final String CMD_STOP = "S";
	
	public static final String CMD_FORWARD_UP = "A";//"FU";
	public static final String CMD_FORWARD_DOWN = "T";//"FD";
	public static final String CMD_BACKWARD_UP = "U";//"BU";
	public static final String CMD_BACKWARD_DOWN = "V";//"BD";
	public static final String CMD_LEFT_UP = "W";//"LU";
	public static final String CMD_LEFT_DOWN = "X";//"LD";
	public static final String CMD_RIGHT_UP = "Y";//"RU";
	public static final String CMD_RIGHT_DOWN = "Z";//"RD";
	

	public static final String ADDRESS_DEFAULT = "192.168.43.191";
	public static final int PORT_DEFAULT = 44300;
	
	private Socket socket;
	private OutputStreamWriter out;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_robot_fizkult);
        
        final Button btnF = (Button)findViewById(R.id.btn_f);
        btnF.setOnTouchListener(onTouchListener);
        
        final Button btnB = (Button)findViewById(R.id.btn_b);
        btnB.setOnTouchListener(onTouchListener);
        
        final Button btnL = (Button)findViewById(R.id.btn_l);
        btnL.setOnTouchListener(onTouchListener);
        
        final Button btnR = (Button)findViewById(R.id.btn_r);
        btnR.setOnTouchListener(onTouchListener);
        
        final Button btnFU = (Button)findViewById(R.id.btn_f_u);
        btnFU.setOnClickListener(onClickListener);
        
        final Button btnFD = (Button)findViewById(R.id.btn_f_d);
        btnFD.setOnClickListener(onClickListener);
        
        final Button btnBU = (Button)findViewById(R.id.btn_b_u);
        btnBU.setOnClickListener(onClickListener);
        
        final Button btnBD = (Button)findViewById(R.id.btn_b_d);
        btnBD.setOnClickListener(onClickListener);
        
        final Button btnLU = (Button)findViewById(R.id.btn_l_u);
        btnLU.setOnClickListener(onClickListener);
        
        final Button btnLD = (Button)findViewById(R.id.btn_l_d);
        btnLD.setOnClickListener(onClickListener);
        
        final Button btnRU = (Button)findViewById(R.id.btn_r_u);
        btnRU.setOnClickListener(onClickListener);
        
        final Button btnRD = (Button)findViewById(R.id.btn_r_d);
        btnRD.setOnClickListener(onClickListener);
    }


    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.robot_fizkult, menu);
        return true;
    }
    
    private OnTouchListener onTouchListener = new OnTouchListener() {

		@Override
		public boolean onTouch(View v, MotionEvent event) {
			if (event.getAction() == MotionEvent.ACTION_DOWN) {
				switch (v.getId()) {
				case R.id.btn_f:
					sendToCarBackground(CMD_FORWARD);
					break;
				case R.id.btn_b:
					sendToCarBackground(CMD_BACKWARD);
					break;
				case R.id.btn_l:
					sendToCarBackground(CMD_LEFT);
					break;
				case R.id.btn_r:
					sendToCarBackground(CMD_RIGHT);
					break;
				}
			} else if (event.getAction() == MotionEvent.ACTION_UP) {
				sendToCarBackground(CMD_STOP);
			}
			return false;
		}
	};
	
	private OnClickListener onClickListener = new OnClickListener() {

		@Override
		public void onClick(View v) {
			switch (v.getId()) {
			case R.id.btn_f_u:
				sendToCarBackground(CMD_FORWARD_UP);
				break;
			case R.id.btn_f_d:
				sendToCarBackground(CMD_FORWARD_DOWN);
				break;
			case R.id.btn_b_u:
				sendToCarBackground(CMD_BACKWARD_UP);
				break;
			case R.id.btn_b_d:
				sendToCarBackground(CMD_BACKWARD_DOWN);
				break;
			case R.id.btn_l_u:
				sendToCarBackground(CMD_LEFT_UP);
				break;
			case R.id.btn_l_d:
				sendToCarBackground(CMD_LEFT_DOWN);
				break;
			case R.id.btn_r_u:
				sendToCarBackground(CMD_RIGHT_UP);
				break;
			case R.id.btn_r_d:
				sendToCarBackground(CMD_RIGHT_DOWN);
				break;
			}
		}
		
	};
        
    void sendToCar(final String address, final int port, final String cmd) {
		boolean connected = false;
		if (out != null) {
			try {
				System.out.println(cmd);
				writeToCar(cmd);
				connected = true;
			} catch (IOException e) {
				System.out.println("Failed connection, try reconnect.");
			}
		}
		if (!connected) {
			try {
				connectToCar(address, port);
				writeToCar(cmd);
			} catch (Exception e) {
				e.printStackTrace();
				handler.post(new Runnable(){
					@Override
					public void run() {
						Toast.makeText(RobotFizkultActivity.this, "Failed connection.", Toast.LENGTH_LONG)
						.show();
					}});				
			}
		}
	}
	
	private Handler handler = new Handler();

	void writeToCar(String cmd) throws IOException {
		out.write(cmd);
		out.flush();
	}

	private boolean sendingCommand = false;

	void sendToCarBackground(final String cmd) {
		sendToCarBackground(ADDRESS_DEFAULT, PORT_DEFAULT, cmd);
	}
	void sendToCarBackground(final String address, final int port,
			final String cmd) {
		new Thread(new Runnable() {

			@Override
			public void run() {
				if (!sendingCommand) {
					sendingCommand = true;
					sendToCar(address, port, cmd);
					sendingCommand = false;
				}
			}

		}).start();
	}

	void connectToCar(String address, int port) throws Exception {
		socket = new Socket(address, port);
		out = new OutputStreamWriter(socket.getOutputStream());
	}
}
