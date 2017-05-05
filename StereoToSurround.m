function varargout = StereoToSurround(varargin)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @StereoToSurround_OpeningFcn, ...
                   'gui_OutputFcn',  @StereoToSurround_OutputFcn, ...
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


% --- Executes just before StereoToSurround is made visible.
function StereoToSurround_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to StereoToSurround (see VARARGIN)
%#function fints
%#function dfilt.dffir

% Choose default command line output for StereoToSurround
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes StereoToSurround wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = StereoToSurround_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function input_text_Callback(hObject, eventdata, handles)
% hObject    handle to input_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of input_text as text
%        str2double(get(hObject,'String')) returns contents of input_text as a double


% --- Executes during object creation, after setting all properties.
function input_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to input_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function output_text_Callback(hObject, eventdata, handles)
% hObject    handle to output_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of output_text as text
%        str2double(get(hObject,'String')) returns contents of output_text as a double


% --- Executes during object creation, after setting all properties.
function output_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to output_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in input_path.
function input_path_Callback(hObject, eventdata, handles)
% hObject    handle to input_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[inputfilename, inputpathname] = uigetfile('*.*','Select Stereo File');
if inputfilename == 0
    return
end
fullinputpathname = strcat (inputpathname, inputfilename);
set(handles.input_text,'String',[fullinputpathname]);


% --- Executes on button press in output_path.
function output_path_Callback(hObject, eventdata, handles)
% hObject    handle to output_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[outputfilename, outputpathname]=uiputfile('*.wav','Select Output Folder');
fulloutputpathname = strcat (outputpathname, outputfilename);
if outputfilename == 0
    return;
end
set(handles.output_text,'String',fulloutputpathname);

% --- Executes on button press in convert.
function convert_Callback(hObject, eventdata, handles)
% hObject    handle to convert (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%#function fints
%#function dfilt.dffir
load('Hd200.mat');
load('Hd7.mat');
inputfile = get(handles.input_text,'String');
[original,Fs] = audioread(inputfile);
set(handles.input_text,'Enable','off');
set(handles.input_path,'Enable','off');
set(handles.output_text,'Enable','off');
set(handles.output_path,'Enable','off');
set(handles.convert,'Enable','off');
[m,n] = size(original);
if n~=2
    set(handles.input_text,'Enable','on');
    set(handles.input_path,'Enable','on');
    set(handles.output_text,'Enable','on');
    set(handles.output_path,'Enable','on');
    set(handles.convert,'Enable','on');
    errordlg('Only stereo audio files are supported.','File Error');
    close(h)
end
h = waitbar(0,'Converting Stereo to Surround. Please Wait...');waitbar( 1/ 8)
leftChannel=original(:,1);                              
rightChannel=original(:,2);                                   
centerChannel=(leftChannel + rightChannel)/sqrt(2);
upmixedSurroundChannel=(leftChannel - rightChannel)/sqrt(2);waitbar( 2/ 8)
delayedSurroundChannel = delayseq(upmixedSurroundChannel,0.012,Fs);
filteredSurroundChannel = filter(Hd7,delayedSurroundChannel);waitbar( 3/ 8)
LFEChannel = filter(Hd200,centerChannel);
LFEChannel = 0.5*(LFEChannel);waitbar( 4/ 8)
surroundHilbertTransform = hilbert(filteredSurroundChannel);
surroundright = imag(surroundHilbertTransform);waitbar( 5/ 8)
surroundleft=-(surroundright); waitbar( 6/ 8)
surroundsong=horzcat(leftChannel,rightChannel,centerChannel,LFEChannel,surroundleft,surroundright);waitbar( 7/ 8)
surroundsong = surroundsong./max(abs(surroundsong(:)))*(1-(2^-(16-1)));waitbar( 8/ 8)
close(h)
q = waitbar(0,'Saving Surround File. Please Wait.');
waitbar(1/ 2)
outputfile = get(handles.output_text,'String');
audiowrite(outputfile,surroundsong,Fs);
waitbar(2/ 2)
close(q)
set(handles.input_text,'Enable','on');
set(handles.input_path,'Enable','on');
set(handles.output_text,'Enable','on');
set(handles.output_path,'Enable','on');
set(handles.convert,'Enable','on');