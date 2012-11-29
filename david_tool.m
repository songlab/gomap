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

% Last Modified by GUIDE v2.5 28-Nov-2012 11:22:30

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

main_data.id_type='ENTREZ gene ID';
main_data.species='Homo sapien';
main_data.fc=[];
main_data.pval=[];
main_data.prank=[];
main_data.gsymb={};
main_data.gid=[];
main_data.eml=[];
main_data.GO=[];
main_data.pname=pwd;
h=waitbar(0,'loading java packaes');
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
wb=waitbar(0.5,'Loading gene ontology data.');
main_data.GO=geneont('file','gene_ontology.obo');
set(handles.david_tool_root,'UserData',main_data);
delete(wb);
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


% --- Executes on button press in load_glst_btn.
function load_glst_btn_Callback(hObject, eventdata, handles)
% hObject    handle to load_glst_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
main_data=get(handles.david_tool_root,'UserData');
isent=strcmp(main_data.id_type,'ENTREZ gene ID');
if isent&strcmp(main_data.species,'Other')
    alert('title','Gene list format error','string','Only ENTREZ ids are supported for species other than human or mouse');
    return;
end
if isent, s='%n';
else, s='%s';end
ge=get(handles.radiobutton1,'Value');
if ge,s=[s '%n%n'];end
[fname pname]=uigetfile(fullfile(main_data.pname, '*'),'Select gene list...');
if ~fname,return;
else,main_data.pname=pname;end
f=fopen(fullfile(pname,fname));
D=textscan(f,s);
if ge
    main_data.fc=D{2};
    main_data.pval=D{3};
    [~,sidx]=sort(main_data.pval);
    main_data.prank=sidx;
end
if isent
    main_data.gid=D{1};
    if strcmp(main_data.species,'Other')
        for i=1:length(D{1}),t{i}=num2str(D{1}(i));end
    else
        if strcmp(main_data.species,'Homo sapien')
            load('entrez2gsymb_hsa.mat');ent2symb=ent2symb_hsa;
        end
        if strcmp(main_data.species,'Mus musculus')
            load('entrez2gsymb_mmu.mat');ent2symb=ent2symb_mmu;
        end
        for i=1:length(D{1}),t{i}=ent2symb(D{1}(i));end
    end
    main_data.gsymb=t;
else
    main_data.gsymb=D{1};
    isref=strcmp(main_data.id_type,'RefSeq accession');
    ishum=strcmp(main_data.species,'Homo sapien');
    if isref
        if ishum,load('refseq2entrez_hsa.mat');symb2ent=ref2ent_hsa;
        else,load('refseq2entrez_mmu.mat');symb2ent=ref2ent_mmu;
        end
    else
        if ishum,load('symb2entrez_hsa.mat');symb2ent=symb2ent_hsa;
        else,load('symb2entrez_mmu.mat');symb2ent=symb2ent_mmu;
        end
    end
    kz=symb2ent.keys;
    for i=1:lentgh(D{1})
        idx=find(strcmpi(D{1}{i},kz));
        en(i)=symb2ent(kz(idx));
    end
    main_data.gid=en;    
end
if ge
    gs{1}=sprintf('Gene : Entrez ID : Fold change : p-value\n');
    for i=1:length(main_data.gid)
        gs{i+1}=[sprintf('%s : ',main_data.gsymb{i}),sprintf('%i : ',main_data.gid(i)),...
            sprintf('%g : ',main_data.fc(i)),sprintf('%g\n',main_data.pval(i))];
    end
else
    gs{1}=sprintf('Gene\tEntrez ID\n');
    for i=1:length(main_data.gid)
        gs{i+1}=[sprintf('%s : ',main_data.gsymb{i}),sprintf('%i\n',main_data.gid(i))];
    end
end
set(handles.glist_textbox,'String',gs);
set(handles.david_tool_root,'UserData',main_data);

% --- Executes on button press in query_david_btn.
function query_david_btn_Callback(hObject, eventdata, handles)
% hObject    handle to query_david_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
main_data=get(handles.david_tool_root,'UserData');
if isempty(main_data.gid)
    alert('title','No data loaded','String','Load a gene list first');
    return;
end
if isempty(main_data.eml)
    alert('title','Enter an email in the edit box which is registered with DAVID','String','No valid email found.');
    return;
end
c=query_david(main_data.gid,main_data.eml);
if isempty(main_data.fc)
    x=pack_david_clusr_for_treemap(c,[],main_data.GO);
else
    x=pack_david_clusr_for_treemap(c,main_data,main_data.GO);
end
clear c;
pause(0.5);
h=waitbar(0.25,'Writting javascript files');
js=make_treemap_json_from_david(x);
f=fopen('david_cluster_report/data.js','w');
fprintf(f,'var json_data = %s;',js);
fclose(f);
waitbar(0.75,h,'Spawning web browser')
web david_cluster_report/david_treemap.html -browser
waitbar(0.9,h,'Packaging web files for you to use later')
[fname pname]=uiputfile(fullfile(main_data.pname,'david_cluster_report.zip'));
if ~isequal(fname,0)&~isequal(pname,0),zip(fullfile(pname,fname),'david_cluster_report');end
delete(h)
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
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String',{'ENTREZ gene ID','Gene symbol','RefSeq accession'});


% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2
main_data=get(handles.david_tool_root,'UserData');
contents = cellstr(get(hObject,'String'));
main_data.species=contents{get(hObject,'Value')};
set(handles.david_tool_root,'UserData',main_data);

% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String',{'Homo sapien','Mus musculus', 'Other'});

% --- Executes on button press in radiobutton1.
function radiobutton1_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double
main_data=get(handles.david_tool_root,'UserData');
main_data.eml=get(hObject,'String');
set(handles.david_tool_root,'UserData',main_data);

% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

web('http://david.abcc.ncifcrf.gov/webservice/register.htm')
