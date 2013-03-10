function varargout = david_tool(varargin)
% DAVID_TOOL MATLAB code for david_tool.fig
%      DAVID_TOOL, by itself, creates a new DAVID_TOOL or raises the existing
%      singleton*.
%
%      H = DAVID_TOOL returns the handle to a new DAVID_TOOL or the handle to
%      the existing singleton*.
%
%      DAVID_TOOL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DAVID_TOOL.M with the given input arguments.
%
%      DAVID_TOOL('Property','Value',...) creates a new DAVID_TOOL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before david_tool_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to david_tool_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help david_tool

% Last Modified by GUIDE v2.5 22-Jan-2013 17:04:34

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @david_tool_OpeningFcn, ...
                   'gui_OutputFcn',  @david_tool_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before david_tool is made visible.
function david_tool_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to david_tool (see VARARGIN)

% Choose default command line output for david_tool
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);

if length(varargin)>0,smp=varargin{1};else,smp=[];end
main_data.id_type='ENTREZ gene ID';
if strcmp(smp.genome{3},'hg19'),main_data.species='Homo sapien';
elseif strcmp(smp.genome{3},'mm9'),main_data.species='Mus musculus';end
main_data.fc=smp.fc;
main_data.tt=smp.tt;
main_data.pval=smp.pval;
main_data.prank=smp.prank;
main_data.nsh=smp.nsh;
main_data.mlodz=smp.mlodz;
main_data.gsymb=smp.gsymb;
main_data.gid=smp.gid;
main_data.eml=get(handles.edit2,'String');
main_data.vis_dir='';
main_data.pname=smp.pname;
main_data.screen_pcut=smp.screen_pcut;
main_data.gexp_pcut=smp.gexp_pcut;
main_data.glists_textbox=smp.glists_textbox;
main_data.main_glst=smp.main_glst;
pareto_root_data=get(smp.pareto_gui_root_handle,'UserData');
if ~pareto_root_data.java_loaded
    h=waitbar(0,'loading java packaes. This only needs to be done once per session.');
    d=dir('david_java_client/lib/*.jar');
    wt=linspace(1/length(d),1,length(d));
    for i=1:length(d)
        s=fullfile(['david_java_client/lib/' d(i).name]);
        waitbar(wt(i),h,{'Loading java package:',strrep(s,'_','\_')})
        javaaddpath(s);   
    end
    import david.xsd.*;
    import org.apache.axis2.AxisFault;
    import sample.session.client.util.*;
    import sample.session.service.xsd.*;
    import sample.session.client.stub.*;
    delete(h);
    pareto_root_data.java_loaded=1;
    set(smp.pareto_gui_root_handle,'UserData',pareto_root_data);
end
if isempty(pareto_root_data.GO),
    wb=waitbar(0.5,'Loading gene ontology data. This needs to be done once per session.');
    main_data.GO=geneont('file','gene_ontology.obo');
    pareto_root_data.GO=main_data.GO;
    set(smp.pareto_gui_root_handle,'UserData',pareto_root_data);
    delete(wb);
else
    main_data.GO=pareto_root_data.GO;
end
%enter genes into the working list window
for i=1:length(main_data.gsymb),gs{i}=main_data.gsymb{i};end
set(handles.glist_textbox,'String',gs,'UserData',gs);
set(handles.david_tool_root,'UserData',main_data);


% UIWAIT makes david_tool wait for user response (see UIRESUME)
% uiwait(handles.david_tool_root);


% --- Outputs from this function are returned to the command line.
function varargout = david_tool_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1
main_data=get(handles.david_tool_root,'UserData');
contents = cellstr(get(hObject,'String'));
main_data.id_type=contents{get(hObject,'Value')};
set(handles.david_tool_root,'UserData',main_data);

% --- Executes during object creation, after setting all properties.
function glist_textbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to glist_textbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in query_david_pushbutton.
function query_david_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to query_david_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
main_data=get(handles.david_tool_root,'UserData');
if isempty(main_data.eml)
    alert('title','Enter an email in the edit box which is registered with DAVID','String','No valid email found.');
    return;
end
gns=get(handles.glist_textbox,'String');%query DAVID only on the genes in the working genelist
gids=[];j=1;                              %so loook up their ENTREZ IDs
for i=1:length(gns)
    idx=min(find(strcmpi(gns{i},main_data.gsymb)));
    if ~isempty(idx),gids(j)=main_data.gid(idx);j=j+1;end
end
c=query_david(gids,main_data.eml);
x=pack_david_clusr_for_treemap(c,main_data,main_data.GO);
gene_clusts={};
for i=1:length(x.children) %10 clusters at most, set the radio button string for each
    gene_clusts{i}=[];
    for j=1:length(x.children(i).children)
       D=textscan(x.children(i).children(j).data.gns,'%n','Delimiter',',');
       gene_clusts{i}=union(gene_clusts{i},D{1}); 
    end
    eval(['set(handles.c' num2str(i) '_button,''String'',x.children(' num2str(i) ').name,''Value'',1)']);
end
set(handles.all_button,'Value',1);
main_data.gene_clusts=gene_clusts;
clear c;
pause(0.5);
outdir=uigetdir(main_data.pname,'Please select a directory where I can save your visualizations.');
if ~outdir, delete(h);return;end
main_data.vis_dir=outdir;
set(handles.david_tool_root,'UserData',main_data);
h=waitbar(0.25,'Writting javascript files');
js=make_treemap_json_from_david(x);
unzip(which('david_clustering.zip'),outdir);
f=fopen(fullfile(outdir,'david_clustering','data.js'),'w');
fprintf(f,'var json_data = %s;',js);
fclose(f);
waitbar(0.75,h,'Spawning web browser')
if ispc, dos(['start ' fullfile(outdir,'david_clustering','david_treemap.html') ' &']);
elseif ismac, unix(['open ' fullfile(outdir,'david_clustering','david_treemap.html') ' &']);
else unix(['firefox ' fullfile(outdir,'david_clustering','david_treemap.html') ' &']);end
%web(['file://' fullfile(outdir,'david_clustering','david_treemap.html')],'-browser')
waitbar(0.9,h,'Packaging web files for you to use later')
if get(handles.to_file_radiobutton,'Value')
    [fname pname]=uiputfile(fullfile(outdir,'david_cluster_report.zip'));
    if ~isequal(fname,0)&~isequal(pname,0),zip(fullfile(pname,fname),fullfile(outdir,'david_clustering'));end
    f=fopen(fullfile(ctfroot,'david_cluster_report.txt'));
    g=fopen(fullfile(pname,[fname '_goterm_list.csv']),'w');
    D=textscan(f,'%s%n%n','Delimiter',',');
    for i=1:length(D{1})
        fprintf(g,'%s,',D{1}{i});
        fprintf(g,'%g,',D{2}(i));
        fprintf(g,'%g\n',D{3}(i));
    end
    fclose(f);fclose(g);
end
delete(h)

% --- Executes on selection change in glist_textbox.
function glist_textbox_Callback(hObject, eventdata, handles)
% hObject    handle to glist_textbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns glist_textbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from glist_textbox
gnz=get(hObject,'UserData');
s=gnz{get(hObject,'Value')};
main_data=get(handles.david_tool_root,'UserData');
glst_ids=get(handles.glist_textbox,'UserData');
idx=min(find(strcmpi(s,main_data.gsymb)));
set(handles.screen_rank_textbox,'String',num2str(main_data.prank(idx)));
if main_data.pval(idx)<=main_data.screen_pcut
    set(handles.screen_pval_textbox,'String',num2str(main_data.pval(idx)),'ForegroundColor','r');
else
    set(handles.screen_pval_textbox,'String',num2str(main_data.pval(idx)),'ForegroundColor','k');
end
set(handles.nsh_textbox,'String',num2str(main_data.nsh(idx)));
if main_data.tt(idx)==-1,
    set(handles.ttest_textbox,'String','NA');
    set(handles.exp_fc_textbox,'String','NA');    
else
    if main_data.tt(idx)<=main_data.gexp_pcut
        set(handles.ttest_textbox,'String',num2str(main_data.tt(idx)),'ForegroundColor','r');
    else
        set(handles.ttest_textbox,'String',num2str(main_data.tt(idx)),'ForegroundColor','k');
    end
    set(handles.exp_fc_textbox,'String',num2str(main_data.fc(idx)));
end
set(handles.mlodz_textbox,'String',num2str(main_data.mlodz(idx)));
if isfield(main_data,'net_cent_comb')
    set(handles.net_cent_textbox,'String',num2str(main_data.net_cent_comb(idx)));
end


function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double
main_data=get(handles.david_tool_root,'UserData');
main_data.eml=get(hObject,'String');
set(handles.david_tool_root,'UserData',main_data);

% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in register_david_pushbutton.
function register_david_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to register_david_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
web('http://david.abcc.ncifcrf.gov/webservice/register.htm')

% --- Executes on button press in to_file_radiobutton.
function to_file_radiobutton_Callback(hObject, eventdata, handles)
% hObject    handle to to_file_radiobutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of to_file_radiobutton


% --- Executes on button press in view_david_pushbutton.
function view_david_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to view_david_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

main_data=get(handles.david_tool_root,'UserData');
if isempty(main_data.vis_dir),alert('Title','No visualizations found','String','You must run Query DAVID first');return;end
if ispc, dos(['start ' fullfile(main_data.vis_dir,'david_clustering','david_treemap.html')]);
elseif ismac, unix(['open ' fullfile(main_data.vis_dir,'david_clustering','david_treemap.html')]);
else unix(['firefox ' fullfile(main_data.vis_dir,'david_clustering','david_treemap.html')]);end


% --- Executes on button press in c1_button.
function c1_button_Callback(hObject, eventdata, handles)
% hObject    handle to c1_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of c1_button
main_data=get(handles.david_tool_root,'UserData');
if ~isfield(main_data,'gene_clusts'),return;end
gl={};j=1;
for i=1:length(main_data.gene_clusts{1})
    idx=min(find(main_data.gene_clusts{1}(i)==main_data.gid));
    if ~isempty(idx),gl{j}=main_data.gsymb{idx};j=j+1;end
end
if get(hObject,'Value')
    set(handles.glist_textbox,'String',...
        union(gl,get(handles.glist_textbox,'String')));
else
    set(handles.glist_textbox,'String',...
        setdiff(get(handles.glist_textbox,'String'),gl));
    set(handles.all_button,'Value',0);
end

% --- Executes on button press in c2_button.
function c2_button_Callback(hObject, eventdata, handles)
% hObject    handle to c2_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of c2_button
main_data=get(handles.david_tool_root,'UserData');
if ~isfield(main_data,'gene_clusts'),return;end
gl={};j=1;
for i=1:length(main_data.gene_clusts{2})
    idx=min(find(main_data.gene_clusts{2}(i)==main_data.gid));
    if ~isempty(idx),gl{j}=main_data.gsymb{idx};j=j+1;end
end
if get(hObject,'Value')
    set(handles.glist_textbox,'String',...
        union(gl,get(handles.glist_textbox,'String')));
else
    set(handles.glist_textbox,'String',...
        setdiff(get(handles.glist_textbox,'String'),gl));
    set(handles.all_button,'Value',0);
end

% --- Executes on button press in c3_button.
function c3_button_Callback(hObject, eventdata, handles)
% hObject    handle to c3_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of c3_button
main_data=get(handles.david_tool_root,'UserData');
if ~isfield(main_data,'gene_clusts'),return;end
gl={};j=1;
for i=1:length(main_data.gene_clusts{3})
    idx=min(find(main_data.gene_clusts{3}(i)==main_data.gid));
    if ~isempty(idx),gl{j}=main_data.gsymb{idx};j=j+1;end
end
if get(hObject,'Value')
    set(handles.glist_textbox,'String',...
        union(gl,get(handles.glist_textbox,'String')));
else
    set(handles.glist_textbox,'String',...
        setdiff(get(handles.glist_textbox,'String'),gl));
    set(handles.all_button,'Value',0);
end

% --- Executes on button press in c4_button.
function c4_button_Callback(hObject, eventdata, handles)
% hObject    handle to c4_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of c4_button
main_data=get(handles.david_tool_root,'UserData');
if ~isfield(main_data,'gene_clusts'),return;end
gl={};j=1;
for i=1:length(main_data.gene_clusts{4})
    idx=min(find(main_data.gene_clusts{4}(i)==main_data.gid));
    if ~isempty(idx),gl{j}=main_data.gsymb{idx};j=j+1;end
end
if get(hObject,'Value')
    set(handles.glist_textbox,'String',...
        union(gl,get(handles.glist_textbox,'String')));
else
    set(handles.glist_textbox,'String',...
        setdiff(get(handles.glist_textbox,'String'),gl));
    set(handles.all_button,'Value',0);
end

% --- Executes on button press in all_button.
function all_button_Callback(hObject, eventdata, handles)
% hObject    handle to all_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of all_button
main_data=get(handles.david_tool_root,'UserData');
if ~isfield(main_data,'gene_clusts'),return;end
if get(hObject,'Value')
    set(handles.glist_textbox,'String',main_data.gsymb);
    for i=1:10,eval(['set(handles.c' num2str(i) '_button,''Value'',1)']);end
else
    set(handles.glist_textbox,'String',{});
    for i=1:10,eval(['set(handles.c' num2str(i) '_button,''Value'',0)']);end
end

% --- Executes on button press in c5_button.
function c5_button_Callback(hObject, eventdata, handles)
% hObject    handle to c5_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of c5_button
main_data=get(handles.david_tool_root,'UserData');
if ~isfield(main_data,'gene_clusts'),return;end
gl={};j=1;
for i=1:length(main_data.gene_clusts{5})
    idx=min(find(main_data.gene_clusts{5}(i)==main_data.gid));
    if ~isempty(idx),gl{j}=main_data.gsymb{idx};j=j+1;end
end
if get(hObject,'Value')
    set(handles.glist_textbox,'String',...
        union(gl,get(handles.glist_textbox,'String')));
else
    set(handles.glist_textbox,'String',...
        setdiff(get(handles.glist_textbox,'String'),gl));
    set(handles.all_button,'Value',0);
end

% --- Executes on button press in c6_button.
function c6_button_Callback(hObject, eventdata, handles)
% hObject    handle to c6_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of c6_button
main_data=get(handles.david_tool_root,'UserData');
if ~isfield(main_data,'gene_clusts'),return;end
gl={};j=1;
for i=1:length(main_data.gene_clusts{6})
    idx=min(find(main_data.gene_clusts{6}(i)==main_data.gid));
    if ~isempty(idx),gl{j}=main_data.gsymb{idx};j=j+1;end
end
if get(hObject,'Value')
    set(handles.glist_textbox,'String',...
        union(gl,get(handles.glist_textbox,'String')));
else
    set(handles.glist_textbox,'String',...
        setdiff(get(handles.glist_textbox,'String'),gl));
    set(handles.all_button,'Value',0);
end

% --- Executes on button press in c7_button.
function c7_button_Callback(hObject, eventdata, handles)
% hObject    handle to c7_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of c7_button
main_data=get(handles.david_tool_root,'UserData');
if ~isfield(main_data,'gene_clusts'),return;end
gl={};j=1;
for i=1:length(main_data.gene_clusts{7})
    idx=min(find(main_data.gene_clusts{7}(i)==main_data.gid));
    if ~isempty(idx),gl{j}=main_data.gsymb{idx};j=j+1;end
end
if get(hObject,'Value')
    set(handles.glist_textbox,'String',...
        union(gl,get(handles.glist_textbox,'String')));
else
    set(handles.glist_textbox,'String',...
        setdiff(get(handles.glist_textbox,'String'),gl));
    set(handles.all_button,'Value',0);
end

% --- Executes on button press in c8_button.
function c8_button_Callback(hObject, eventdata, handles)
% hObject    handle to c8_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of c8_button
main_data=get(handles.david_tool_root,'UserData');
if ~isfield(main_data,'gene_clusts'),return;end
gl={};j=1;
for i=1:length(main_data.gene_clusts{8})
    idx=min(find(main_data.gene_clusts{8}(i)==main_data.gid));
    if ~isempty(idx),gl{j}=main_data.gsymb{idx};j=j+1;end
end
if get(hObject,'Value')
    set(handles.glist_textbox,'String',...
        union(gl,get(handles.glist_textbox,'String')));
else
    set(handles.glist_textbox,'String',...
        setdiff(get(handles.glist_textbox,'String'),gl));
    set(handles.all_button,'Value',0);
end

% --- Executes on button press in c9_button.
function c9_button_Callback(hObject, eventdata, handles)
% hObject    handle to c9_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of c9_button
main_data=get(handles.david_tool_root,'UserData');
if ~isfield(main_data,'gene_clusts'),return;end
gl={};j=1;
for i=1:length(main_data.gene_clusts{9})
    idx=min(find(main_data.gene_clusts{9}(i)==main_data.gid));
    if ~isempty(idx),gl{j}=main_data.gsymb{idx};j=j+1;end
end
if get(hObject,'Value')
    set(handles.glist_textbox,'String',...
        union(gl,get(handles.glist_textbox,'String')));
else
    set(handles.glist_textbox,'String',...
        setdiff(get(handles.glist_textbox,'String'),gl));
    set(handles.all_button,'Value',0);
end

% --- Executes on button press in c10_button.
function c10_button_Callback(hObject, eventdata, handles)
% hObject    handle to c10_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of c10_button
main_data=get(handles.david_tool_root,'UserData');
if ~isfield(main_data,'gene_clusts'),return;end
gl={};j=1;
for i=1:length(main_data.gene_clusts{10})
    idx=min(find(main_data.gene_clusts{10}(i)==main_data.gid));
    if ~isempty(idx),gl{j}=main_data.gsymb{idx};j=j+1;end
end
if get(hObject,'Value')
    set(handles.glist_textbox,'String',...
        union(gl,get(handles.glist_textbox,'String')));
else
    set(handles.glist_textbox,'String',...
        setdiff(get(handles.glist_textbox,'String'),gl));
    set(handles.all_button,'Value',0);
end

% --- Executes on button press in delete_gene_pushbutton.
function delete_gene_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to delete_gene_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
idx=get(handles.glist_textbox,'Value');
glist_old=get(handles.glist_textbox,'String');
if isempty(idx)
    set(handles.glist_textbox,'String',{},'UserData',{},'Value',1);
else
    j=1;
    for i=1:idx-1,glist{j}=glist_old{i};j=j+1;end
    for i=idx+1:length(glist_old),glist{j}=glist_old{i};j=j+1;end
    set(handles.glist_textbox,'String',glist,'Value',max(1,idx-1));
end



function find_gene_editbox_Callback(hObject, eventdata, handles)
% hObject    handle to find_gene_editbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of find_gene_editbox as text
%        str2double(get(hObject,'String')) returns contents of find_gene_editbox as a double


% --- Executes during object creation, after setting all properties.
function find_gene_editbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to find_gene_editbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton15.
function pushbutton15_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in find_gene_button.
function find_gene_button_Callback(hObject, eventdata, handles)
% hObject    handle to find_gene_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
s=get(handles.find_gene_editbox,'String');
sample_data=get(handles.david_tool_root,'UserData');
idx=min(find(strcmpi(s,sample_data.gsymb)));
if isempty(idx),set(handles.find_gene_editbox,'String','Gene not found!');return;end
if ~isempty(idx)
    set(handles.glist_textbox,'Value',idx);
    sample_data.gsymb(get(handles.glist_textbox,'Value'))
    set(handles.screen_rank_textbox,'String',num2str(sample_data.prank(idx)));
    if sample_data.pval(idx)<=sample_data.screen_pcut
        set(handles.screen_pval_textbox,'String',num2str(sample_data.pval(idx)),'ForegroundColor','r');
    else
        set(handles.screen_pval_textbox,'String',num2str(sample_data.pval(idx)),'ForegroundColor','k');
    end
    set(handles.nsh_textbox,'String',num2str(sample_data.nsh(idx)));
    if sample_data.tt(idx)==-1,
        set(handles.ttest_textbox,'String','NA');
        set(handles.exp_fc_textbox,'String','NA');    
    else
        if sample_data.tt(idx)<=sample_data.gexp_pcut
            set(handles.ttest_textbox,'String',num2str(sample_data.tt(idx)),'ForegroundColor','r');
        else
            set(handles.ttest_textbox,'String',num2str(sample_data.tt(idx)),'ForegroundColor','k');
        end
        set(handles.exp_fc_textbox,'String',num2str(sample_data.fc(idx)));
    end
    set(handles.mlodz_textbox,'String',num2str(sample_data.mlodz(idx)));
    if isfield(sample_data,'net_cent_comb')
        set(handles.net_cent_textbox,'String',num2str(sample_data.net_cent_comb(idx)));

    end
end

% --- Executes on button press in export_gene_list.
function export_gene_list_Callback(hObject, eventdata, handles)
% hObject    handle to export_gene_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

main_data=get(handles.david_tool_root,'UserData');
glst_ids=get(handles.glist_textbox,'String');
glists=get(main_data.glists_textbox,'UserData');
v=get(main_data.glists_textbox,'Value');
glists{v}=glst_ids;
set(main_data.glists_textbox,'UserData',glists);
set(main_data.main_glst,'String',glst_ids,'UserData',glst_ids);

% --- Executes during object creation, after setting all properties.
function query_david_pushbutton_CreateFcn(hObject, eventdata, handles)
% hObject    handle to query_david_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
