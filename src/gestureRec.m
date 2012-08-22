function varargout = gestureRec(varargin)
% GESTUREREC MATLAB code for gestureRec.fig
%      GESTUREREC, by itself, creates a new GESTUREREC or raises the existing
%      singleton*.
%
%      H = GESTUREREC returns the handle to a new GESTUREREC or the handle to
%      the existing singleton*.
%
%      GESTUREREC('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GESTUREREC.M with the given input arguments.
%
%      GESTUREREC('Property','Value',...) creates a new GESTUREREC or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gestureRec_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gestureRec_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gestureRec

% Last Modified by GUIDE v2.5 03-May-2012 13:36:37

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gestureRec_OpeningFcn, ...
                   'gui_OutputFcn',  @gestureRec_OutputFcn, ...
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


% --- Executes just before gestureRec is made visible.
function gestureRec_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gestureRec (see VARARGIN)

% Choose default command line output for gestureRec
handles.output = hObject;

% Create video object
% Putting the object into manual trigger mode and then
% starting the object will make GETSNAPSHOT return faster
% since the connection to the camera will already have
% been established.

camera = imaqhwinfo('winvideo',1);
supportedFormats = camera.SupportedFormats;
ind = cellfun(@(x)(~isempty(x)), regexp(supportedFormats,'.*640x480.*'));
formatName = supportedFormats(ind);
formatName = char(formatName);

handles.video = videoinput('winvideo', 1, formatName);

set(handles.video,'TimerPeriod', 0.01, ...
'TimerFcn',['if(~isempty(gco)),'...
'handles=guidata(gcf);'... % Update handles
'axes(handles.liveVid);'... % Set liveVid as a current axes
'imshow(ycbcr2rgb(getsnapshot(handles.video)));'... % Get picture using GETSNAPSHOT and put it into axes using IMAGE
'set(handles.liveVid,''ytick'',[],''xtick'',[]),'... % Remove tickmarks and labels that are inserted when using IMAGE
'else '...
'delete(imaqfind);'... % Clean up - delete any image acquisition objects
'end']);
triggerconfig(handles.video,'manual');

%Img = zeros(15,20,15);
%counter = 1;
%setappdata(handles.train,'Img',Img);
%setappdata(handles.train,'counter',counter);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes gestureRec wait for user response (see UIRESUME)
uiwait(handles.gestureRec);


% --- Outputs from this function are returned to the command line.
function varargout = gestureRec_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
handles.output = hObject;
varargout{1} = handles.output;


% --- Executes when user attempts to close gestureRec.
function gestureRec_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to gestureRec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure

%Img = getappdata(handles.train,'Img');
%save('learnData.mat','Img');
delete(hObject);
delete(imaqfind);


% --- Executes on button press in startStop.
function startStop_Callback(hObject, eventdata, handles)
% hObject    handle to startStop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Start/Stop Camera
if strcmp(get(handles.startStop,'String'),'Start Camera')
    % Camera is off. Change button string and start camera.
    set(handles.startStop,'String','Stop Camera')
    start(handles.video)
    set(handles.capture,'Enable','on');
    
else
    % Camera is on. Stop camera and change button string.
    set(handles.startStop,'String','Start Camera')
    stop(handles.video)
    set(handles.capture,'Enable','off');
end


% --- Executes on button press in capture.
function capture_Callback(hObject, eventdata, handles)
% hObject    handle to capture (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% frame = getsnapshot(handles.video);
frame = get(get(handles.liveVid,'children'),'cdata'); % The current displayed frame

% Preprocessing
I = frame;
I = rgb2gray(I);

level = graythresh(I);
I = im2bw(I, level);

imSize = size(I,1)*size(I,2);
toDelete = 0.1*imSize;

I = bwareaopen(I, toDelete);

se = strel('disk',10);
I = imclose(I,se);

handles=guidata(gcf);
axes(handles.capturedPic);
imshow(I);

I = imresize(I,0.03125);

%Img = getappdata(handles.train,'Img');
%counter = getappdata(handles.train,'counter');

%Img(:,:,counter) = I;
%counter = counter + 1;

%setappdata(handles.train,'Img',Img);
%setappdata(handles.train,'counter',counter);

% Using neural network
X = zeros(1,300);
for j=0:14
    X(1,(20*j)+1:20*(j+1)) = I(j+1,:);
end
X=X';

network = getappdata(handles.train,'Network');
Y = network(X);
Y
% Giving answer

counter = 0;    % licznik pomocniczy
for i = 1:3
    if Y(i) < 0.5   % je¿eli odpowiedŸ sieci jest mniejsza od 0.5 uwa¿ana jest za niedostatecznie siln¹
        Y(i) = 0;   % zerujemy tak¹ odpowiedŸ
        counter = counter+1;    % zliczamy iloœæ za s³abych sygna³ów wyjœciowych
    end
end
if counter == 3    % wszystkie odpowiedzi by³y na tyle s³abe, ¿e mo¿na uznaæ cyfrê jako nierozpoznan¹
    answer = 'Gest nie rozpoznany';
else
    Y = compet(Y);  % funkcja compet zeruje wszystkie elementy wektora Y oprócz najwiêkszego, który zamienia na '1'
    pos = find(Y==1);   % ustalenie pozycji elementu najwiêkszego
    switch pos
        case 1
            answer = 'Fist';
        case 2
            answer = 'Open hand';
        case 3
            answer = 'Scissors';
    end
end

answ = strcat('Network answer :  ',answer);

set(handles.txt,'String',answ);
set(handles.capturedPic,'ytick',[],'xtick',[]);


% --- Executes on button press in showTrainSet.
function showTrainSet_Callback(hObject, eventdata, handles)
% hObject    handle to showTrainSet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

showTestData;

% --- Executes on button press in train.
function train_Callback(hObject, eventdata, handles)
% hObject    handle to train (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

network = neuralNetwork();

setappdata(handles.train,'Network',network);
set(handles.startStop,'Enable','on');
set(handles.train,'Enable','off');  
set(handles.showTrainSet,'Enable','off');
