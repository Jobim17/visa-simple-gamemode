
#include <YSI_Coding\y_hooks>

//-----------------------------------------------------------------------------

#define MOVE_SPEED              100.0
#define ACCEL_RATE              0.03

#define CAMERA_MODE_NONE    	0
#define CAMERA_MODE_FLY     	1

#define MOVE_FORWARD    		1
#define MOVE_BACK       		2
#define MOVE_LEFT       		3
#define MOVE_RIGHT      		4
#define MOVE_FORWARD_LEFT       5
#define MOVE_FORWARD_RIGHT      6
#define MOVE_BACK_LEFT          7
#define MOVE_BACK_RIGHT         8

//-----------------------------------------------------------------------------

enum noclipenum
{
	cameramode,
	flyobject,
	mode,
	lrold,
	udold,
	lastmove,
	Float:accelmul
}

new noclipdata[MAX_PLAYERS][noclipenum];
new gUpdateNC[MAX_PLAYERS] = {-1, ...};

//-----------------------------------------------------------------------------

hook OnGameModeExit()
{
	foreach (new i : Player)
	{
		if(noclipdata[i][cameramode] == CAMERA_MODE_FLY) CancelFlyMode(i);
	}
	return Y_HOOKS_CONTINUE_RETURN_1;
}

hook OnPlayerConnect(playerid)
{
	// No-Clip
	noclipdata[playerid][cameramode] 	= CAMERA_MODE_NONE;
	noclipdata[playerid][lrold]	   	 	= 0;
	noclipdata[playerid][udold]   		= 0;
	noclipdata[playerid][mode]   		= 0;
	noclipdata[playerid][lastmove]   	= 0;
	noclipdata[playerid][accelmul]   	= 0.0;
	return Y_HOOKS_CONTINUE_RETURN_1;
}

hook OnPlayerDisconnect(playerid, reason)
{
	KillTimer(gUpdateNC[playerid]);
	gUpdateNC[playerid] = -1;
	return Y_HOOKS_CONTINUE_RETURN_1;
}

forward UpdateNoClip(playerid);
public UpdateNoClip(playerid)
{
	if(noclipdata[playerid][cameramode] == CAMERA_MODE_FLY)
	{
		new keys,ud,lr;
		GetPlayerKeys(playerid,keys,ud,lr);

		if(noclipdata[playerid][mode] && (GetTickCount() - noclipdata[playerid][lastmove] > 100))
		{
		    MoveCamera(playerid);
		}

		if(noclipdata[playerid][udold] != ud || noclipdata[playerid][lrold] != lr)
		{
			if((noclipdata[playerid][udold] != 0 || noclipdata[playerid][lrold] != 0) && ud == 0 && lr == 0)
			{   
				StopPlayerObject(playerid, noclipdata[playerid][flyobject]);
				noclipdata[playerid][mode]      = 0;
				noclipdata[playerid][accelmul]  = 0.0;
			}
			else
			{   

				noclipdata[playerid][mode] = GetMoveDirectionFromKeys(ud, lr);

				MoveCamera(playerid);
			}
		}
		noclipdata[playerid][udold] = ud; noclipdata[playerid][lrold] = lr; 
		return 0;
	}
	return 1;
}

GetMoveDirectionFromKeys(ud, lr)
{
	new direction = 0;
	
    if(lr < 0)
	{
		if(ud < 0) 		direction = MOVE_FORWARD_LEFT; 	// Up & Left key pressed
		else if(ud > 0) direction = MOVE_BACK_LEFT; 	// Back & Left key pressed
		else            direction = MOVE_LEFT;          // Left key pressed
	}
	else if(lr > 0) 	// Right pressed
	{
		if(ud < 0)      direction = MOVE_FORWARD_RIGHT;  // Up & Right key pressed
		else if(ud > 0) direction = MOVE_BACK_RIGHT;     // Back & Right key pressed
		else			direction = MOVE_RIGHT;          // Right key pressed
	}
	else if(ud < 0) 	direction = MOVE_FORWARD; 	// Up key pressed
	else if(ud > 0) 	direction = MOVE_BACK;		// Down key pressed
	
	return direction;
}

MoveCamera(playerid)
{
	new Float:FV[3], Float:CP[3];
	GetPlayerCameraPos(playerid, CP[0], CP[1], CP[2]);          
    GetPlayerCameraFrontVector(playerid, FV[0], FV[1], FV[2]);  

	if(noclipdata[playerid][accelmul] <= 1) noclipdata[playerid][accelmul] += ACCEL_RATE;

	new Float:speed = MOVE_SPEED * noclipdata[playerid][accelmul];

	new Float:X, Float:Y, Float:Z;
	GetNextCameraPosition(noclipdata[playerid][mode], CP, FV, X, Y, Z);
	MovePlayerObject(playerid, noclipdata[playerid][flyobject], X, Y, Z, speed);

	noclipdata[playerid][lastmove] = GetTickCount();
	return 1;
}

GetNextCameraPosition(move_mode, const Float:CP[3], const Float:FV[3], &Float:X, &Float:Y, &Float:Z)
{
    #define OFFSET_X (FV[0]*6000.0)
	#define OFFSET_Y (FV[1]*6000.0)
	#define OFFSET_Z (FV[2]*6000.0)
	switch(move_mode)
	{
		case MOVE_FORWARD:
		{
			X = CP[0]+OFFSET_X;
			Y = CP[1]+OFFSET_Y;
			Z = CP[2]+OFFSET_Z;
		}
		case MOVE_BACK:
		{
			X = CP[0]-OFFSET_X;
			Y = CP[1]-OFFSET_Y;
			Z = CP[2]-OFFSET_Z;
		}
		case MOVE_LEFT:
		{
			X = CP[0]-OFFSET_Y;
			Y = CP[1]+OFFSET_X;
			Z = CP[2];
		}
		case MOVE_RIGHT:
		{
			X = CP[0]+OFFSET_Y;
			Y = CP[1]-OFFSET_X;
			Z = CP[2];
		}
		case MOVE_BACK_LEFT:
		{
			X = CP[0]+(-OFFSET_X - OFFSET_Y);
 			Y = CP[1]+(-OFFSET_Y + OFFSET_X);
		 	Z = CP[2]-OFFSET_Z;
		}
		case MOVE_BACK_RIGHT:
		{
			X = CP[0]+(-OFFSET_X + OFFSET_Y);
 			Y = CP[1]+(-OFFSET_Y - OFFSET_X);
		 	Z = CP[2]-OFFSET_Z;
		}
		case MOVE_FORWARD_LEFT:
		{
			X = CP[0]+(OFFSET_X  - OFFSET_Y);
			Y = CP[1]+(OFFSET_Y  + OFFSET_X);
			Z = CP[2]+OFFSET_Z;
		}
		case MOVE_FORWARD_RIGHT:
		{
			X = CP[0]+(OFFSET_X  + OFFSET_Y);
			Y = CP[1]+(OFFSET_Y  - OFFSET_X);
			Z = CP[2]+OFFSET_Z;
		}
	}
}

CancelFlyMode(playerid)
{
	DeletePVar(playerid, "FlyMode");
	CancelEdit(playerid);
	TogglePlayerSpectating(playerid, false);

	DestroyPlayerObject(playerid, noclipdata[playerid][flyobject]);
	noclipdata[playerid][cameramode] = CAMERA_MODE_NONE;

	KillTimer(gUpdateNC[playerid]);
    gUpdateNC[playerid] = -1;

	return 1;
}

StartFlyMode(playerid)
{
	new Float:X, Float:Y, Float:Z;
	GetPlayerPos(playerid, X, Y, Z);
	noclipdata[playerid][flyobject] = CreatePlayerObject(playerid, 19300, X, Y, Z, 0.0, 0.0, 0.0);

	TogglePlayerSpectating(playerid, true);
	AttachCameraToPlayerObject(playerid, noclipdata[playerid][flyobject]);

	SetPVarInt(playerid, "FlyMode", 1);
	noclipdata[playerid][cameramode] = CAMERA_MODE_FLY;

	gUpdateNC[playerid] = SetTimerEx("UpdateNoClip", 250, true, "i", playerid);
	return 1;
}

IsFlyMode(playerid)
{
	return GetPVarInt(playerid, "FlyMode");
}