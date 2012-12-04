function x=pack_david_clusr_for_treemap(c,smp,GO)
%function x=pack_david_clusr_for_treemap(c,smp,GO)
%
%IN:c is an object containing data from a DAVID gene ontology term cluster
%report, generated by query_david.m
%smp is an object with arrays of data concerning the genes
%    see pareto_gui.m
%GO is a gene ontology mapping generated by geneont from a gene ontology
%obo file
%
%OUT:
%   x is a structure encoding the 


x=struct('id','root','name','root_node','data',[]); %root node
%collect all the scores and cluster sizes
for i=1:length(c)
    scz(i)=c(i).getScore;
    rec=c(i).getSimpleChartRecords;
    ntm(i)=length(rec);
end
mscz=max(scz);mntm=max(ntm);
%color the GO term clusters by score, size them by cluster size
%a range of colors from blue to red, one for each decile of score/p-value
cmp={'#0000FF','#1900E6','#3300CC','#4D00B2','#800080','#990066','#B2004C','#CC0033','#E6001A','#FF0000'};
%create a node for each cluster (clus) and set them to be the children of x
for i=1:min(length(c),10)
   rec=c(i).getSimpleChartRecords;%get all the terms in the cluster
   %set the nodes size by the number of GO terms, as a % of the max
   d.area=max(1,round(ntm(i)/mntm*10));%1<=dim,area<=10
   %set the node color as a hex, as a percentage of the largest score 
   pr=max(1,round(scz(i)/mscz*10));
   d.color = cmp{pr};
   d.score = scz(i);
   nm=char(c(i).getName);
   if nm(1)=='G' %if the cluster name is a GO term, deconstruct
       tstr=textscan(nm,'GO:%s%s','delimiter','~');
       nm=tstr{2}{:};
       d.go=str2num(tstr{1}{:});
       id=['clus_' num2str(i) '_GO:' tstr{1}{:}];
   else
       id=['clus_' num2str(i) '_' nm];
   end
   if ~isempty(GO) %if we have GO information and the cluster name is a
       if isfield(d,'go') %GO term, annotate the node with GO term info
           trm=GO(d.go).terms(1);
           if ~isempty(trm.ontology)
               tmp=strrep(trm.ontology,'"','');
               tmp=strrep(tmp,':','');
               d.ont=tmp;
           end
           if ~isempty(trm.definition)
               tmp=strrep(trm.definition,'"','');
               tmp=strrep(tmp,':','');
               d.def=tmp;
           end
       end
   end
   clus=struct('id',id,'name',nm,'data',d);
   %create a node for each GO term in cluster i and set them to be the
   %gtrm are the children of clus(i), one for each GO term
   for j=1:length(rec),pvl(j)=rec(j).getEase;end,mpvl=max(1-pvl);
   for j=1:length(rec)
       %set the size of the node by the number of genes
       d.area=max(1,round(rec(j).getPercent));
       %set the color by p-value as a % of the minimum
       pr=max(1,round((1-pvl(j))/mpvl*10));%set color as a % of smallest pval
       d.color = cmp{pr};
       nm=char(rec(j).getTermName);
       if strcmp(nm(1:3),'GO:') %if the cluster name is a GO term, deconstruct
           tstr=textscan(nm,'GO:%s%s','delimiter','~');
           nm=tstr{2}{:};
           d.go=str2num(tstr{1}{:});
           id=['trm_' num2str(i) '_' num2str(j) '_GO:' tstr{1}{:}];
       else
           id=['trm_' num2str(i) '_' num2str(j) '_' nm];
       end
       if ~isempty(GO) %if we have GO information and the term name is a
           if isfield(d,'go') %GO term, annotate the node with GO term info
             try
               trm=GO(d.go).terms(1);
               if ~isempty(trm.ontology)
                   tmp=strrep(trm.ontology,'"','');
                   tmp=strrep(tmp,':','');
                   d.ont=tmp;
               end
               if ~isempty(trm.definition)
                   tmp=strrep(trm.definition,'"','');
                   tmp=strrep(tmp,':','');
                   d.def=tmp;
               end
             catch me
             end
           end
       end
       d.gns=char(rec(j).getGeneIds);
       d.pval=pvl(j);
       gtrm=struct('id',id,'name',nm,'data',d);
       %parse the gene ids
       gns=textscan(char(rec(j).getGeneIds),'%s','EndOfLine',',');gns=gns{1};
       d.area=d.area/length(gns);
       if ~isempty(smp)
           for k=1:length(gns),idx(k)=find(smp.gid==str2num(gns{k}));end
           mxr=max(smp.prank(idx));
       end
       %create a child node of gtrm
       for k=1:length(gns)
           %extract the screen enrichment data and save in the gene nodes
           if isempty(smp)
               gstr=gns{k};
           else
               gstr=smp.gsymb{idx(k)};
               d.rank=smp.prank(idx(k));
               d.pvl=smp.pval(idx(k));
               d.fc=smp.fc(idx(k));
               pr=floor(d.rank/mxr*10);
               d.color=cmp{max(1,end-pr)};
               gtrm.children(k)=struct('id',...
                   ['gn_' num2str(i) '_' num2str(j) '_' num2str(k) '_' gns{k}],...
                   'name',smp.gsymb{idx(k)},'data',d);
           end
       end
       clus.children(j)=gtrm;
   end
   x.children(i)=clus;
end