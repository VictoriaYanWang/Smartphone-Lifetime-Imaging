% PMW generator for smartphone lifetime imaging
%------------------------------------------------------------------------
% NC State UNIVERSITY
% DEPARTMENT OF CHEMICAL AND BIOMOLECULAR ENGINEERING
%------------------------------------------------------------------------
% Author : Yan Wang 
% Date   : 13 March 2023
%------------------------------------------------------------------------
% Questions email to victoria.yan.wang@gmail.com
%------------------------------------------------------------------------
% close all;  
prompt = {'LED Frequency (Hz):', 'LED Duty (%):','Smartphone Video Frame Rate (fps):',...
          'Video Shutter Time (1/ST s):', 'Expected Lifetime (us):', 'Sampling Rate (/s):', 'Drifting Time (us):'};
    
dlgtitle = 'Input';
dims = [1 50; 1 50; 1 50; 1 50; 1 50; 1 50; 1 50];
definput = {'50', '40' ,'30.02', '350', '1000', '10000', '60'};
answer = inputdlg(prompt,dlgtitle,dims,definput);
F = str2double(answer{1});
Dt = str2double(answer{2})*1e-2;
FR = str2double(answer{3});
ST = 1/str2double(answer{4});
LT = str2double(answer{5})*1e-6;    
SR = 1/str2double(answer{6});
DFT = str2double(answer{7})*1e-6;

Sample_duration = 60; % seconds
        

t = 0 : SR : Sample_duration;         % Sampling rate
d_LED = 0 : 1/F : Sample_duration;           % Repetition rate / Frequency of pulses 
d_SP = 0 : 1/FR : Sample_duration; 

xx = 0:SR:1/F*(1-Dt);
d_LT = exp(-xx/LT);
% d_LT = [zeros(1,length(d_LT)-length(d_LT)),d_LT];
% xx = 0:4e-5:1/F;
% figure, plot(xx, d_LT)

% d_LED_LT = [d_LED;d_LT]';

y_LED = pulstran(t,d_LED,@rectpuls,1/F*Dt);
y_LT = pulstran(t+1/F*(1-Dt/2),d_LED,d_LT,1/SR);
y_LT = y_LT.*~y_LED;

% delta = zeros(1,length(y_LED)); delta(randi([0 length(y_LED)]))=1;
% y_LED = cconv(delta,y_LED,length(y_LED));
% y_LT = cconv(delta,y_LT,length(y_LT));


y_SP = pulstran(t,d_SP,@rectpuls,ST);
% delta = zeros(1,length(y_SP)); delta(randi([0 length(y_SP)]))=1;
% y_SP = cconv(delta,y_SP,length(y_SP));




figure,
plot(t,y_LT,'--r','LineWidth', 1.5);
hold on
plot(t,y_LED,'Color',[0.3 0.5 1],'LineWidth', 1.5);
plot(t,y_SP,'Color',[0.7290 0.7940 0.1250],'LineWidth', 1.5);
axis([0 0.2 0 1.5])
title({ ...
    ['F=' num2str(F) 'Hz,', ' Dt=' num2str(Dt*100), '%; LT=' num2str(LT) 's'] ...
    [' f=' num2str(FR) 'fps', ', Shutter=1/' num2str(1/ST) 's']},'color','b','FontSize',12);
xlabel('Time (s)')
ylabel('Waveform')
grid on
grid minor

pgon1 = polyshape([t(1) t t(end)],[0 y_LT 0],'Simplify',false);
pgon2 = polyshape([t(1) t t(end)],[0 y_SP 0],'Simplify',false);
pgon3 = polyshape([t(1) t t(end)],[0 y_LED 0],'Simplify',false);
[polyout1,~,~] = intersect(pgon1,pgon2);
% [polyout2,~,~] = intersect(pgon2,pgon3);
plot(polyout1,'EdgeColor','none','FaceColor','magenta','FaceAlpha',0.25)
% plot(polyout2,'EdgeColor','none','FaceColor','y','FaceAlpha',0.5)


[~,lt,~] = risetime(y_SP,t,'PercentReferenceLevels',[10 80]);
for k=1:length(lt)
       text(lt(k),1.05,['#' num2str(k)],'color',[0.7290 0.7940 0.1250],'FontSize',16,'Clipping','on');
end
% scatter(polyout1.Vertices(:,1),polyout1.Vertices(:,2),'*g')
% scatter(polyout2.Vertices(:,1),polyout2.Vertices(:,2),'*b')
legend('Long Luminescence','LED','V-Chopper', 'Time-Gated Image', 'Fluorescence Signal','TG Vertices','FL Vertices')


loc_NaN = find(isnan(polyout1.Vertices(:,1)));
loc_NaN = [0;loc_NaN];

Intensity_index=zeros(polyout1.NumRegions,2);

for ol_num=1:polyout1.NumRegions
    
    if ol_num<polyout1.NumRegions
        edge=polyout1.Vertices((loc_NaN(ol_num)+1):(loc_NaN(ol_num+1)-1),:);
    else
        edge=polyout1.Vertices((loc_NaN(ol_num)+1):end,:);
    end

    Intensity_index(ol_num,:)=[edge(1,1),polyarea(edge(:,1),edge(:,2))];
    
end

figure, scatter(Intensity_index(1:1:polyout1.NumRegions,1),Intensity_index(1:1:polyout1.NumRegions,2),'r.')
xlabel('Time (s)')
ylabel('Intensity (a.u.)')
% axis([0 30 0 NaN])
title({ ...
    ['F=' num2str(F) 'Hz,', ' D=' num2str(Dt*100), '%;'] ...
    [' f=' num2str(FR) 'fps', ', Shutter=1/' num2str(1/ST) 's']},'color','b','FontSize',12);
% polyarea(polyout1.Vertices(:,1),polyout1.Vertices(:,2));


% figure, plot(pgon1)
% figure, plot(pgon2)


% sig_LED = [t;y_LED]';
% sig_SP = [t;y_SP]';
% sig_LT = [t;y_LT]';
% 
% sim('simulation_LED_Video')
% open_system('simulation_LED_Video/mySimScope') %opens the scope
% axis([0 0.2 0 1.2])
% xlabel('Time (s)')
% ylabel('Waveform')



