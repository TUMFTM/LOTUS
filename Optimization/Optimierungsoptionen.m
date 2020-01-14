function varargout = Optimierungsoptionen(varargin)
% OPTIMIERUNGSOPTIONEN MATLAB code for Optimierungsoptionen.fig
%      OPTIMIERUNGSOPTIONEN, by itself, creates a new OPTIMIERUNGSOPTIONEN or raises the existing
%      singleton*.
%
%      H = OPTIMIERUNGSOPTIONEN returns the handle to a new OPTIMIERUNGSOPTIONEN or the handle to
%      the existing singleton*.
%
%      OPTIMIERUNGSOPTIONEN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in OPTIMIERUNGSOPTIONEN.M with the given input arguments.
%
%      OPTIMIERUNGSOPTIONEN('Property','Value',...) creates a new OPTIMIERUNGSOPTIONEN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Optimierungsoptionen_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Optimierungsoptionen_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Optimierungsoptionen

% Last Modified by GUIDE v2.5 24-Apr-2016 15:40:09

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Optimierungsoptionen_OpeningFcn, ...
                   'gui_OutputFcn',  @Optimierungsoptionen_OutputFcn, ...
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
end

% --- Executes just before Optimierungsoptionen is made visible.
function Optimierungsoptionen_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Optimierungsoptionen (see VARARGIN)

% Choose default command line output for Optimierungsoptionen
handles.output = hObject;
movegui(hObject,'center')                                               %Theisen  14.04.2016

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Optimierungsoptionen wait for user response (see UIRESUME)
% uiwait(handles.figure1);
global Composition

Composition{1}.VSim.n_gen=str2double(get(handles.edit_gen, 'String'));
Composition{1}.VSim.n_ind=str2double(get(handles.edit_ind, 'String'));

Dauer = 25;                                                                              %Dauer pro Simulation ca. 25s
Dauer=round((Composition{1}.VSim.n_gen*Composition{1}.VSim.n_ind)*(Dauer/60),1);
set(handles.text5, 'String', ['Voraussichtliche Dauer: ca.  ' num2str(Dauer) ' min']);

end

% --- Outputs from this function are returned to the command line.
function varargout = Optimierungsoptionen_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end


function edit_ind_Callback(hObject, eventdata, handles)
% hObject    handle to edit_ind (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_ind as text
%        str2double(get(hObject,'String')) returns contents of edit_ind as a double
    global Composition
        n_ind=str2double(get(handles.edit_ind, 'String'));
        if n_ind>0
        Composition{1}.VSim.n_ind=n_ind;
        end
        
Dauer = 34;                                                                              %Dauer pro Simulation ca. 34s
Dauer=round((Composition{1}.VSim.n_gen*Composition{1}.VSim.n_ind)*(Dauer/60),1);
set(handles.text5, 'String', ['Voraussichtliche Dauer: ca.  ' num2str(Dauer) ' min']);
        
end

% --- Executes during object creation, after setting all propertie.
function edit_ind_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_ind (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function edit_gen_Callback(hObject, eventdata, handles)
% hObject    handle to edit_gen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_gen as text
%        str2double(get(hObject,'String')) returns contents of edit_gen as a double
        global Composition
        n_gen=str2double(get(handles.edit_gen, 'String'));
        if n_gen>0
        Composition{1}.VSim.n_gen=n_gen;
        end
        
Dauer = 34;                                                                              %Dauer pro Simulation ca. 34s
Dauer=round((Composition{1}.VSim.n_gen*Composition{1}.VSim.n_ind)*(Dauer/60),1);
set(handles.text5, 'String', ['Voraussichtliche Dauer: ca.  ' num2str(Dauer) ' min']);
        
end

% --- Executes during object creation, after setting all propertie.
function edit_gen_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_gen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% --- Executes on selection change in popupmenu_optgroessen.
function popupmenu_optgroessen_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_optgroessen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_optgroessen contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_optgroessen

global Composition
Composition{1}.VSim.Opt_groessen = get(handles.popupmenu_optgroessen ,'Value');

Dauer = 34;                                                                              %Dauer pro Simulation ca. 34s
Dauer=round((Composition{1}.VSim.n_gen*Composition{1}.VSim.n_ind)*(Dauer/60),1);
set(handles.text5, 'String', ['Voraussichtliche Dauer: ca.  ' num2str(Dauer) ' min']);

end

% --- Executes during object creation, after setting all propertie.
function popupmenu_optgroessen_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_optgroessen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% --- Executes on button press in pb_start.
function pb_start_Callback(hObject, eventdata, handles)
% hObject    handle to pb_start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global Composition

Composition{1}.VSim.Opt_groessen = get(handles.popupmenu_optgroessen ,'Value');

Composition{1}.VSim.n_gen=str2double(get(handles.edit_gen, 'String'));
Composition{1}.VSim.n_ind=str2double(get(handles.edit_ind, 'String'));

if(get(handles.rb_parallel,'Value')==1)     % Wenn Haken gesetzt
    Composition{1}.VSim.Parallel = 'yes';
else                                        % Wenn kein Haken gesetzt
    Composition{1}.VSim.Parallel = 'no';
end

close all
Start_Mehrzielopti2015b

end

% --- Executes on button press in pb_zurueck.
function pb_zurueck_Callback(hObject, eventdata, handles)
% hObject    handle to pb_zurueck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    cd ../;    
    close all
    Gui_Menue3();
end


% --- Executes on button press in rb_parallel.
function rb_parallel_Callback(hObject, eventdata, handles)
% hObject    handle to rb_parallel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rb_parallel
global Composition
if(get(handles.rb_parallel,'Value')==1)     % Wenn Haken gesetzt
    Composition{1}.VSim.Parallel = 'yes';
else                                        % Wenn kein Haken gesetzt
    Composition{1}.VSim.Parallel = 'no';
end

end
