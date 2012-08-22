function net = neuralNetwork
%% Funkcja, kt�ra tworzy, konfiguruje, trenuje oraz testuje sie� neuronow�
% stworzon� do rozpoznawania gest�ws
%
%  NET = NEURAL_NETWORK()
%  Returns:
%    NET - stworzona przez funkcje sie� s�u��ca do rozpoznawania gest�w
%
% Marek Cabaj & Kamil Kr�l
% 03.05.2012



%% Tworzenie zestawu danych do uczenia 
load('learnData.mat');
load('targetData.mat');

X = zeros(300,15);
T = Target;

for i=1:15
    Tmp = zeros(1,300);
    for j=0:14
        Tmp(1,(20*j)+1:20*(j+1)) = Img(j+1,:,i);
    end
    Tmp=Tmp';
    X(:,i) = Tmp;
end

%% Tworzenie sieci neuronowej
network = feedforwardnet(40);   % tworzenie sieci neuronowej typu feedforward z 40 neuronami

%% Konfigurowanie sieci
network.divideFcn = '';       % wy��czenie funkcji dziel�cej zestaw danych na Train/Validate/Test
network.initFcn = 'initlay';  % ustawienie funkcji, kt�ra  inicjalizuje wagi i bias'y 

%% Inicjalizacja wagi i bias'�w
network = init(network);     % inicjalizacja sieci neuronowej

%% Trenowanie sieci
network = train(network,X,T);   % trenowanie sieci


%%
net = network;
end
