function net = neuralNetwork
%% Funkcja, która tworzy, konfiguruje, trenuje oraz testuje sieæ neuronow¹
% stworzon¹ do rozpoznawania gestóws
%
%  NET = NEURAL_NETWORK()
%  Returns:
%    NET - stworzona przez funkcje sieæ s³u¿¹ca do rozpoznawania gestów
%
% Marek Cabaj & Kamil Król
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
network.divideFcn = '';       % wy³¹czenie funkcji dziel¹cej zestaw danych na Train/Validate/Test
network.initFcn = 'initlay';  % ustawienie funkcji, która  inicjalizuje wagi i bias'y 

%% Inicjalizacja wagi i bias'ów
network = init(network);     % inicjalizacja sieci neuronowej

%% Trenowanie sieci
network = train(network,X,T);   % trenowanie sieci


%%
net = network;
end
