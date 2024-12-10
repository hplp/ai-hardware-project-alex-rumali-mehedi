%clc;
%clear all;
%close all;
% To read edf file of subject_3
[a, b]= edfread("D:\verilog\SLEEP_APNEA\EEG_Matlab\EEG_subjectwise_Datbase\ucddb003.edf");
%c=b(4,:);
c=a.C3A2;  %C3A2 and C4A1 represents EEG signals column in the complete database of Subject_3
d=a.C4A1;
%e=(c+d)/2; 
%time domain averaging
%------------------pre-processing----------------------------------%

%----------------------butterworth bandpass filter------------------%
L=length(c);
eeg2=[];
eeg4=[];
for i=1:L
   eeg1=c{i,1} ;
   eeg2=cat(1,eeg2,eeg1);
end

for i=1:L
   eeg3=d{i,1} ;
   eeg4=cat(1,eeg4,eeg3);
end

e=(eeg2+eeg4)/2; 


fp=0.25; % Passband frequency
fs=40;   % Stopband frequency
f=128;   % Sampling frequency
wp=2*(fp/f);
ws=2*(fs/f);
filtOrd=4; % Order of the bandpass filter is 4 (4th Order filter)

%Eqn to calculate the coefficient of the BPF

BPFCoeff= designfilt('bandpassiir','FilterOrder',filtOrd, ...
'HalfPowerFrequency1',fp,'HalfPowerFrequency2',fs,'SampleRate',f);

g=filter(BPFCoeff,e);


fp_d=0.25;   % passband of delta band
fs_d=4;      % stopband of delta band
wp_d=2*(fp_d/f);
ws_d=2*(fs_d/f);
BPFCoeff= designfilt('bandpassiir','FilterOrder',filtOrd, ...
'HalfPowerFrequency1',fp_d,'HalfPowerFrequency2',fs_d,'SampleRate',f);
eeg(1)={filter(BPFCoeff,g)};

fp_t=4; %theta band
fs_t=8;
wp_t=2*(fp_t/f);
ws_t=2*(fs_t/f);
BPFCoeff= designfilt('bandpassiir','FilterOrder',filtOrd, ...
'HalfPowerFrequency1',fp_t,'HalfPowerFrequency2',fs_t,'SampleRate',f);
eeg(2)={filter(BPFCoeff,g)};

fp_a=8; %alpha band
fs_a=12;
wp_a=2*(fp_a/f);
ws_a=2*(fs_a/f);
BPFCoeff= designfilt('bandpassiir','FilterOrder',filtOrd, ...
'HalfPowerFrequency1',fp_a,'HalfPowerFrequency2',fs_a,'SampleRate',f);
eeg(3)={filter(BPFCoeff,g)};

fp_s=12; %sigma band
fs_s=16;
wp_s=2*(fp_s/f);
ws_s=2*(fs_s/f);
BPFCoeff= designfilt('bandpassiir','FilterOrder',filtOrd, ...
'HalfPowerFrequency1',fp_s,'HalfPowerFrequency2',fs_s,'SampleRate',f);
eeg(4)={filter(BPFCoeff,g)};


fp_b=16; %beta band
fs_b=40;
wp_b=2*(fp_b/f);
ws_b=2*(fs_b/f);
BPFCoeff= designfilt('bandpassiir','FilterOrder',filtOrd, ...
'HalfPowerFrequency1',fp_b,'HalfPowerFrequency2',fs_b,'SampleRate',f);
eeg(5)={filter(BPFCoeff,g)};

%---------------------segmentation for 5 bands--------------------------%
% Read the subject_3 data in excell format for reading start time, end time
x1= xlsread("D:\verilog\SLEEP_APNEA\EEG_Matlab\EEG_Subjectwise_database_Excell\ucddb003.xlsx");
ap_st=floor(x1(:,1));           % apnea start time
ap_dur=floor(x1(:,5));          % apnea duration
ap_end=floor(ap_st+ap_dur);     % apnea end time

lengt= length(ap_st);

for rr=1:5
  nor_eegc{1,rr}(1)={eeg{1,rr}(1:ap_st(1)*128-1)};
  nor_eegc{1,rr}(lengt+1)={eeg{1,rr}((ap_end(lengt)*128+1):(length(g)))};
  ap_eegc{1,rr}(1)={eeg{1,rr}(ap_st(1)*128:ap_end(1)*128-1)};

for i=2:lengt
    nor_eeg=eeg{1,rr}(ap_end(i-1)*128+38400+1:ap_st(i)*128-1);
    nor_eegc{1,rr}(i)={nor_eeg}; % Normal EEG extracted in cells
    ap_eeg=eeg{1,rr}(ap_st(i)*128:(ap_end(i))*128-1);
    ap_eegc{1,rr}(i)={ap_eeg};% Apnea EEG extracted in cells
   
end
end

s=0;s1=0;
t4=zeros(1,lengt);t5=zeros(1,lengt);t6=zeros(1,lengt);t7=zeros(1,lengt);
for u= 1:lengt
    if ap_dur(u)>=10 && ap_dur(u)<=19
        t4(u)=s+1;
    elseif ap_dur(u)>=19 && ap_dur(u)<=29
        t5(u)=s+2;
    elseif ap_dur(u)>=30 && ap_dur(u)<=39
        t6(u)=s+3;
    elseif ap_dur(u)>=40
        t7(u)=s+4;
    end
end
t8=t4'+t5'+t6'+t7';
fr = sum(t8);



for ww=1:5
    ee=1;
    apn= cell(1,fr);
    for q=1:lengt
        len=length(ap_eegc{1,ww}{1,q});
        if len>=1280 && len<=2432
           apn(ee)={ap_eegc{1,ww}{1,q}(1:1280)};
           ee=ee+1;

        elseif len>=2560 && len<=3712
                apn(ee)={ap_eegc{1,ww}{1,q}(1:1280)};
                apn(ee+1)={ap_eegc{1,ww}{1,q}(1281:2560)};
                ee=ee+2;
               
        elseif len>=3840 && len<=4992
                apn(ee)={ap_eegc{1,ww}{1,q}(1:1280)};
                apn(ee+1)={ap_eegc{1,ww}{1,q}(1281:2560)};
                apn(ee+2)={ap_eegc{1,ww}{1,q}(2561:3840)};
                ee=ee+3;  
        elseif len>=5120 && len<=6272
                apn(ee)={ap_eegc{1,ww}{1,q}(1:1280)};
                apn(ee+1)={ap_eegc{1,ww}{1,q}(1281:2560)};
                apn(ee+2)={ap_eegc{1,ww}{1,q}(2561:3840)};
                apn(ee+3)={ap_eegc{1,ww}{1,q}(3841:5120)};
                ee=ee+4;  
        end
    end
    apnea10{ww}=apn;
end

for tt=1:5
    energy=cell(1,fr);
    kurt=cell(1,fr);
    skew=cell(1,fr);
    iqrr=cell(1,fr);
    ass=cell(1,fr);
    integral=cell(1,fr);
    activity=cell(1,fr);
    mobility=cell(1,fr);
    mad1=cell(1,fr);
    com1=cell(1,fr);
    %Z1234APBETA=[]
    for zz=1:fr
    z1=apnea10{1,tt}{1,zz};
    energy(zz)={sum(z1.^2)};
    kurt(zz)={kurtosis(z1)};
    skew(zz)={skewness(z1)};
    iqrr(zz)={iqr(z1)};
    ass(zz)={sum(sqrt(abs(z1)))};
    integral(zz)={sum(abs(z1))};
    activity(zz)={var(z1)};
    mobility(zz)={sqrt(var(diff(z1))/var(z1))};
    mad1(zz)={mad(z1)};
    com1(zz)={(sqrt(var(diff(diff(z1)))/var(diff(z1))))/(sqrt(var(diff(z1))/var(z1)))};
    end
    energy10{tt}=transpose(energy);
    kurtosis10{tt}=transpose(kurt);
     skew10{tt}=transpose(skew);
      iqr10{tt}=transpose(iqrr);
       ass10{tt}=transpose(ass);
        kurtosis10{tt}=transpose(kurt);
         integral10{tt}=transpose(integral);
         activity10{tt}=transpose(activity);
         mobility10{tt}=transpose(mobility);
         mad10{tt}=transpose(mad1);
        com10{tt}=transpose(com1);
end  
ef=[]
ef1=[]
ef2=[]
ef3=[]
ef4=[]
ef5=[]
ef6=[]
ef7=[]
ef8=[]
ef9=[]
for j=1:5
   z1=energy10{1,j}
   z12=kurtosis10{1,j}
   z13=skew10{1,j}
   z14=iqr10{1,j}
   z15=ass10{1,j}
   z16=integral10{1,j}
   z17=activity10{1,j};
   z18=mobility10{1,j};
   z19=mad10{1,j};
   z20=com10{1,j};
   ef=cat(2,ef,z1);
    ef1=cat(2,ef1,z12);
     ef2=cat(2,ef2,z13);
      ef3=cat(2,ef3,z14);
       ef4=cat(2,ef4,z15);
        ef5=cat(2,ef5,z16);
        ef6=cat(2,ef6,z17);
        ef7=cat(2,ef7,z18);
        ef8=cat(2,ef8,z19);
        ef9=cat(2,ef9,z20);
end
op=ones(fr);
op={op(1:fr,1)}
featureapnea=cat(2,ef,ef1,ef2,ef3,ef4,ef5,ef6,ef7,ef8,ef9);
normal1= [];
  normal2= [];
    normal3= [];
    normal4= [];
    normal5= [];
    
    
    for j=1:lengt+1
       nor = nor_eegc{1,1}{1,j};
       normal1 = cat(2,normal1,nor);
         nor2 = nor_eegc{1,2}{1,j};
       normal2 = cat(2,normal2,nor2);
          nor3 = nor_eegc{1,3}{1,j};
       normal3 = cat(2,normal3,nor3);
       nor4 = nor_eegc{1,4}{1,j};
       normal4 = cat(2,normal4,nor4);
          nor5 = nor_eegc{1,5}{1,j};
       normal5 = cat(2,normal5,nor5);
    end
 energy_apnea_delta=[];
 energy_apnea_theta=[];
 energy_apnea_alpha=[];
 energy_apnea_sigma=[];
 energy_apnea_beta=[];

  kurt_apnea_delta=[];
 kurt_apnea_theta=[];
 kurt_apnea_alpha=[];
 kurt_apnea_sigma=[];
 kurt_apnea_beta=[];


   mob_apnea_delta=[];
 mob_apnea_theta=[];
 mob_apnea_alpha=[];
 mob_apnea_sigma=[];
 mob_apnea_beta=[];

 act_apnea_delta=[];
 act_apnea_theta=[];
 act_apnea_alpha=[];
 act_apnea_sigma=[];
 act_apnea_beta=[];
 
 skew_apnea_delta=[];
 skew_apnea_theta=[];
 skew_apnea_alpha=[];
 skew_apnea_sigma=[];
 skew_apnea_beta=[];
 
 iqr_apnea_delta=[];
 iqr_apnea_theta=[];
 iqr_apnea_alpha=[];
 iqr_apnea_sigma=[];
 iqr_apnea_beta=[];
 
 ass_apnea_delta=[];
  ass_apnea_theta=[];
  ass_apnea_alpha=[];
  ass_apnea_sigma=[];
  ass_apnea_beta=[];
  
  in_apnea_delta=[];
  in_apnea_theta=[];
 in_apnea_alpha=[];
 in_apnea_sigma=[];
  in_apnea_beta=[];

    mad_apnea_delta=[];
 mad_apnea_theta=[];
 mad_apnea_alpha=[];
 mad_apnea_sigma=[];
  mad_apnea_beta=[];

 com_apnea_delta=[];
 com_apnea_theta=[];
 com_apnea_alpha=[];
 com_apnea_sigma=[];
  com_apnea_beta=[];
t111=[]
t1111=[]
     for k=0:fr-1
       t1=normal1(1,1+(1280*k):(1280*k)+1280);
        t2=normal2(1,1+(1280*k):(1280*k)+1280);
         t3=normal3(1,1+(1280*k):(1280*k)+1280);
          t4=normal4(1,1+(1280*k):(1280*k)+1280);
           t5=normal5(1,1+(1280*k):(1280*k)+1280);
           t111=cat(2,t111,t5);
           t1111=cat(2,t1111,t1);
             energy_apnea_delta1 = sum(t1.^2);
    energy_apnea_theta1 = sum(t2.^2);
    energy_apnea_alpha1 = sum(t3.^2);
    energy_apnea_sigma1 = sum(t4.^2);
    energy_apnea_beta1 = sum(t5.^2);

            mad_apnea_delta1 = mad(t1);
    mad_apnea_theta1 = mad(t2);
    mad_apnea_alpha1 = mad(t3);
    mad_apnea_sigma1 = mad(t4);
    mad_apnea_beta1 = mad(t5);

     kurt_apnea_delta1 = kurtosis(t1);
    kurt_apnea_theta1 = kurtosis(t2);
    kurt_apnea_alpha1 = kurtosis(t3);
    kurt_apnea_sigma1 =kurtosis(t4);
    kurt_apnea_beta1 = kurtosis(t5);
     
      
    skew_apnea_delta1 = skewness(t1);
    skew_apnea_theta1 =skewness(t2);
    skew_apnea_alpha1 = skewness(t3);
    skew_apnea_sigma1 = skewness(t4);
    skew_apnea_beta1 = skewness(t5);

      act_apnea_delta1 = var(t1);
    act_apnea_theta1 =var(t2);
    act_apnea_alpha1 = var(t3);
    act_apnea_sigma1 = var(t4);
    act_apnea_beta1 = var(t5);
    

     mob_apnea_delta1 = sqrt(var(diff(t1))/var(t1));
    mob_apnea_theta1 =sqrt(var(diff(t2))/var(t2));
    mob_apnea_alpha1 = sqrt(var(diff(t3))/var(t3));
    mob_apnea_sigma1 = sqrt(var(diff(t4))/var(t4));
    mob_apnea_beta1 = sqrt(var(diff(t5))/var(t5));

    com_apnea_delta1 = (sqrt(var(diff(diff(t1)))/var(diff(t1))))/(sqrt(var(diff(t1))/var(t1)));
    com_apnea_theta1 =(sqrt(var(diff(diff(t2)))/var(diff(t2))))/(sqrt(var(diff(t2))/var(t2)));
    com_apnea_alpha1 = (sqrt(var(diff(diff(t3)))/var(diff(t3))))/(sqrt(var(diff(t3))/var(t3)));
    com_apnea_sigma1 = (sqrt(var(diff(diff(t4)))/var(diff(t4))))/(sqrt(var(diff(t4))/var(t4)));
    com_apnea_beta1 = (sqrt(var(diff(diff(t5)))/var(diff(t5))))/(sqrt(var(diff(t5))/var(t5)));
    

    iqr_apnea_delta1 =iqr(t1);
    iqr_apnea_theta1 =iqr(t2);
    iqr_apnea_alpha1 = iqr(t3);
    iqr_apnea_sigma1 = iqr(t4);
    iqr_apnea_beta1 = iqr(t5);
    
     in_apnea_delta1 =sum(abs(t1));
   in_apnea_theta1 =sum(abs(t2));
   in_apnea_alpha1 =sum(abs(t3));
   in_apnea_sigma1 = sum(abs(t4));
   in_apnea_beta1 = sum(abs(t5));
    
    ass_apnea_delta1 =sum(sqrt(abs(t1)));
   ass_apnea_theta1 =sum(sqrt(abs(t2)));
    ass_apnea_alpha1 = sum(sqrt(abs(t3)));
    ass_apnea_sigma1 =sum(sqrt(abs(t4)));
   ass_apnea_beta1 = sum(sqrt(abs(t5)));
  
         energy_apnea_delta= cat(1,energy_apnea_delta,energy_apnea_delta1);
     energy_apnea_theta=cat(1,energy_apnea_theta,energy_apnea_theta1);
     energy_apnea_alpha=cat(1,energy_apnea_alpha,energy_apnea_alpha1);
     energy_apnea_sigma=cat(1,energy_apnea_sigma,energy_apnea_sigma1);
     energy_apnea_beta=cat(1,energy_apnea_beta,energy_apnea_beta1);

         mad_apnea_delta= cat(1,mad_apnea_delta,mad_apnea_delta1);
     mad_apnea_theta=cat(1,mad_apnea_theta,mad_apnea_theta1);
     mad_apnea_alpha=cat(1,mad_apnea_alpha,mad_apnea_alpha1);
     mad_apnea_sigma=cat(1,mad_apnea_sigma,mad_apnea_sigma1);
     mad_apnea_beta=cat(1,mad_apnea_beta,mad_apnea_beta1);

      mob_apnea_delta= cat(1,mob_apnea_delta,mob_apnea_delta1);
     mob_apnea_theta=cat(1,mob_apnea_theta,mob_apnea_theta1);
     mob_apnea_alpha=cat(1,mob_apnea_alpha,mob_apnea_alpha1);
     mob_apnea_sigma=cat(1,mob_apnea_sigma,mob_apnea_sigma1);
     mob_apnea_beta=cat(1,mob_apnea_beta,mob_apnea_beta1);

         act_apnea_delta= cat(1,act_apnea_delta,act_apnea_delta1);
     act_apnea_theta=cat(1,act_apnea_theta,act_apnea_theta1);
     act_apnea_alpha=cat(1,act_apnea_alpha,act_apnea_alpha1);
     act_apnea_sigma=cat(1,act_apnea_sigma,act_apnea_sigma1);
     act_apnea_beta=cat(1,act_apnea_beta,act_apnea_beta1);



       kurt_apnea_delta= cat(1,kurt_apnea_delta,kurt_apnea_delta1);
     kurt_apnea_theta=cat(1,kurt_apnea_theta,kurt_apnea_theta1);
     kurt_apnea_alpha=cat(1, kurt_apnea_alpha, kurt_apnea_alpha1);
     kurt_apnea_sigma=cat(1, kurt_apnea_sigma, kurt_apnea_sigma1);
     kurt_apnea_beta=cat(1, kurt_apnea_beta, kurt_apnea_beta1);
     
     in_apnea_delta= cat(1, in_apnea_delta, in_apnea_delta1);
     in_apnea_theta=cat(1, in_apnea_theta, in_apnea_theta1);
     in_apnea_alpha=cat(1,  in_apnea_alpha,  in_apnea_alpha1);
    in_apnea_sigma=cat(1,  in_apnea_sigma,  in_apnea_sigma1);
      in_apnea_beta=cat(1, in_apnea_beta,  in_apnea_beta1);
     
     skew_apnea_delta= cat(1,skew_apnea_delta,skew_apnea_delta1);
     skew_apnea_theta=cat(1,skew_apnea_theta,skew_apnea_theta1);
     skew_apnea_alpha=cat(1, skew_apnea_alpha, skew_apnea_alpha1);
     skew_apnea_sigma=cat(1, skew_apnea_sigma,skew_apnea_sigma1);
     skew_apnea_beta=cat(1, skew_apnea_beta, skew_apnea_beta1);
     
      iqr_apnea_delta= cat(1, iqr_apnea_delta, iqr_apnea_delta1);
      iqr_apnea_theta=cat(1, iqr_apnea_theta, iqr_apnea_theta1);
      iqr_apnea_alpha=cat(1,  iqr_apnea_alpha,  iqr_apnea_alpha1);
      iqr_apnea_sigma=cat(1,  iqr_apnea_sigma,  iqr_apnea_sigma1);
      iqr_apnea_beta=cat(1,  iqr_apnea_beta,  iqr_apnea_beta1);
      
      ass_apnea_delta= cat(1,   ass_apnea_delta,   ass_apnea_delta1);
       ass_apnea_theta=cat(1,   ass_apnea_theta,   ass_apnea_theta1);
        ass_apnea_alpha=cat(1,   ass_apnea_alpha,   ass_apnea_alpha1);
       ass_apnea_sigma=cat(1,    ass_apnea_sigma,  ass_apnea_sigma1);
       ass_apnea_beta=cat(1,   ass_apnea_beta,   ass_apnea_beta1);

         com_apnea_delta= cat(1,   com_apnea_delta,   com_apnea_delta1);
       com_apnea_theta=cat(1,   com_apnea_theta,  com_apnea_theta1);
        com_apnea_alpha=cat(1,   com_apnea_alpha,  com_apnea_alpha1);
       com_apnea_sigma=cat(1,    com_apnea_sigma,  com_apnea_sigma1);  
        com_apnea_beta=cat(1, com_apnea_beta, com_apnea_beta1);
    end
   
   
energyapnea=cat(2,energy_apnea_delta,energy_apnea_theta,energy_apnea_alpha,energy_apnea_sigma,energy_apnea_beta);
 kurtapnea=cat(2, kurt_apnea_delta, kurt_apnea_theta, kurt_apnea_alpha, kurt_apnea_sigma, kurt_apnea_beta)
madapnea=cat(2,mad_apnea_delta,mad_apnea_theta,mad_apnea_alpha,mad_apnea_sigma,mad_apnea_beta);

 skewapnea=cat(2,skew_apnea_delta,skew_apnea_theta,skew_apnea_alpha,skew_apnea_sigma,skew_apnea_beta);
 iqrapnea=cat(2,iqr_apnea_delta,iqr_apnea_theta,iqr_apnea_alpha,iqr_apnea_sigma,iqr_apnea_beta);
  mobapnea=cat(2,mob_apnea_delta,mob_apnea_theta,mob_apnea_alpha,mob_apnea_sigma,mob_apnea_beta);
 assapnea=cat(2,ass_apnea_delta,ass_apnea_theta,ass_apnea_alpha,ass_apnea_sigma,ass_apnea_beta);
  actapnea1=cat(2,act_apnea_delta,act_apnea_theta,act_apnea_alpha,act_apnea_sigma,act_apnea_beta);
 inapnea=cat(2,in_apnea_delta,in_apnea_theta,in_apnea_alpha,in_apnea_sigma,in_apnea_beta);
 comapnea=cat(2,com_apnea_delta,com_apnea_theta,com_apnea_alpha,com_apnea_sigma,com_apnea_beta);
  

NORMALbeta=transpose(t111);
NORMALbeta=NORMALbeta(1:215040)
NORMALDELTA=transpose(t1111);
NORMALDELTA=NORMALDELTA(1:215040)
writematrix(NORMALbeta,"C:\Users\project_AI_Hardware\Desktop\normalbeta_2.txt")
writematrix(NORMALDELTA,"C:\Users\project_AI_Hardware\Desktop\normaldelta_2.txt")
 z3=[];
 nonapneafeature=cat(2,energyapnea,kurtapnea,skewapnea,iqrapnea,assapnea,inapnea,actapnea1,mobapnea,madapnea, comapnea);
   deltaapnea=[]
   betaapnea=[]
    for zz=1:fr
    z1=apnea10{1,1}{1,zz};
     z2=apnea10{1,5}{1,zz};
    z1=transpose(z1);
    z2=transpose(z2);
   deltaapnea=(cat(1,deltaapnea,z1));
   betaapnea=(cat(1,betaapnea,z2));
  
    end
       deltaapnea=   deltaapnea(1:215040)
         betaapnea=     betaapnea(1:215040)
    writematrix(deltaapnea,"C:\Users\project_AI_Hardware\Desktop\apneadelta_2.txt")
       writematrix(betaapnea,"C:\Users\project_AI_Hardware\Desktop\apneabeta_2.txt")




       x=timetable2table(a);
y=table2array(x(:,5));
z=cell2mat(y);
w=table2array(x(:,6));
z1=cell2mat(w);
c=transpose(z);
d=transpose(z1);



overalldeltaqpoint=int64(OVERALLDELTA2*8192);
max(abs(overalldeltaqpoint))
overallbetaqpoint=int64(OVERALLBETA2*8192);
max(abs(overallbetaqpoint))

