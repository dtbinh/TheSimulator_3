clear all;
load('RecordVO.mat')
VOpPoiX = zeros(AgentNumber,AgentNumber-1,...
                length(VOpVee),length(VOpPo),RecVOpVe(1).Elapsed-1);
VOpPoiY = VOpPoiX;
VOpPoiS = VOpPoiX;
for ii = 1:AgentNumber
    nn = 1;
    for jj = 1:AgentNumber-1
        for kk = 1:length(VOpVee)
            for ll = 1:length(VOpPo)
                for mm = 1:RecVOpVe(1).Elapsed-1
                    %some(agnetNo,xyz,time)
                    aa = size(RecVOpVe(ii).Data(nn,mm));
                    VOpPoiX(ii,jj,kk,ll,mm) = RecVOpVe(ii).Data(nn,mm);
                    VOpPoiY(ii,jj,kk,ll,mm) = RecVOpVe(ii).Data(nn+1,mm);
                    VOpPoiS(ii,jj,kk,ll,mm) = RecVOpVe(ii).Data(nn+2,mm);
                end
                nn = nn+3;
            end
        end

    end
end
%for first agent, make 2 x 2 subplot
Poi = zeros(2,length(VOpPo));
Col = 'brmgk';
figure(30); 
for jj = 1:AgentNumber-1
    for kk = 1:12
        subplot(4,3,kk); grid on;
        
        Poi(1,:) = VOpPoiX(1,jj,kk,:,1);
        Poi(2,:) = VOpPoiY(1,jj,kk,:,1);
        VOpPol(kk) = line(Poi(1,:),Poi(2,:),'Color',Col(jj));
        axis([0 3 -1 1]); hold on;
    end
end

%move it?
for mm = 2:RecVOpVe(1).Elapsed-1
    for kk = 1:12
        PoiX(1,:) = VOpPoiX(1,jj,kk,:,mm);
        PoiX(2,:) = VOpPoiY(1,jj,kk,:,mm);
        set(VOpPol(kk),'XData',PoiX(1,:),'YData',PoiX(2,:))    
        
    end
    pause(0.1)
end
