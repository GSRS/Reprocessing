%author: Aizhong Ye; azye@bnu.edu.cn
clear

fname = ['E:\ʦ����Ŀ\��������\Data\ganzipost.txt'];%�޸������ļ�·��������վ����ģ��ʾ������
outpath='E:\ʦ����Ŀ\��������\Data\postprocess\'; %�޸�����ļ�·��

%�����ļ���ˮ��ģ��ģ���ԭʼ����
Ganzi = importdata(fname);%�����ļ���ʽ����	��	��	����	ʵ������	DTVGM	Btop	Swat
id =[ 'TVGM'     %ʾ�������е�3��ˮ��ģ��ģ��������
    'Btop'
    'Swat'    ]
year=Ganzi.data(:,1);
month=Ganzi.data(:,2);
day=Ganzi.data(:,3);
Obs=Ganzi.data(:,5);
nrecs=size(year,1);
nmem = 50;
events=7;
Ebegin=[1	2	3	4	5	6	7	 ];
Eend=[	1	2	3	4	5	6	7	 ];



%GLMPP parameters settings (see Ye et al., 2014,2015)
nf =7;%forecast period % input('enter forecast period in days\n');
na =3;%analysis period % input('enter assimilation period in days\n');
buffer = 15;%buffer period
naf=2*na+nf;



%����ƽ��׼���۲⾶���ĵ����¼� observation
for i=1:nf;
    for j=1:nrecs;
        k=j+Eend(i)- Ebegin(i);
        if (k>nrecs);k=nrecs;end;
        Obsmean(i,j)=mean(Obs(j:k));
    end;
end;


for idk=1:idk %��ʾ�������е�3��ˮ��ģ��ģ�⾶���ֱ����
    ids=strtrim(id(idk,:))
    
    
    Cal=Ganzi.data(:,idk+5);  %6-8��Ϊʾ�������е�3��ˮ��ģ��ģ�⾶��
    
    %����ƽ��׼��ģ�⾶���ĵ����¼� simulation
    for i=1:nf;
        for j=1:nrecs;
            k=j+Eend(i)- Ebegin(i);
            if (k>nrecs);k=nrecs;end;
            Calmean(i,j)=mean(Cal(j:k));
        end;
    end;
    qobsx=Obs(:);
    qsimx=Cal(:);
    qcalx=Cal(:);
    qobsxmean=Obsmean(:,:);
    qsimxmean=Calmean(:,:);
    
    outfilename = [outpath  ids   '_a.txt' ]; %����ļ���
    fida = fopen(outfilename,'w');
    outfilename = [outpath  ids   '_b.txt' ];
    fidb = fopen(outfilename,'w');
    for  i=1:nmem;
        for j=1:nf
            qensx(:,j,i)=qsimx(:);
        end
    end;
    %qresult(1:40,1:12,1:31,1:nf,1:nmem)=0; %�� �� �� Ԥ���� ��Ա
    for jmo=  1:12
        for jday= 1:31
            %     na = 0;
            [jmo jday]
            
            indx = find(month==jmo&day==jday&year>1988&year<2009);%GLMPP���õ���������ݷ�Χ����Ҫ�����޸�
            n = length(indx);  %����
            if (n>0)
                iyr = year(indx(1));
                lyr = year(indx(n));
                nts = 0;
                ndays = nf + na + buffer;
                for i=1:n; %����
                    k1 = indx(i) - floor(buffer/2)-na;
                    if (k1<=0); k1 = 1; end;
                    k2 = k1 + ndays - 1;
                    if (k2>nrecs-Eend(nf)+nf);
                        k2 = nrecs-Eend(nf)+nf;
                        k1 = k2 - ndays + 1;
                    end;
                    nts = nts + 1;
                    for k=k1:k2;
                        qobs_calb(1,nts,k-k1+1) = qobsx(k);
                        qsim_calb(1,nts,k-k1+1) = qsimx(k);
                    end;
                    
                    %canonical events
                    for ce=2:nf+1;
                        for k=k1:k2;
                            kk= k+ Ebegin(ce-1)-ce+1;
                            qobs_calb(ce,nts,k-k1+1) = qobsxmean(ce-1,kk);
                            qsim_calb(ce,nts,k-k1+1) = qsimxmean(ce-1,kk);
                        end;
                    end;
                end;
                
                
                
                
                
                %GLMPP��Ҫ����: ����enspost_sim�������GLMPP����
                nts1=10; % set the number of years to calibrate GLMPP; Currently "enspost_sim" use the first "nts1" years to calibrate GLMPP
                [qobs,qsim,nens,qsim2_ens,a,b] = enspost_sim (qobs_calb,qsim_calb, nts,nts1, na,nf,ndays,jday,jmo,nmem,buffer);  %inputs: qobs_calb: observation streamflow qsim_calb: simulated streamflow,
                
                
                
                
                nts=0;
                for i=1:n; %����
                    k1 = indx(i) - floor(buffer/2)-na;
                    if (k1<=0); k1 = 1; end;
                    k2 = k1 + ndays - 1;
                    if (k2>nrecs);
                        k2 = nrecs;
                        k1 = k2 - ndays + 1;
                    end;
                    k1=k1+floor(buffer/2)+na;
                    qensx(k1,:,:)=qsim2_ens(i,:,:);
                end;
                fprintf(fida, '%2d\t%2d\n',jmo,jday);
                for i=1:nf;
                    fprintf(fida, '%7.4f\t',a(i,:) );
                    fprintf(fida, '\n');
                end;
                %fprintf(fida, '\n');
                fprintf(fidb, '%2d\t%2d\n',jmo,jday);
                for i=1:nf;
                    fprintf(fidb, '%7.4f\t',b(i,:) );
                    fprintf(fidb, '\n');
                end;
            end;
        end;
    end;
    fclose(fida);
    fclose(fidb);
    
    
    
    %��������Ͼ���Ԥ��
    outfilename = [outpath ids   '_result1.txt' ];
    fidr = fopen(outfilename,'w');
    fprintf(fidr, 'YearMonthDay\tLeadT\tObs\tSim\tEnsM\tEMax\tEmin');
    for i=1:nmem;
        fprintf(fidr, '\tEns%d',i);
    end;
    fprintf(fidr, '\n');
    
    indx = find(year>1960 & year<2090);
    for j=1:nf;
        qensm(:,j)=qsimx(:);
    end;
    for i=1:size(indx,1) ;
        k=indx(i);
        for j=1:nf
            %kk=k+j-1;
            kk= k+ Ebegin(j)-1;
            if (kk>nrecs);
                kk = nrecs;
            end;
            qensm(k,j)=mean(qensx(k,j,:));
            fprintf(fidr, '%4d%2.2d%2.2d\t%d\t',year(k),month(k),day(k),j);
            fprintf(fidr, '%4.2f\t', qobsxmean(j,kk) ,qsimxmean(j,kk));
            fprintf(fidr, '%4.2f\t',mean(qensx(k,j,:)),max(qensx(k,j,:)),min(qensx(k,j,:)),qensx(k,j,1:nmem));
            fprintf(fidr, '\n');
        end;
        %qcalx(k) qensx(k1,j,i) qobsx(k) qsimx(k);prec year(indx(i)); month==jmo&day==jday
    end
    fclose(fidr);
    
    
    
    %���ۣ��������ϵ�� Ч��ϵ�� qobsx(k) qensm(k) qcalx(k) qsimx(k)
    for j=1:nf;
        indx1=min(indx+j-1,nrecs);
        xx= corrcoef(qobsx(indx1),qensm(indx,j));
        Rensm(j)=xx(1,2);
        stdx=std(qobsx(indx1));
        Eensm(j)=1-mean((qobsx(indx1)-qensm(indx,j)).*(qobsx(indx1)-qensm(indx,j)))/stdx/stdx;
        Bensm(j)=sum(qobsx(indx1))/sum(qensm(indx,j));
        RMensm(j)=sqrt(mean((qobsx(indx1)-qensm(indx,j)).*(qobsx(indx1)-qensm(indx,j))));
    end;
    xx=corrcoef(qobsx(indx),qcalx(indx));
    Rcal=xx(1,2);
    xx=corrcoef(qobsx(indx),qsimx(indx));
    Rsim=xx(1,2);
    stdx=std(qobsx(indx));
    Ecal=1-mean((qobsx(indx)-qcalx(indx)).*(qobsx(indx)-qcalx(indx)))/stdx/stdx;
    Esim=1-mean((qobsx(indx)-qsimx(indx)).*(qobsx(indx)-qsimx(indx)))/stdx/stdx;
    
    Bcal=sum(qcalx(indx))/ sum(qobsx(indx));
    Bsim=sum(qsimx(indx))/ sum(qobsx(indx));
    
    RMcal=sqrt(mean((qobsx(indx)-qcalx(indx)).*(qobsx(indx)-qcalx(indx))));
    RMsim=sqrt(mean((qobsx(indx)-qsimx(indx)).*(qobsx(indx)-qsimx(indx))));
    
    
    %�������ָ��
    outfilename = [outpath ids   '_RE.txt' ];
    fidr = fopen(outfilename,'w');
    fprintf(fidr, 'LT\tR\tE\tB\tRMSE\n');
    for j=1:nf;
        fprintf(fidr, '%2d\t%4.2f\t%4.2f\t%4.2f\t%4.2f\n',j,Rensm(j),Eensm(j),Bensm(j),RMensm(j) );
    end;
    fprintf(fidr, '%2d\t%4.2f\t%4.2f\t%4.2f\t%4.2f\n',nf+1,Rcal,Ecal,Bcal,RMcal );
    fprintf(fidr, '%2d\t%4.2f\t%4.2f\t%4.2f\t%4.2f\n',nf+2,Rsim,Esim,Bsim,RMsim );
    fclose(fidr);
    
    
    
    %��ͼ
    figure
    set(gcf,'unit','normalized','position',[0.01,0.2,0.98,0.4]);
    subplot(1,4,1);
    bar([Rsim Rensm(1) Rcal])
    set(gca,'position',[0.04,0.1,0.21,0.8]);
    hold on
    title(ids,'FontSize',14,'FontWeight','bold');
    %legend('Rsim','Rensm','Rcal');
    xlabel('Basin','FontSize',12,'FontWeight','bold');
    ylabel('correlation coefficient','FontSize',12,'FontWeight','bold');
    axis([0,3,0,1]);
    
    subplot(1,4,2);
    bar([Esim Eensm(1) Ecal])
    set(gca,'position',[0.29,0.1,0.21,0.8]);
    title(ids,'FontSize',14,'FontWeight','bold');
    %legend('Esim','Eensm','Ecal');
    xlabel('Basin','FontSize',12,'FontWeight','bold');
    ylabel('Nash-Sutcliffe efficiency','FontSize',12,'FontWeight','bold');
    axis([0,3,0,1]);
    
    subplot(1,4,3);
    bar([Bsim-1 Bensm(1)-1 Bcal-1])
    set(gca,'position',[0.54,0.1,0.2,0.8]);
    title(ids,'FontSize',14,'FontWeight','bold');
    xlabel('Basin','FontSize',12,'FontWeight','bold');
    ylabel('Bias','FontSize',12,'FontWeight','bold');
    axis([0,3,-1,1]);
    
    subplot(1,4,4);
    bar([RMsim RMensm(1) RMcal])
    set(gca,'position',[0.78,0.1,0.2,0.8]);
    title(ids,'FontSize',14,'FontWeight','bold');
    legend('Esim','Eensm','Ecal');
    xlabel('Basin','FontSize',12,'FontWeight','bold');
    ylabel('RMSE','FontSize',12,'FontWeight','bold');
    axis([0,3,0,3]);
end