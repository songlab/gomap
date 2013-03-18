%script to generate example gene lists to use with GO-map
if ~exist('ref2ent_hsa','var'),load ~/research/fun_genom/data/gene_id_maps/refseq2entrez_hsa.mat;end
refs=ref2ent_hsa.keys;
if ~exist('ent2symb_hsa','var'),load ~/research/fun_genom/data/gene_id_maps/entrez2gsymb_hsa.mat;end
ents=ent2symb_hsa.keys;
if ~exist('symb2ent_hsa','var'),load ~/research/fun_genom/data/gene_id_maps/symb2entrez_hsa.mat;end
gsymbs=symb2ent_hsa.keys;

%entrez ids
f=fopen('example_gene_list_human_entrez_ids.txt','w');
idx=randi(length(ents),100,1);
for i=1:100
    fprintf(f,'%i\t',ents{idx(i)});
    fprintf(f,'%g\t',2*rand(1)-1);
    fprintf(f,'%g\n',rand(1));
end
fclose(f)

%refseq ids
f=fopen('example_gene_list_human_refseq_ids.txt','w');
idx=randi(length(refs),100,1);
for i=1:100
    fprintf(f,'%s\t',refs{idx(i)});
    fprintf(f,'%g\t',2*rand(1)-1);
    fprintf(f,'%g\n',rand(1));
end
fclose(f)

%gene symbols ids
f=fopen('example_gene_list_human_gene_symbols.txt','w');
idx=randi(length(gsymbs),100,1);
for i=1:100
    fprintf(f,'%s\t',gsymbs{idx(i)});
    fprintf(f,'%g\t',2*rand(1)-1);
    fprintf(f,'%g\n',rand(1));
end
fclose(f)