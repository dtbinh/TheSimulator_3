

%To Simulate Velocity Obstacle
%Yazdi Ibrahim Jenie
%2012

%clear all; close all; 
%clc;

%load scenario
%load('Name_Contoh.mat')

%NAgent
%Run simulation===========================================================

ElaTi = 0;
TimeEnd = RecGloPos(1).TimeEnd;
TiSt = RecGloPos(1).TimeStep;
%TiSt = 1;
ttt=300;
dde = 0;
while ElaTi < TimeEnd
    for ii = 1:AgentNumber  %Each Agent Process, still on same phase
        %disp(['hitungan agent ' num2str(ii) '============'])
        %Sensor Sensing...
        VelSens(ii).Sense(Agent(ii).BodVel)
        AttSens(ii).Sense(Agent(ii).WinAtt)
        GPSP(ii).Sense(Agent(ii).GloPos)
        GPSV(ii).Sense(Agent(ii).GloVel)
        
        ProxSensP(ii).Clear()
        ProxSensV(ii).Clear()
        for jj = 1:AgentNumber
            if ii ~= jj
                ProxSensP(ii).SenseAdd(Agent(jj).GloPos)
                ProxSensV(ii).SenseAdd(Agent(jj).GloVel)
            end
        end
        
        %CAS Computer receive all sensor data
        CAS(ii).InputSensor(GPSP(ii).MeasureData,GPSV(ii).MeasureData,...
            VelSens(ii).MeasureData, AttSens(ii).MeasureData, ...
            ProxSensP(ii).MeasureData, ProxSensV(ii).MeasureData)
        %GCS Computer receive all sensor data
        GCS(ii).InputSensor(GPSP(ii).MeasureData,GPSV(ii).MeasureData,...
            VelSens(ii).MeasureData, AttSens(ii).MeasureData,[],[])
        
        %GCS Computer analyzing and deciding
        GCS(ii).GCSRun()
        %ACAS Computer read data from GCS and set info for GCS
        CAS(ii).ReadGCS(GCS(ii).TGoVel)
        %CAS Computer analyzing and deciding
        CAS(ii).ACASRun() 
        %GCS Computer read data and interupt from CAS
        GCS(ii).ReadCAS(CAS(ii).CASFlag,CAS(ii).Decision,CAS(ii).Interupt)

        
        %Put Input on UAV
        %Agent(ii).InputDVel_1(Desicion, Warning)
        Agent(ii).InputDVel_1(GCS(ii).Decision,GCS(ii).CASFlag)
 
    end
    %RECORDING!!!!
    %Update and Record states
    for ii = 1:AgentNumber
        %if there are collision, stop immediately?
        if CAS(ii).CASFlag(1) == 3
            %LastPoint = CAS(ii).ObDist(jj)
            dde = 1;
            gugu = ii;
            %ElaTi
            break
        end
        Agent(ii).MoveTimeD_1(RecGloPos(1).TimeStep)
        dde=0;
    end
    
    if dde == 1;
        Collisi(mci) = 2;
        break; 
    end
    dde = 0;
    ElaTi = ElaTi + TiSt;
    Collisi(mci) = 1;
end
EndDist = CAS(1).ObDist(1:AgentNumber-1,1);






