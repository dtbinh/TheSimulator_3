%a Master file for the three-D simulator
clear all; clc; close all;
%initialization of.. 2 vehicle? actually, yusing teh VO frame, the choice
%is just relative velocity inside the CC. So set the distance and the
%ownship velocity (just keep these contsnat). Then choose a random relative
%velocity (ranging form 0? to double the speed of Vo) and direction inside the cone!, then you can get the
%obstacle velocity (all in 3D?). Assuming a ball separation.

%%
%Making the world.... making the object==================================
AgentNumber = 8;
tSimTiR = 15; %Recording Alocation
tTiStR = 0.2; %Recording Save
VOpPoints = zeros(60000,1);
VOpPoints2 = zeros(10000,1);
VOpEscPoints = zeros(60000,1);
load('CASData.mat'); %the velocity and distance data of the spheres
for tii = 1:AgentNumber
    Agent(tii) = UAV(1,1,1,1,0,...
                 [0; 0; 0],[0; 0; 0],[0; 0; 0]);
                
    %Generate Sensor accordingly (Acc,Err,Rang,iData)
    VelSens(tii) = Sensor(1,0,100,[0; 0; 0]);
    AttSens(tii) = Sensor(1,0,100,[0; 0; 0]);
    GPSP(tii) = Sensor(1,0,100,[0; 0; 0]);
    GPSV(tii) = Sensor(1,0,100,[0;0;0]);
    ProxSensP(tii) = Sensor(1,0,40000,[0; 0; 0]);
    ProxSensV(tii) = Sensor(1,0,40000,[0; 0; 0]);
        
    %CASManager?
    
    GCS(tii) = GCS001([0; 0; 0],[0; 0; 0],[[0; 0; 0] [0; 0; 0]]);
    CAS(tii) = CAS004([0; 0; 0],[0; 0; 0],[[0; 0; 0] [0; 0; 0]],...
                       1,2,ImpoDist,ImpoVelo); %Last two --> ImpoDist and ImpoVelo
        
    %BlackBox, with simulation properties
    RecXYZ_g(tii) = FDRecord('XYZ_g',tSimTiR,tTiStR,3);
    RecUVW_g(tii) = FDRecord('XYZ_g',tSimTiR,tTiStR,3);
    RecVTP_g(tii) = FDRecord('XYZ_g',tSimTiR,tTiStR,3);
    RecExpVO(tii) = FDRecord('VO',tSimTiR,tTiStR,4); 
    
    
    RecVOpVe(tii) = FDRecord('VO',tSimTiR,tTiStR,60000);
    RecVOpVe2(tii) = FDRecord('VO',tSimTiR,tTiStR,10000); %Vix, Viy, VTgoal across agent(50) across VOPvee(50)
    RecVOpEscOp(tii) = FDRecord('VO',tSimTiR,tTiStR,60000); %the point and AvoPlane? of escape
    RecDecision(tii) = FDRecord('VO',tSimTiR,tTiStR,6); %actually the decision - pointV (3), and AVO, and interupt?
    %RecVOpEsc1(tii) = FDRecord('VO',tSimTiR,tTiStR,200000);
    %RecVOpEsc2(tii) = FDRecord('VO',tSimTiR,tTiStR,200000);
    RecVOpNum(tii) = FDRecord('VO',tSimTiR,tTiStR,50); %all scalar number
    
    RecODist(tii) = FDRecord('ODist',tSimTiR,tTiStR,50); 
    RecOFlag(tii) = FDRecord('ODist',tSimTiR,tTiStR,204);
end
%========================================================================


%%
%Initializations -========================================================
%From the VO frame? but imposible for more than 2. Should
%it be a superconflict generator? Orjust for two? JUST OFR TWO. FOCUS:
%Reciprocality
%So Initilaization based on the CC framework - ensure conflict

%Agent - 0, ownship
PooG = [0; 0; 0]; %seting the origin ALWAYS
XYZ_g(:,1) = [0;0;0];%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
VooA = 2; %designated 
UVW_b(:,1) = [VooA;0;0];%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
UVW_g(:,1) = UVW_b(:,1);
VTP_g(:,1) = [0;0;0];%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Veeo = 0; %its zero (designated)
VooElv = -70/180*pi; %on symmteric plane, up 45 degree from the VO base lane
VooAzz = 56/180*pi;
Voo = [VooA*sin(pi/2-VooElv)*cos(VooAzz); 
       VooA*sin(pi/2-VooElv)*sin(VooAzz);
       VooA*cos(pi/2-VooElv)]; %the equation is for inclination, hence the pi/2 -
VeG(:,1) = Voo;
Dist = 10; %designated distance, time to collision min 5 second
Rsep = 1; %designeated protected sphere
%From here, the CC can be generated
ThetaBVO = asin(Rsep/Dist);
LimElvVO = [-ThetaBVO ThetaBVO];
LimAzzVO = [-ThetaBVO ThetaBVO];
%the CC/VO parameter
RVO = Rsep*(Dist^2-Rsep^2)^0.5/Dist;
DVO = (Dist^2-Rsep^2)/Dist;

%pick a relative velocity
%LETS SET one case first. If it works, then randomize
RelVelA = 0.75*VooA*2; %rand(1)*(Voo*2); %because the max rand is 2 times the Voo
%pick the Elev and Azz? --> set 0.8 and 0.7 as below.
RelVElv = LimElvVO(1)+0.75*range(LimElvVO); %LimElvVO(1)+rand(1)*range(LimElvVO);
RelVAzz = LimAzzVO(1)+0.75*range(LimAzzVO); %LimAzzVO(1)+rand(1)*range(LimAzzVO);
RelVel = [RelVelA*sin(pi/2-RelVElv)*cos(RelVAzz); 
          RelVelA*sin(pi/2-RelVElv)*sin(RelVAzz);
          RelVelA*cos(pi/2-RelVElv)]; %the equation is for inclination, hence the pi/2 -

%which then make the Obstacle velocity:
Vio = Voo-RelVel;
VioA = (sum(Vio.^2))^0.5;
UVW_b(:,2) = [VioA;0;0];%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

% Plot it first?

ObsPos = [Dist; 0; 0];

%above s just the setup --> testing the cases which difficult to be determined in the bofy frame of reference . The visualization should always be on the ownshp
%frame of reference
%rotation matrix to make all of them on ownship body axis...
RotMatP = [cos(-VooAzz) sin(-VooAzz) 0; -sin(-VooAzz) cos(-VooAzz) 0 ; 0 0 1]; %3D turning to heading
RotMatT = [cos(-VooElv) 0 -sin(-VooElv); 0 1 0; sin(-VooElv) 0 cos(-VooElv)];
RotMatV = [1 0 0; 0 cos(0) sin(0); 0 -sin(0) cos(0)];
MatB2E = RotMatP*RotMatT*RotMatV; %reversed angles!
R2Bod0 = MatB2E;
VooB =  R2Bod0*Voo;
UVWo = VooB;
VTPo = [0; 0; 0];
ObsPosB = R2Bod0*ObsPos;

XYZ_g(:,2) = ObsPosB;%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
VoiG = R2Bod0*Vio;
UVW_g(:,2) = VoiG;
VioB = R2Bod0*Vio;
UVWi = VioB;
%VTPi = [0; acos(VioB(3)/(VioA)); atan2(VioB(2),VioB(1))];
VTPi = [0; -atan2(VioB(3),((VioB(2)^2+VioB(1)^2)^0.5)); atan2(VioB(2),VioB(1))];
VTP_g(:,2) = VTPi;%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Aa1 = VTP_g(:,2);
RelVelB = R2Bod0*RelVel;

%The end of the road
Tifin = 1000; %until it stop. Does not matter
XYZfin_g = XYZ_g + UVW_g*Tifin;%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%=========================================================================

%% Dumd Scenario
XYZ_g = [0 10+10/(3^0.5) 10+10/(3^0.5) 20; 
         0 10/(3^0.5) -10/(3^0.5) 0;
         0 -10/(3^0.5) -10/(3^0.5) 0];
UVW_g = [2 -2/(3^0.5) -2/(3^0.5) -2;
         0 -2/(3^0.5) 2/(3^0.5) 0;
         0 2/(3^0.5) 2/(3^0.5) 0];
UVW_b = [2 2 2 2; 0 0 0 0; 0 0 0 0];
VTP_g = [0 0 0 0;
         0 -atan2(1,0.5*2^0.5)*180/pi-90 (atan2(1,0.5*2^0.5)*180/pi-90) 0;
         0 90-45 90-45 180]/180*pi;
VTP_g(:,2) = [0; -atan2(UVW_g(3,2),((UVW_g(2,2)^2+UVW_g(1,2)^2)^0.5)); atan2(UVW_g(2,2),UVW_g(1,2))];
VTP_g(:,3) = [0; -atan2(UVW_g(3,3),((UVW_g(2,3)^2+UVW_g(1,3)^2)^0.5)); atan2(UVW_g(2,3),UVW_g(1,3))];
XYZsta_g = XYZ_g - UVW_g*Tifin/1000;
XYZfin_g = XYZ_g + UVW_g*Tifin;

DecMode = [1; 1; 1; 1];
ADist = [10; 10; 10; 10];

Cube8;
%%

%if you want scenario visualization======================================
%InitialVisualization; %three figure, CCframe, CC, VO. NOT A FUNCTION!
%=========================================================================

%%
%Puting Init Value into Objects =========================================
%dynamic parameter
NTurnRate = 10/180*pi;
GoalvPath = 0.01;

ATurnRate = 10/180*pi;

VOpPo = 0:2*pi/36:2*pi; 
VOpVee = -pi/2:pi/12:pi/2;

for tii = 1:AgentNumber
    Agent(tii).SetInit(XYZ_g(:,tii),UVW_b(:,tii),VTP_g(:,tii))
    %Generate Sensor accordingly (Acc,Err,Rang,iData)
    VelSens(tii).SetInit(UVW_b(:,tii));
    AttSens(tii).SetInit(VTP_g(:,tii));
    GPSP(tii).SetInit(XYZ_g(:,tii));
    %CASManager?
    GCS(tii).SetInit(UVW_b(:,tii),VTP_g(:,tii),[XYZsta_g(:,tii) XYZfin_g(:,tii)],NTurnRate,GoalvPath);
    CAS(tii).SetInit(UVW_b(:,tii),VTP_g(:,tii),[XYZsta_g(:,tii) XYZfin_g(:,tii)],ATurnRate,ADist(tii),VOpPo,VOpVee,DecMode(tii));
    
    RecXYZ_g(tii).AddRecord(Agent(tii).GloPos)
    RecXYZ_g(tii).AddRecord2(XYZfin_g(:,tii))
    RecXYZ_g(tii).AddRecord2(XYZsta_g(:,tii))
    RecUVW_g(tii).AddRecord(Agent(tii).GloVel)
    RecVTP_g(tii).AddRecord(Agent(tii).GloAtt)
    %RecODist(tii).AddRecord([0;0;0;0])
    %[tii AvoW(tii,1) AvoTy(tii,1)]
end
Agent(1).SetInit(XYZ_g(:,1)+[0;0;0],[2;0;0],VTP_g(:,1))
Agent(2).SetInit(XYZ_g(:,2)+[0;0;0],[2;0;0],VTP_g(:,2))
%========================================================================

%save InitCond

%%
%Now move it - move it. 
%just solve the navigation equation in every time step?
ElaTi = 0;
TimeEnd = RecXYZ_g(1).TimeEnd;
TiSt = 0.1;
%TiSt = 1;
ttt=300;
dde = 0;
while ElaTi < TimeEnd
    for ii = 1:AgentNumber  %Each Agent Process, still on same phase
        
        disp([num2str(ElaTi) '  hitungan agent ' num2str(ii) '============'])
        %Sensor Sensing...
        VelSens(ii).Sense(Agent(ii).BodVel)
        AttSens(ii).Sense(Agent(ii).GloAtt)
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
            VelSens(ii).MeasureData, AttSens(ii).MeasureData,...
            ProxSensP(ii).MeasureData, ProxSensV(ii).MeasureData)
        
        %Avoidance Computer
        GCS(ii).GCSRun()                                                   %GCS Computer analyzing and deciding
        CAS(ii).ReadGCS(GCS(ii).TGoVel)                                    %CAS Computer read data from GCS and set info for GCS
        CAS(ii).ACASRun()                                                  %CAS Computer analyzing and deciding
        
        GCS(ii).ReadCAS(CAS(ii).CASFlag,CAS(ii).Decision,CAS(ii).Interupt) %GCS Computer read data and interupt from CAS

        %Put Input on UAV
        %Agent(ii).InputDVel_1(Desicion, Warning)
        Agent(ii).InputD(GCS(ii).Decision,GCS(ii).CASFlag)
 
    end
    
    %Update and Record states --> only after all Vehicles decide
    for ii = 1:AgentNumber
        %if there are collision, stop immediately?
        
        disp([num2str(ElaTi) '  '  num2str(mod(ElaTi,1))])
        if abs(mod((round(ElaTi*100))/100,tTiStR)) <= 0.000001
        RecXYZ_g(ii).AddRecord(Agent(ii).GloPos)
        RecUVW_g(ii).AddRecord(Agent(ii).GloVel)
        RecVTP_g(ii).AddRecord(Agent(ii).GloAtt) 
        RecODist(ii).AddRecord(CAS(ii).ObDist)
        RecOFlag(ii).AddRecord([CAS(ii).CASFlag(1,:)'; CAS(ii).CASFlag(2,:)'; CAS(ii).CASFlag(3,:)'; CAS(ii).CASFlag(4,:)'])
        
        dd = 1;
        ee = 1;
        %saving private ryan
%         for bb = 1:length(VOpVee) %many avo pl
%             VOpPoints2(ee) = CAS(ii).VOPv2(1,bb);
%             VOpPoints2(ee+1) = CAS(ii).VOPv2(2,bb);
%             ee = ee+2;
%            for aa = 1:AgentNumber-1
%                %VOpEscPo(ff) = CAS(ii).VOpIntNumUn(12,smething,oo);
%                %ff = ff+1;
%                VOpPoints2(ee) = CAS(ii).VOPv2(2*aa+1,bb);
%                Aaa = CAS(ii).VOPv2(2*aa+1,bb);
%                VOpPoints2(ee+1) = CAS(ii).VOPv2(2*aa+2,bb);
%                Bbb = CAS(ii).VOPv2(2*aa+2,bb);
%                ee = ee+2;
%               for cc = 1:length(VOpPo) %many point
%                   VOpPoints(dd) = CAS(ii).VOPv(1,cc,bb,aa);
%                   VOpPoints(dd+1) = CAS(ii).VOPv(2,cc,bb,aa);
%                   VOpPoints(dd+2) = CAS(ii).VOpNum(bb,aa);
%                   VOpPoints(dd+3) = CAS(ii).VOpEscOp(cc,bb,aa);
%                   dd = dd+4;
%               end
%            end
%         end
%         disp('hahahaha')
%         RecVOpVe(ii).AddRecord(VOpPoints);
%         RecVOpVe2(ii).AddRecord(VOpPoints2);
%         RecVOpEscOp(ii).AddRecord(VOpEscPoints);
        end

        if ii == 2
            Aa2 = Agent(ii).GloAtt;
            Bb2 = Agent(ii).GloPos;
        end

        Agent(ii).MoveTimeD_3(TiSt)

        dde=0;
    end

    ElaTi = ElaTi + TiSt;
end

EndDist = CAS(1).ObDist(1:AgentNumber-1,1);
save Record RecXYZ_g RecUVW_g RecVTP_g RecODist RecOFlag AgentNumber Rsep
%save RecordVO RecVOpVe RecVOpVe2 RecVOpEscOp VOpVee VOpPo AgentNumber Rsep
clear all;
%=====================================================================
%%
MoveVisualization
%========================================================================
%%























