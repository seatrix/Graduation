function[mseq]=m_sequence(fbconnection,m_initial_phase) 
%***********************************************
%eg: Polynome is x5+x2+1,fbconnection=[0 1 0 0 1];
%***********************************************
n=length(fbconnection); 
N=(2^n-1);  
% if m_initialstate==1 
%     register=[zeros(1,n-1) 1];  %��λ�Ĵ����ĳ�ʼ״̬ 
% else
%     register=[1 0 1 zeros(1,n-3)];  %��λ�Ĵ����ĳ�ʼ״̬ 
% end
register=m_initial_phase;

mseq(1)=register(n);        %m���еĵ�һ�������Ԫ 
    
for j=2:n          
newregister(j)=register(j-1);     
end;      
register=newregister;     
mseq(i)=register(n); 
end  

